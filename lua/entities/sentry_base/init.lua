-- sentry_base/init.lua
-- Full AI brain shared by all 48 re-skin sentries.
-- Children only need to set their config fields in shared.lua and AddCSLuaFile.

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- ── Faction table: these classes are never attacked ─────────────────────────
local COMBINE_FRIENDLY = {
    npc_combine_s             = true,
    npc_combine_prison_guard  = true,
    npc_metropolice           = true,
    npc_manhack               = true,
    npc_helicopter            = true,
    npc_combinegunship        = true,
    npc_strider               = true,
    npc_rollermine            = true,
    npc_cscanner              = true,
    npc_clawscanner           = true,
    npc_turret_floor          = true,
    npc_turret_ceiling        = true,
    npc_turret_ground         = true,
    combine_mine              = true,
}

-- Internal constants (not overridable, same for all sentries)
local THINK_RATE              = 0.1
local FAST_THINK_RATE         = 0.02
local SEARCH_STATE_DURATION   = 2
local SEARCH_TIMEOUT          = 5
local TARGET_SEARCH_INTERVAL  = 0.5
local IDLE_SCAN_DELAY_MIN     = 3
local IDLE_SCAN_DELAY_MAX     = 6
local IDLE_HOLD_TIME_MIN      = 1
local IDLE_HOLD_TIME_MAX      = 2
local IDLE_YAW_RANGE          = 40
local IDLE_PITCH_RANGE        = 15
local BARREL_SPIN_THRESHOLD   = 0.85
local COOLING_RATE            = 5
local HEATING_RATE_BASE       = 8
local MAX_HEAT                = 100
local OVERHEAT_THRESHOLD      = 90
local COOLDOWN_THRESHOLD      = 45
-- ────────────────────────────────────────────────────────────────────────────

