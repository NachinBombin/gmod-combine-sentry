AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- ─────────────────────────────────────────────
-- Combine Sentry – Alliance Logic
--   Friends  : Combine faction NPCs (never attacked)
--   Enemies  : Everyone else – rebels, citizens, players
-- No whitelist, no owner, no UI – pure faction check.
-- ─────────────────────────────────────────────

local COMBINE_FRIENDLY = {
    npc_combine_s         = true,
    npc_combine_prison_guard = true,
    npc_metropolice       = true,
    npc_manhack           = true,
    npc_helicopter        = true,
    npc_combinegunship    = true,
    npc_strider           = true,
    npc_rollermine        = true,
    npc_cscanner          = true,
    npc_clawscanner       = true,
    npc_turret_floor      = true,
    npc_turret_ceiling    = true,
    npc_turret_ground     = true,
    combine_mine          = true,
}

local CONFIG = {
    MODEL                = "models/codbo6/other/sentry.mdl",
    MASS                 = 150,
    MAX_HEALTH           = 500,
    TURN_SPEED           = 60,
    TARGETING_RADIUS     = 1500,
    FIRE_RATE            = 15,
    DAMAGE               = 15,
    SEARCH_SPEED         = 0.5,
    TARGET_LOCK_TIME     = 1,
    COOLING_RATE         = 5,
    HEATING_RATE         = 8,
    MAX_HEAT             = 100,
    OVERHEAT_THRESHOLD   = 90,
    COOLDOWN_THRESHOLD   = 45,
    HEIGHT_OFFSET        = 55,
    MUZZLE_FALLBACK      = Vector(34, 0, 55),
    INACCURACY           = 0.02,
    BARREL_SPIN_THRESHOLD = 0.85,
    IDLE_SCAN_DELAY_MIN  = 3,
    IDLE_SCAN_DELAY_MAX  = 6,
    IDLE_HOLD_TIME_MIN   = 1,
    IDLE_HOLD_TIME_MAX   = 2,
    IDLE_YAW_RANGE       = 40,
    IDLE_PITCH_RANGE     = 15,
    THINK_RATE           = 0.1,
    FAST_THINK_RATE      = 0.02,
    TARGET_SEARCH_INTERVAL = 0.5,
    SEARCH_STATE_DURATION  = 2,
    SEARCH_TIMEOUT         = 5,
}

function ENT:Initialize()
    self:SetModel(CONFIG.MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(CONFIG.MASS)
    end
    self:InitializeStats()
    self:InitializeAI()
    self:SetState(self.STATE_WATCHING)
    self:EmitSound("npc/turret_floor/active.wav", 65, 100)
end

function ENT:InitializeStats()
    self:SetHP(CONFIG.MAX_HEALTH)
    self:SetAimPitch(0)
    self:SetAimYaw(0)
    self:SetHeat(0)
    self:SetBarrelSpin(0)
    self.MaxHealth         = CONFIG.MAX_HEALTH
    self.TurnSpeed         = CONFIG.TURN_SPEED
    self.TargetingRadius   = CONFIG.TARGETING_RADIUS
    self.FireRate          = CONFIG.FIRE_RATE
    self.Damage            = CONFIG.DAMAGE
    self.SearchSpeed       = CONFIG.SEARCH_SPEED
    self.TargetLockTime    = CONFIG.TARGET_LOCK_TIME
    self.CoolingRate       = CONFIG.COOLING_RATE
    self.HeatingRate       = CONFIG.HEATING_RATE
    self.MaxHeat           = CONFIG.MAX_HEAT
    self.OverheatThreshold = CONFIG.OVERHEAT_THRESHOLD
    self.CooldownThreshold = CONFIG.COOLDOWN_THRESHOLD
end

function ENT:InitializeAI()
    self.Target           = nil
    self.NextFire         = 0
    self.NextThink        = 0
    self.NextTargetSearch = 0
    self.Firing           = false
    self.BarrelSpinTarget = 0
    self.NextIdleLook     = 0
    self.IdleTargetYaw    = nil
    self.IdleTargetPitch  = nil
    self.IdleHoldUntil    = nil
    self.IdleScanPhase    = nil
    self.SearchData = {
        LastKnownTarg   = nil,
        LastKnownPos    = nil,
        LastKnownVel    = nil,
        NextDeEsc       = 0,
        NextSearchChange = 0,
        State           = 0,
    }
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 10)
    ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
    ent:Spawn()
    ent:Activate()
    return ent
