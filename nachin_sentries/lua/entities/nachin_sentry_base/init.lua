AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- ───────────────────────────────────────────────────────────────────────────────
local COMBINE_FRIENDLY = {
    npc_combine_s            = true,
    npc_combine_prison_guard = true,
    npc_metropolice          = true,
    npc_manhack              = true,
    npc_helicopter           = true,
    npc_combinegunship       = true,
    npc_strider              = true,
    npc_rollermine           = true,
    npc_cscanner             = true,
    npc_clawscanner          = true,
    npc_turret_floor         = true,
    npc_turret_ceiling       = true,
    npc_turret_ground        = true,
    combine_mine             = true,
}

local HEAT_COOLING_RATE     = 5
local HEAT_HEATING_RATE     = 8
local HEAT_MAX              = 100
local HEAT_OVERHEAT         = 90
local HEAT_COOLDOWN         = 45
local HEIGHT_OFFSET         = 55
local INACCURACY            = 0.03
local BARREL_SPIN_THRESH    = 0.85
local IDLE_DELAY_MIN        = 3
local IDLE_DELAY_MAX        = 6
local IDLE_HOLD_MIN         = 1
local IDLE_HOLD_MAX         = 2
local IDLE_YAW_RANGE        = 40
local IDLE_PITCH_RANGE      = 15
local THINK_DT              = 0.1
local FAST_DT               = 0.02
local SEARCH_INTERVAL       = 0.5
local SEARCH_STATE_DUR      = 2
local SEARCH_TIMEOUT        = 5

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:Initialize()
    self:SetModel(self.GunModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() phys:SetMass(150) end

    self:SetHP(self.GunMaxHealth)
    self:SetAimPitch(0)
    self:SetAimYaw(0)
    self:SetHeat(0)
    self:SetBarrelSpin(0)

    self.MaxHealth         = self.GunMaxHealth
    self.TurnSpeed         = self.GunTurnSpeed
    self.TargetingRadius   = self.GunRadius
    self.FireRate          = self.GunFireRate
    self.Damage            = self.GunDamage
    self.CoolingRate       = HEAT_COOLING_RATE
    self.HeatingRate       = HEAT_HEATING_RATE
    self.MaxHeat           = HEAT_MAX
    self.OverheatThreshold = HEAT_OVERHEAT
    self.CooldownThreshold = HEAT_COOLDOWN

    self.Target            = nil
    self.NextFire          = 0
    self.Firing            = false
    self.BarrelSpinTarget  = 0
    self.NextIdleLook      = 0
    self.IdleTargetYaw     = nil
    self.IdleTargetPitch   = nil
    self.IdleHoldUntil     = nil
    self.IdleScanPhase     = nil
    self.NextTargetSearch  = 0
    self.SearchData = {
        LastKnownPos      = nil,
        NextDeEsc         = 0,
        NextSearchChange  = 0,
        State             = 0,
    }
    self:SetState(self.STATE_WATCHING)
    self:EmitSound("npc/turret_floor/active.wav", 65, 100)
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 10)
    ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
    ent:Spawn()
    ent:Activate()
    return ent
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:Think()
    local t = CurTime()
    self:UpdateHeat()
    self:UpdateBarrelSpin()
    self:UpdateState(t)
    self:HandleFiring(t)
    self:NextThink(t + FAST_DT)
    return true
end

function ENT:UpdateHeat()
    local h = self:GetHeat()
    if h > 0 then
        self:SetHeat(math.Clamp(h - self.CoolingRate * THINK_DT, 0, self.MaxHeat))
    end
end

function ENT:UpdateBarrelSpin()
    local cur = self:GetBarrelSpin()
    local tgt = self.BarrelSpinTarget
    if cur ~= tgt then
        local acc = tgt > cur and 0.15 or 0.1
        self:SetBarrelSpin(math.Clamp(cur + (tgt - cur) * acc, 0, 1))
    end
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:UpdateState(t)
    local s = self:GetState()
    if s == self.STATE_BROKEN or s == self.STATE_OFF then
        self.Firing = false ; self.BarrelSpinTarget = 0
    elseif s == self.STATE_OVERHEATED then
        self.Firing = false ; self.BarrelSpinTarget = 0
        if self:GetHeat() < self.CooldownThreshold then self:SetState(self.STATE_WATCHING) end
    elseif s == self.STATE_WATCHING  then self:HandleWatching(t)
    elseif s == self.STATE_SEARCHING then self:HandleSearching(t)
    elseif s == self.STATE_ENGAGING  then self:HandleEngaging()
    end