function ENT:Initialize()
    self:SetModel(self.SentryModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(self.SentryMass)
    end
    self:InitializeStats()
    self:InitializeAI()
    self:SetState(self.STATE_WATCHING)
    self:EmitSound("npc/turret_floor/active.wav", 65, 100)
end

function ENT:InitializeStats()
    self:SetHP(self.SentryHealth)
    self:SetAimPitch(0)
    self:SetAimYaw(0)
    self:SetHeat(0)
    self:SetBarrelSpin(0)
end

function ENT:InitializeAI()
    self.Target           = nil
    self.NextFire         = 0
    self.Firing           = false
    self.BarrelSpinTarget = 0
    self.NextIdleLook     = 0
    self.IdleTargetYaw    = nil
    self.IdleTargetPitch  = nil
    self.IdleHoldUntil    = nil
    self.IdleScanPhase    = nil
    self.NextTargetSearch = 0
    self.SearchData = {
        LastKnownTarg    = nil,
        LastKnownPos     = nil,
        LastKnownVel     = nil,
        NextDeEsc        = 0,
        NextSearchChange = 0,
        State            = 0,
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
    self:NextThink(time + FAST_THINK_RATE)
    return true
end

function ENT:UpdateHeat()
    local heat = self:GetHeat()
    if heat > 0 then
        self:SetHeat(math.Clamp(heat - COOLING_RATE * THINK_RATE, 0, MAX_HEAT))
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
    if     state == self.STATE_BROKEN or state == self.STATE_OFF then self:HandleInactiveState()
    elseif state == self.STATE_OVERHEATED  then self:HandleOverheatedState()
    elseif state == self.STATE_WATCHING    then self:HandleWatchingState(time)
    elseif state == self.STATE_SEARCHING   then self:HandleSearchingState(time)
    elseif state == self.STATE_ENGAGING    then self:HandleEngagingState()
    end
end

function ENT:HandleInactiveState()
    self.Firing = false
    self.BarrelSpinTarget = 0
end

function ENT:HandleOverheatedState()
    self.Firing = false
    self.BarrelSpinTarget = 0
    if self:GetHeat() < COOLDOWN_THRESHOLD then
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
    if self:CanEngage(self.Target) then self:Engage(self.Target) return end
    local target = self:TryFindTarget()
    if IsValid(target) then self:Engage(target) return end
    if self.SearchData.State == 1 and self.SearchData.LastKnownPos then
        local needPitch, needYaw = self:GetTargetAimOffset(self.SearchData.LastKnownPos)
        if needPitch or needYaw then self:Turn(needPitch, needYaw) end
    end
    if self.SearchData.NextSearchChange < time then
        self.SearchData.NextSearchChange = time + SEARCH_STATE_DURATION
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
            self.Firing = self:GetBarrelSpin() > BARREL_SPIN_THRESHOLD
        else
            self.Firing = false
            self.BarrelSpinTarget = 0
        end
    else
        local target = self:TryFindTarget()
        if target then self:Engage(target) else self:Disengage() end
    end
end

function ENT:PerformIdleScan(time)
    if not self.IdleScanPhase then
        self.IdleScanPhase = "centered"
        self.NextIdleLook  = time + math.Rand(IDLE_SCAN_DELAY_MIN, IDLE_SCAN_DELAY_MAX)
    end
    local curYaw   = self:GetAimYaw()
    local curPitch = self:GetAimPitch()
    if self.IdleScanPhase == "centered" then
        if time > self.NextIdleLook then
            self.IdleTargetYaw   = math.Rand(-IDLE_YAW_RANGE,   IDLE_YAW_RANGE)
            self.IdleTargetPitch = math.Rand(-IDLE_PITCH_RANGE, IDLE_PITCH_RANGE)
            self.IdleScanPhase   = "scanning"
        elseif math.abs(curYaw) > 1 or math.abs(curPitch) > 1 then
            self:ReturnToForward()
        end
    elseif self.IdleScanPhase == "scanning" then
        local needYaw   = curYaw - self.IdleTargetYaw
        local needPitch = -curPitch - self.IdleTargetPitch
        if math.abs(needYaw) > 2 or math.abs(needPitch) > 2 then
            self:Turn(needPitch, needYaw)
        else
            self.IdleScanPhase = "holding"
            self.IdleHoldUntil = time + math.Rand(IDLE_HOLD_TIME_MIN, IDLE_HOLD_TIME_MAX)
        end
    elseif self.IdleScanPhase == "holding" then
        if time > self.IdleHoldUntil then self.IdleScanPhase = "returning" end
    elseif self.IdleScanPhase == "returning" then
        if math.abs(curYaw) > 1 or math.abs(curPitch) > 1 then
            self:ReturnToForward()
        else
            self.IdleScanPhase = "centered"
            self.NextIdleLook  = time + math.Rand(IDLE_SCAN_DELAY_MIN, IDLE_SCAN_DELAY_MAX)
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
    if not self.Firing then return end
    if self.NextFire >= time then return end
    local heat = self:GetHeat()
    if heat >= OVERHEAT_THRESHOLD then
        self:SetState(self.STATE_OVERHEATED)
        self:EmitSound("weapons/ar2/ar2_empty.wav", 70, 100)
        return
    end
    self.NextFire = time + self.FireInterval
    if self.FireType == "ROCKET" then
        self:FireRocket()
    else
        self:FireBulletRound()
    end
end

-- ── Bullet fire ─────────────────────────────────────────────────────────────
function ENT:FireBulletRound()
    local muzzlePos, aimAng = self:GetMuzzlePositionAndAngle()
    local shootDir = (aimAng:Forward() + VectorRand() * self.BulletInaccuracy):GetNormalized()
    self:FireBullets({
        Attacker     = self,
        Damage       = self.BulletDamage,
        Force        = self.BulletDamage * 2,
        Num          = self.BulletNum,
        Tracer       = 0,
        Dir          = shootDir,
        Spread       = Vector(0, 0, 0),
        Src          = muzzlePos,
        IgnoreEntity = self,
    })
    local tr = util.TraceLine({ start = muzzlePos, endpos = muzzlePos + shootDir * 10000, filter = self, mask = MASK_SHOT })
    local td = EffectData() td:SetStart(muzzlePos) td:SetOrigin(tr.HitPos) td:SetScale(5000)
    util.Effect("Tracer", td)
    local ed = EffectData() ed:SetOrigin(muzzlePos) ed:SetNormal(shootDir) ed:SetAngles(aimAng)
    util.Effect("MuzzleEffect", ed)
    ParticleEffect("muzzleflash_pistol", muzzlePos, aimAng, self)
    self:EmitSound(self.BulletSound, 75, math.random(95, 105))
    self:AddHeat()
end

-- ── Rocket fire ─────────────────────────────────────────────────────────────
function ENT:FireRocket()
    local muzzlePos, aimAng = self:GetMuzzlePositionAndAngle()
    local rocket = ents.Create("rpg_rocket")
    if not IsValid(rocket) then return end
    rocket:SetPos(muzzlePos)
    rocket:SetAngles(aimAng)
    rocket:SetOwner(self)
    rocket:Spawn()
    rocket:Activate()
    local phys = rocket:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(aimAng:Forward() * self.RocketSpeed)
    end
    -- Override damage on impact via a hook stored per rocket
    local dmg  = self.RocketDamage
    local rad  = self.RocketRadius
    local attk = self
    rocket:CallOnRemove("SentryRocketHit", function(r)
        if not IsValid(r) then return end
        util.BlastDamage(attk, attk, r:GetPos(), rad, dmg)
    end)
    self:EmitSound(self.RocketSound, 80, math.random(95, 105))
    self:AddHeat()
end

function ENT:AddHeat()
    local newHeat = math.Clamp(self:GetHeat() + HEATING_RATE_BASE / (1 / self.FireInterval), 0, MAX_HEAT)
    self:SetHeat(newHeat)
end

-- ── Target search ────────────────────────────────────────────────────────────
function ENT:TryFindTarget()
    local time = CurTime()
    if self.NextTargetSearch > time then
        if self:CanEngage(self.Target) then return self.Target end
        return nil
    end
    self.NextTargetSearch = time + TARGET_SEARCH_INTERVAL
    local selfPos = self:GetPos()
    local best, bestDist = nil, math.huge
    for _, ent in pairs(ents.FindInSphere(selfPos, self.TurretRadius)) do
        if self:CanEngage(ent) then
            local dist = ent:GetPos():Distance(selfPos)
            if dist < bestDist then best = ent bestDist = dist end
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
    local targPos = self:DetermineTargetAimPoint(ent)
    local selfPos = self:GetPos() + self:GetUp() * self.HeightOffset
    if targPos:Distance(selfPos) > self.TurretRadius then return false end
    -- Check yaw limits for non-360 turrets
    if not (self.YawMin == -180 and self.YawMax == 180) then
        local toTarget = (targPos - selfPos):GetNormalized()
        local localAng = self:WorldToLocalAngles(toTarget:Angle())
        local relYaw   = localAng.y
        if relYaw > 180 then relYaw = relYaw - 360 end
        if relYaw < -180 then relYaw = relYaw + 360 end
        if relYaw < self.YawMin or relYaw > self.YawMax then return false end
    end
    local tr = util.TraceLine({ start = selfPos, endpos = targPos, filter = {self, ent}, mask = MASK_SHOT })
    return not tr.Hit
end

function ENT:DetermineTargetAimPoint(ent)
    if not IsValid(ent) then return nil end
    if ent:IsPlayer() then
        return ent:GetShootPos()
    elseif ent:IsNPC() then
        local h = ent:OBBMaxs().z - ent:OBBMins().z
        return ent:GetPos() + Vector(0, 0, h * 0.5)
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
    self.SearchData.State            = 1
    self.SearchData.NextSearchChange = time + SEARCH_STATE_DURATION
    self.SearchData.NextDeEsc        = time + SEARCH_TIMEOUT
    self:SetState(self.STATE_SEARCHING)
    self:EmitSound("npc/turret_floor/ping.wav", 65, 100)
end

function ENT:StandDown()
    self.Target = nil
    self.SearchData.State = 0
    self:SetState(self.STATE_WATCHING)
end

function ENT:GetMuzzlePositionAndAngle()
    local selfPos = self:GetPos()
    local up      = self:GetUp()
    local selfAng = self:GetAngles()
    local aimAng  = Angle(selfAng)
    aimAng:RotateAroundAxis(up, self:GetAimYaw())
    aimAng:RotateAroundAxis(aimAng:Right(), self:GetAimPitch())
    if self.BoneMuzzle then
        local muzzleBone = self:LookupBone(self.BoneMuzzle)
        if muzzleBone then
            local boneMatrix = self:GetBoneMatrix(muzzleBone)
            if boneMatrix then
                return boneMatrix:GetTranslation(), aimAng
            end
        end
    end
    local fb = self.MuzzleFallback
    local muzzlePos = selfPos
        + aimAng:Forward() * fb.x
        + aimAng:Right()   * fb.y
        + aimAng:Up()      * fb.z
    return muzzlePos, aimAng
end

function ENT:GetTargetAimOffset(point)
    if not point then return 0, 0 end
    local selfPos = self:GetPos() + self:GetUp() * self.HeightOffset
    local targAng = self:WorldToLocalAngles((point - selfPos):Angle())
    return -self:GetAimPitch() - targAng.p, self:GetAimYaw() - targAng.y
end

function ENT:Turn(pitch, yaw)
    local dt   = THINK_RATE
    local spd  = self.TurnSpeed
    local turnP = math.Clamp(pitch, -spd * dt / 8, spd * dt / 8)
    local turnY = math.Clamp(yaw,   -spd * dt / 4, spd * dt / 4)
    self:Point(self:GetAimPitch() + turnP, self:GetAimYaw() - turnY)
    if math.abs(turnP) > 0.1 or math.abs(turnY) > 0.1 then
        self:EmitSound("npc/turret_floor/ping.wav", 50, math.random(95, 105))
    end
end

function ENT:ReturnToForward()
    local x, y = self:GetAimYaw(), self:GetAimPitch()
    if x == 0 and y == 0 then return end
    local dt   = THINK_RATE
    local spd  = self.TurnSpeed
    local turnP = math.Clamp(-y, -spd * dt / 8, spd * dt / 8)
    local turnY = math.Clamp( x, -spd * dt / 4, spd * dt / 4)
    self:Point(y + turnP, x - turnY)
end

function ENT:Point(pitch, yaw)
    pitch = pitch and math.Clamp(pitch, self.PitchMin, self.PitchMax) or pitch
    if yaw then
        if yaw >  180 then yaw = yaw - 360 end
        if yaw < -180 then yaw = yaw + 360 end
        if not (self.YawMin == -180 and self.YawMax == 180) then
            yaw = math.Clamp(yaw, self.YawMin, self.YawMax)
        end
    end
    if pitch then self:SetAimPitch(pitch) end
    if yaw   then self:SetAimYaw(yaw) end
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
    local fx = EffectData() fx:SetOrigin(self:GetPos()) fx:SetMagnitude(2) fx:SetScale(1)
    util.Effect("Explosion", fx)
    timer.Simple(1, function() if IsValid(self) then self:Remove() end end)
end