end

function ENT:Think()
    local time = CurTime()
    self:UpdateHeat()
    self:UpdateBarrelSpin()
    self:UpdateState(time)
    self:HandleFiring(time)
    self:NextThink(time + CONFIG.FAST_THINK_RATE)
    return true
end

function ENT:UpdateHeat()
    local heat = self:GetHeat()
    if heat > 0 then
        heat = math.Clamp(heat - self.CoolingRate * CONFIG.THINK_RATE, 0, self.MaxHeat)
        self:SetHeat(heat)
    end
end

function ENT:UpdateBarrelSpin()
    local cur    = self:GetBarrelSpin()
    local target = self.BarrelSpinTarget
    if cur ~= target then
        local accel = target > cur and 0.15 or 0.1
        self:SetBarrelSpin(math.Clamp(cur + (target - cur) * accel, 0, 1))
    end
end

function ENT:UpdateState(time)
    local state = self:GetState()
    if state == self.STATE_BROKEN or state == self.STATE_OFF then
        self:HandleInactiveState()
    elseif state == self.STATE_OVERHEATED then
        self:HandleOverheatedState()
    elseif state == self.STATE_WATCHING then
        self:HandleWatchingState(time)
    elseif state == self.STATE_SEARCHING then
        self:HandleSearchingState(time)
    elseif state == self.STATE_ENGAGING then
        self:HandleEngagingState()
    end
end

function ENT:HandleInactiveState()
    self.Firing = false
    self.BarrelSpinTarget = 0
end

function ENT:HandleOverheatedState()
    self.Firing = false
    self.BarrelSpinTarget = 0
    if self:GetHeat() < self.CooldownThreshold then
        self:SetState(self.STATE_WATCHING)
    end
end

function ENT:HandleWatchingState(time)
    self.Firing = false
    self.BarrelSpinTarget = 0
    local target = self:TryFindTarget()
    if target then
        self:Engage(target)
        self:ClearIdleScan()
    else
        self:PerformIdleScan(time)
    end
end

function ENT:HandleSearchingState(time)
    self.Firing = false
    self.BarrelSpinTarget = 0
    if self:CanEngage(self.Target) then
        self:Engage(self.Target)
        return
    end
    local target = self:TryFindTarget()
    if IsValid(target) then
        self:Engage(target)
        return
    end
    if self.SearchData.State == 1 and self.SearchData.LastKnownPos then
        local needPitch, needYaw = self:GetTargetAimOffset(self.SearchData.LastKnownPos)
        if needPitch or needYaw then self:Turn(needPitch, needYaw) end
    end
    if self.SearchData.NextSearchChange < time then
        self.SearchData.NextSearchChange = time + CONFIG.SEARCH_STATE_DURATION
        self.SearchData.State = self.SearchData.State + 1
        if self.SearchData.State >= 2 then self:StandDown() end
    end
    if self.SearchData.NextDeEsc < time then self:StandDown() end
end

function ENT:HandleEngagingState()
    if self:CanEngage(self.Target) then
        local targPos = self:DetermineTargetAimPoint(self.Target)
        self.SearchData.LastKnownPos = targPos
        self.SearchData.LastKnownVel = self:GetVel(self.Target)
        local needPitch, needYaw = self:GetTargetAimOffset(targPos)
        local turnP, turnY = math.abs(needPitch or 0), math.abs(needYaw or 0)
        if turnP > 0 or turnY > 0 then self:Turn(needPitch, needYaw) end
        if turnP < 3 and turnY < 3 then
            self.BarrelSpinTarget = 1.0
            self.Firing = self:GetBarrelSpin() > CONFIG.BARREL_SPIN_THRESHOLD
        else
            self.Firing = false
            self.BarrelSpinTarget = 0
        end
    else
        local target = self:TryFindTarget()
        if target then
            self:Engage(target)
        else
            self:Disengage()
        end
    end