end

function ENT:HandleWatching(t)
    self.Firing = false ; self.BarrelSpinTarget = 0
    local tgt = self:TryFindTarget()
    if tgt then self:Engage(tgt) ; self:ClearIdleScan()
    else        self:PerformIdleScan(t) end
end

function ENT:HandleSearching(t)
    self.Firing = false ; self.BarrelSpinTarget = 0
    if self:CanEngage(self.Target) then self:Engage(self.Target) ; return end
    local tgt = self:TryFindTarget()
    if IsValid(tgt) then self:Engage(tgt) ; return end
    if self.SearchData.State == 1 and self.SearchData.LastKnownPos then
        local dp, dy = self:GetTargetAimOffset(self.SearchData.LastKnownPos)
        if dp or dy then self:Turn(dp, dy) end
    end
    if self.SearchData.NextSearchChange < t then
        self.SearchData.NextSearchChange = t + SEARCH_STATE_DUR
        self.SearchData.State = self.SearchData.State + 1
        if self.SearchData.State >= 2 then self:StandDown() end
    end
    if self.SearchData.NextDeEsc < t then self:StandDown() end
end

function ENT:HandleEngaging()
    if self:CanEngage(self.Target) then
        local tp = self:DetermineTargetAimPoint(self.Target)
        self.SearchData.LastKnownPos = tp
        local dp, dy = self:GetTargetAimOffset(tp)
        local ap, ay = math.abs(dp or 0), math.abs(dy or 0)
        if ap > 0 or ay > 0 then self:Turn(dp, dy) end
        if ap < 3 and ay < 3 then
            self.BarrelSpinTarget = 1.0
            self.Firing = self:GetBarrelSpin() > BARREL_SPIN_THRESH
        else
            self.Firing = false ; self.BarrelSpinTarget = 0
        end
    else
        local tgt = self:TryFindTarget()
        if tgt then self:Engage(tgt) else self:Disengage() end
    end
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:PerformIdleScan(t)
    if not self.IdleScanPhase then
        self.IdleScanPhase = "centered"
        self.NextIdleLook  = t + math.Rand(IDLE_DELAY_MIN, IDLE_DELAY_MAX)
    end
    local cy, cp = self:GetAimYaw(), self:GetAimPitch()
    if self.IdleScanPhase == "centered" then
        if t > self.NextIdleLook then
            self.IdleTargetYaw   = math.Rand(-IDLE_YAW_RANGE,   IDLE_YAW_RANGE)
            self.IdleTargetPitch = math.Rand(-IDLE_PITCH_RANGE, IDLE_PITCH_RANGE)
            self.IdleScanPhase   = "scanning"
        elseif math.abs(cy) > 1 or math.abs(cp) > 1 then
            self:ReturnToForward()
        end
    elseif self.IdleScanPhase == "scanning" then
        local ny = cy - self.IdleTargetYaw
        local np = -cp - self.IdleTargetPitch
        if math.abs(ny) > 2 or math.abs(np) > 2 then
            self:Turn(np, ny)
        else
            self.IdleScanPhase = "holding"
            self.IdleHoldUntil = t + math.Rand(IDLE_HOLD_MIN, IDLE_HOLD_MAX)
        end
    elseif self.IdleScanPhase == "holding" then
        if t > self.IdleHoldUntil then self.IdleScanPhase = "returning" end
    elseif self.IdleScanPhase == "returning" then
        if math.abs(cy) > 1 or math.abs(cp) > 1 then
            self:ReturnToForward()
        else
            self.IdleScanPhase = "centered"
            self.NextIdleLook  = t + math.Rand(IDLE_DELAY_MIN, IDLE_DELAY_MAX)
            self:ClearIdleScan()
        end
    end
end