end

function ENT:PerformIdleScan(time)
    if not self.IdleScanPhase then
        self.IdleScanPhase = "centered"
        self.NextIdleLook  = time + math.Rand(CONFIG.IDLE_SCAN_DELAY_MIN, CONFIG.IDLE_SCAN_DELAY_MAX)
    end
    local curYaw   = self:GetAimYaw()
    local curPitch = self:GetAimPitch()
    if self.IdleScanPhase == "centered" then
        if time > self.NextIdleLook then
            self.IdleTargetYaw   = math.Rand(-CONFIG.IDLE_YAW_RANGE,   CONFIG.IDLE_YAW_RANGE)
            self.IdleTargetPitch = math.Rand(-CONFIG.IDLE_PITCH_RANGE, CONFIG.IDLE_PITCH_RANGE)
            self.IdleScanPhase   = "scanning"
        else
            if math.abs(curYaw) > 1 or math.abs(curPitch) > 1 then self:ReturnToForward() end
        end
    elseif self.IdleScanPhase == "scanning" then
        local needYaw   = curYaw - self.IdleTargetYaw
        local needPitch = -curPitch - self.IdleTargetPitch
        if math.abs(needYaw) > 2 or math.abs(needPitch) > 2 then
            self:Turn(needPitch, needYaw)
        else
            self.IdleScanPhase = "holding"
            self.IdleHoldUntil = time + math.Rand(CONFIG.IDLE_HOLD_TIME_MIN, CONFIG.IDLE_HOLD_TIME_MAX)
        end
    elseif self.IdleScanPhase == "holding" then
        if time > self.IdleHoldUntil then self.IdleScanPhase = "returning" end
    elseif self.IdleScanPhase == "returning" then
        if math.abs(curYaw) > 1 or math.abs(curPitch) > 1 then
            self:ReturnToForward()
        else
            self.IdleScanPhase = "centered"
            self.NextIdleLook  = time + math.Rand(CONFIG.IDLE_SCAN_DELAY_MIN, CONFIG.IDLE_SCAN_DELAY_MAX)
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

function ENT:HandleFiring(time)
    if self.Firing and self.NextFire < time then
        local heat = self:GetHeat()
        if heat < self.OverheatThreshold then
            self.NextFire = time + (1 / self.FireRate)
            self:FireWeapon()
        else
            self:SetState(self.STATE_OVERHEATED)
            self:EmitSound("weapons/ar2/ar2_empty.wav", 70, 100)
        end
    end
end

function ENT:TryFindTarget()
    local time = CurTime()
    if self.NextTargetSearch > time then
        if self:CanEngage(self.Target) then return self.Target end
        return nil
    end
    self.NextTargetSearch = time + (CONFIG.TARGET_SEARCH_INTERVAL / self.SearchSpeed)
    local selfPos = self:GetPos()
    local objects = ents.FindInSphere(selfPos, self.TargetingRadius)
    local best, bestDist = nil, math.huge
    for _, ent in pairs(objects) do
        if self:CanEngage(ent) then
            local dist = ent:GetPos():Distance(selfPos)
            if dist < bestDist then
                best     = ent
                bestDist = dist
            end
        end
    end
    return best
end

--[[
    CanEngage – The only function that changes vs. nsentry.

    Rules:
      * Combine NPCs (COMBINE_FRIENDLY table) -> never attacked.
      * Any other alive NPC                   -> attacked.
      * Any alive player                      -> always attacked (no whitelist).
      * Anything else (props, etc.)           -> ignored.
]]
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
    local targPos = self:DetermineTargetAimPoint(ent)
    local selfPos = self:GetPos() + self:GetUp() * CONFIG.HEIGHT_OFFSET
    if targPos:Distance(selfPos) > self.TargetingRadius then return false end
    local tr = util.TraceLine({
        start  = selfPos,
        endpos = targPos,
        filter = {self, ent},
        mask   = MASK_SHOT,
    })
    return not tr.Hit
end

function ENT:DetermineTargetAimPoint(ent)
    if not IsValid(ent) then return nil end
    if ent:IsPlayer() then
        return ent:GetShootPos()
    elseif ent:IsNPC() then
        local height = ent:OBBMaxs().z - ent:OBBMins().z
        return ent:GetPos() + Vector(0, 0, height * 0.5)
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

function ENT:GetVel(ent)
    if not IsValid(ent) then return Vector(0, 0, 0) end
    local phys = ent:GetPhysicsObject()
    return IsValid(phys) and phys:GetVelocity() or ent:GetVelocity()
end

function ENT:Engage(target)
    self.Target = target
    self.SearchData.LastKnownTarg = target
    self.SearchData.LastKnownPos  = self:DetermineTargetAimPoint(target)
    self.SearchData.LastKnownVel  = self:GetVel(target)
    self:SetState(self.STATE_ENGAGING)
    self:EmitSound("npc/turret_floor/active.wav", 65, 100)
end

function ENT:Disengage()
    local time = CurTime()
    self.SearchData.State         = 1
    self.SearchData.NextSearchChange = time + CONFIG.SEARCH_STATE_DURATION
    self.SearchData.NextDeEsc     = time + CONFIG.SEARCH_TIMEOUT
    self:SetState(self.STATE_SEARCHING)
    self:EmitSound("npc/turret_floor/ping.wav", 65, 100)
end

function ENT:StandDown()
    self.Target = nil
    self.SearchData.State = 0
    self:SetState(self.STATE_WATCHING)
end

function ENT:GetMuzzlePositionAndAngle()
    local baseUpperBone = self:LookupBone("sentry_base_upper")
    local muzzleBone    = self:LookupBone("sentry_barrels_extrabone")
    if baseUpperBone and muzzleBone then
        local baseUpperMatrix = self:GetBoneMatrix(baseUpperBone)
        local muzzleMatrix    = self:GetBoneMatrix(muzzleBone)
        if baseUpperMatrix and muzzleMatrix then
            local pivotWorldPos  = baseUpperMatrix:GetTranslation()
            local muzzleWorldPos = muzzleMatrix:GetTranslation()
            local pivotToMuzzle  = self:WorldToLocal(muzzleWorldPos) - self:WorldToLocal(pivotWorldPos)
            local pivotLocalPos  = self:WorldToLocal(pivotWorldPos)
            local selfPos = self:GetPos()
            local selfAng = self:GetAngles()
            local up      = self:GetUp()
            local yawAng  = Angle(selfAng)
            yawAng:RotateAroundAxis(up, self:GetAimYaw())
            local pivotPos = selfPos
                + yawAng:Forward() * pivotLocalPos.x
                + yawAng:Right()   * pivotLocalPos.y
                + yawAng:Up()      * pivotLocalPos.z
            local aimAng = Angle(yawAng)
            aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
            local muzzlePos = pivotPos
                + aimAng:Forward() * pivotToMuzzle.x
                + aimAng:Right()   * pivotToMuzzle.y
                + aimAng:Up()      * pivotToMuzzle.z
            return muzzlePos, aimAng
        end
    end
    if muzzleBone then
        local boneMatrix = self:GetBoneMatrix(muzzleBone)
        if boneMatrix then
            local boneLocalPos = self:WorldToLocal(boneMatrix:GetTranslation())
            local selfPos = self:GetPos()
            local up      = self:GetUp()
            local aimAng  = Angle(self:GetAngles())
            aimAng:RotateAroundAxis(up, self:GetAimYaw())
            aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
            local muzzlePos = selfPos
                + aimAng:Forward() * boneLocalPos.x
                + aimAng:Right()   * boneLocalPos.y
                + aimAng:Up()      * boneLocalPos.z
            return muzzlePos, aimAng
        end
    end
    local selfPos = self:GetPos()
    local up      = self:GetUp()
    local aimAng  = Angle(self:GetAngles())
    aimAng:RotateAroundAxis(up, self:GetAimYaw())
    aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
    local muzzlePos = selfPos
        + aimAng:Forward() * CONFIG.MUZZLE_FALLBACK.x
        + aimAng:Right()   * CONFIG.MUZZLE_FALLBACK.y
        + aimAng:Up()      * CONFIG.MUZZLE_FALLBACK.z
    return muzzlePos, aimAng