function ENT:ClearIdleScan()
    self.IdleTargetYaw   = nil
    self.IdleTargetPitch = nil
    self.IdleHoldUntil   = nil
    self.IdleScanPhase   = nil
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:HandleFiring(t)
    if not self.Firing or self.NextFire >= t then return end
    local heat = self:GetHeat()
    if heat < self.OverheatThreshold then
        self.NextFire = t + (1 / self.FireRate)
        self:FireWeapon()
    else
        self:SetState(self.STATE_OVERHEATED)
        self:EmitSound("weapons/ar2/ar2_empty.wav", 70, 100)
    end
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:GetMuzzlePos()
    local muzzleBone = self:LookupBone(self.GunMuzzleBone)
    local pivotBone  = self:LookupBone(self.GunPivotBone)
    local selfPos    = self:GetPos()
    local selfAng    = self:GetAngles()
    local up         = self:GetUp()

    if pivotBone and muzzleBone then
        local pm = self:GetBoneMatrix(pivotBone)
        local mm = self:GetBoneMatrix(muzzleBone)
        if pm and mm then
            local pivotLocal  = self:WorldToLocal(pm:GetTranslation())
            local muzzleLocal = self:WorldToLocal(mm:GetTranslation())
            local p2m         = muzzleLocal - pivotLocal
            local yawAng      = Angle(selfAng)
            yawAng:RotateAroundAxis(up, self:GetAimYaw())
            local pivotPos = selfPos
                + yawAng:Forward() * pivotLocal.x
                + yawAng:Right()   * pivotLocal.y
                + yawAng:Up()      * pivotLocal.z
            local aimAng = Angle(yawAng)
            aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
            local muzzlePos = pivotPos
                + aimAng:Forward() * p2m.x
                + aimAng:Right()   * p2m.y
                + aimAng:Up()      * p2m.z
            return muzzlePos, aimAng
        end
    end

    local aimAng = Angle(selfAng)
    aimAng:RotateAroundAxis(up, self:GetAimYaw())
    aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
    local fb = self.GunMuzzleFB
    local muzzlePos = selfPos
        + aimAng:Forward() * fb.x
        + aimAng:Right()   * fb.y
        + aimAng:Up()      * fb.z
    return muzzlePos, aimAng
end

function ENT:FireWeapon()
    local muzzlePos, aimAng = self:GetMuzzlePos()
    local shootDir = (aimAng:Forward() + VectorRand() * INACCURACY):GetNormalized()

    if self.GunWeaponType == "rocket" then
        local rocket = ents.Create("rpg_missile")
        if IsValid(rocket) then
            rocket:SetPos(muzzlePos)
            rocket:SetAngles(aimAng)
            rocket:SetOwner(self)
            rocket:Spawn()
            rocket:Activate()
            local phys = rocket:GetPhysicsObject()
            if IsValid(phys) then phys:SetVelocity(shootDir * 1200) end
        end
        self:EmitSound("weapons/rpg/rocket1.wav", 75, math.random(95, 105))
    else
        self:FireBullets({
            Attacker     = self,
            Damage       = self.Damage,
            Force        = self.Damage * 2,
            Num          = 1,
            Tracer       = 0,
            Dir          = shootDir,
            Spread       = Vector(0, 0, 0),
            Src          = muzzlePos,
            IgnoreEntity = self,
        })
        local tr = util.TraceLine({ start = muzzlePos, endpos = muzzlePos + shootDir * 10000, filter = self, mask = MASK_SHOT })
        local td = EffectData(); td:SetStart(muzzlePos); td:SetOrigin(tr.HitPos); td:SetScale(5000)
        util.Effect("Tracer", td)
        local ed = EffectData(); ed:SetOrigin(muzzlePos); ed:SetNormal(shootDir); ed:SetAngles(aimAng)
        util.Effect(self.GunMuzzleFX, ed)
        self:EmitSound(self.GunShootSound, 75, math.random(95, 105))
    end

    self:SetHeat(math.Clamp(self:GetHeat() + self.HeatingRate / self.FireRate, 0, self.MaxHeat))
end

-- ───────────────────────────────────────────────────────────────────────────────
function ENT:TryFindTarget()
    local t = CurTime()
    if self.NextTargetSearch > t then
        if self:CanEngage(self.Target) then return self.Target end
        return nil
    end
    self.NextTargetSearch = t + SEARCH_INTERVAL
    local selfPos = self:GetPos()
    local best, bestDist = nil, math.huge
    for _, ent in pairs(ents.FindInSphere(selfPos, self.TargetingRadius)) do
        if self:CanEngage(ent) then
            local d = ent:GetPos():Distance(selfPos)
            if d < bestDist then best = ent ; bestDist = d end
        end
    end
    return best
end

function ENT:CanEngage(ent)
    if not IsValid(ent) or ent == self then return false end
    if ent:IsNPC() then
        if ent:Health() <= 0 then return false end
        if COMBINE_FRIENDLY[ent:GetClass()] then return false end
    elseif ent:IsPlayer() then
        if not ent:Alive() then return false end
    else
        return false
    end
    return self:CanSeeTarget(ent)
end

function ENT:CanSeeTarget(ent)
    if not IsValid(ent) then return false end
    local tp      = self:DetermineTargetAimPoint(ent)
    local selfPos = self:GetPos() + self:GetUp() * HEIGHT_OFFSET
    if tp:Distance(selfPos) > self.TargetingRadius then return false end
    local tr = util.TraceLine({ start = selfPos, endpos = tp, filter = {self, ent}, mask = MASK_SHOT })
    return not tr.Hit
end

function ENT:DetermineTargetAimPoint(ent)
    if not IsValid(ent) then return Vector(0,0,0) end
    if ent:IsPlayer() then return ent:GetShootPos() end
    if ent:IsNPC() then
        local h = ent:OBBMaxs().z - ent:OBBMins().z
        return ent:GetPos() + Vector(0, 0, h * 0.5)
    end
    return ent:LocalToWorld(ent:OBBCenter())
end

function ENT:Engage(target)
    self.Target = target
    self.SearchData.LastKnownPos = self:DetermineTargetAimPoint(target)
    self:SetState(self.STATE_ENGAGING)
    self:EmitSound("npc/turret_floor/active.wav", 65, 100)
end

function ENT:Disengage()
    local t = CurTime()
    self.SearchData.State            = 1
    self.SearchData.NextSearchChange = t + SEARCH_STATE_DUR
    self.SearchData.NextDeEsc        = t + SEARCH_TIMEOUT
    self:SetState(self.STATE_SEARCHING)
    self:EmitSound("npc/turret_floor/ping.wav", 65, 100)
end

function ENT:StandDown()
    self.Target = nil
    self.SearchData.State = 0
    self:SetState(self.STATE_WATCHING)
end

function ENT:GetTargetAimOffset(point)
    if not point then return 0, 0 end
    local selfPos = self:GetPos() + self:GetUp() * HEIGHT_OFFSET
    local targAng = self:WorldToLocalAngles((point - selfPos):Angle())
    return -self:GetAimPitch() - targAng.p, self:GetAimYaw() - targAng.y
end

function ENT:Turn(pitch, yaw)
    local dt = THINK_DT
    local tp = math.Clamp(pitch, -self.TurnSpeed * dt / 8, self.TurnSpeed * dt / 8)
    local ty = math.Clamp(yaw,   -self.TurnSpeed * dt / 4, self.TurnSpeed * dt / 4)
    self:Point(self:GetAimPitch() + tp, self:GetAimYaw() - ty)
end

function ENT:ReturnToForward()
    local y, p = self:GetAimYaw(), self:GetAimPitch()
    if y == 0 and p == 0 then return end
    local dt = THINK_DT
    local tp = math.Clamp(-p, -self.TurnSpeed * dt / 8, self.TurnSpeed * dt / 8)
    local ty = math.Clamp( y, -self.TurnSpeed * dt / 4, self.TurnSpeed * dt / 4)
    self:Point(p + tp, y - ty)
end

function ENT:Point(pitch, yaw)
    if pitch then self:SetAimPitch(math.Clamp(pitch, self.GunPitchMin, self.GunPitchMax)) end
    if yaw then
        if yaw >  180 then yaw = yaw - 360 end
        if yaw < -180 then yaw = yaw + 360 end
        self:SetAimYaw(math.Clamp(yaw, self.GunYawMin, self.GunYawMax))
    end
end

function ENT:OnTakeDamage(dmginfo)
    if self:GetState() == self.STATE_BROKEN then return end
    local hp = self:GetHP() - dmginfo:GetDamage()
    self:SetHP(hp)
    if hp <= 0 then self:Break() end
end

function ENT:Break()
    self:SetState(self.STATE_BROKEN)
    self:EmitSound("npc/turret_floor/die.wav", 75, 100)
    local fx = EffectData(); fx:SetOrigin(self:GetPos()); fx:SetMagnitude(2); fx:SetScale(1)
    util.Effect("Explosion", fx)
    timer.Simple(1, function() if IsValid(self) then self:Remove() end end)
end