end

function ENT:FireWeapon()
    local muzzlePos, aimAng = self:GetMuzzlePositionAndAngle()
    local shootDir = (aimAng:Forward() + VectorRand() * CONFIG.INACCURACY):GetNormalized()
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
    local tr = util.TraceLine({
        start  = muzzlePos,
        endpos = muzzlePos + shootDir * 10000,
        filter = self,
        mask   = MASK_SHOT,
    })
    local tracerData = EffectData()
    tracerData:SetStart(muzzlePos)
    tracerData:SetOrigin(tr.HitPos)
    tracerData:SetScale(5000)
    util.Effect("Tracer", tracerData)
    local effectData = EffectData()
    effectData:SetOrigin(muzzlePos)
    effectData:SetNormal(shootDir)
    effectData:SetAngles(aimAng)
    util.Effect("MuzzleEffect", effectData)
    ParticleEffect("muzzleflash_pistol", muzzlePos, aimAng, self)
    self:EmitSound("weapons/ar2/fire1.wav", 75, math.random(95, 105))
    local newHeat = math.Clamp(self:GetHeat() + self.HeatingRate / self.FireRate, 0, self.MaxHeat)
    self:SetHeat(newHeat)
end

function ENT:GetTargetAimOffset(point)
    if not point then return 0, 0 end
    local selfPos = self:GetPos() + self:GetUp() * CONFIG.HEIGHT_OFFSET
    local targAng = self:WorldToLocalAngles((point - selfPos):Angle())
    return -self:GetAimPitch() - targAng.p, self:GetAimYaw() - targAng.y
end

function ENT:Turn(pitch, yaw)
    local dt = CONFIG.THINK_RATE
    local turnP = math.Clamp(pitch, -self.TurnSpeed * dt / 8, self.TurnSpeed * dt / 8)
    local turnY = math.Clamp(yaw,   -self.TurnSpeed * dt / 4, self.TurnSpeed * dt / 4)
    self:Point(self:GetAimPitch() + turnP, self:GetAimYaw() - turnY)
    if math.abs(turnP) > 0.1 or math.abs(turnY) > 0.1 then
        self:EmitSound("npc/turret_floor/ping.wav", 50, math.random(95, 105))
    end
end

function ENT:ReturnToForward()
    local x, y = self:GetAimYaw(), self:GetAimPitch()
    if x == 0 and y == 0 then return end
    local dt   = CONFIG.THINK_RATE
    local turnP = math.Clamp(-y, -self.TurnSpeed * dt / 8, self.TurnSpeed * dt / 8)
    local turnY = math.Clamp( x, -self.TurnSpeed * dt / 4, self.TurnSpeed * dt / 4)
    self:Point(y + turnP, x - turnY)
end

function ENT:Point(pitch, yaw)
    if pitch then self:SetAimPitch(math.Clamp(pitch, -45, 45)) end
    if yaw   then
        if yaw >  180 then yaw = yaw - 360 end
        if yaw < -180 then yaw = yaw + 360 end
        self:SetAimYaw(math.Clamp(yaw, -180, 180))
    end
end

function ENT:OnTakeDamage(dmginfo)
    if self:GetState() == self.STATE_BROKEN then return end
    local newHP = self:GetHP() - dmginfo:GetDamage()
    self:SetHP(newHP)
    if newHP <= 0 then self:Break() end
end

function ENT:Break()
    self:SetState(self.STATE_BROKEN)
    self:EmitSound("npc/turret_floor/die.wav", 75, 100)
    local fx = EffectData()
    fx:SetOrigin(self:GetPos())
    fx:SetMagnitude(2)
    fx:SetScale(1)
    util.Effect("Explosion", fx)
    timer.Simple(1, function() if IsValid(self) then self:Remove() end end)
end
