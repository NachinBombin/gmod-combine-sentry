-- sentry_base/cl_init.lua
-- Client: bone animation (yaw / pitch / barrel-spin) + laser sight.

include("shared.lua")

local LASER_WIDTH      = 2
local LASER_DOT_SIZE   = 8
local LASER_GLOW_MULT  = 2
local BARREL_SPIN_MULT = 25
local INTERP_SPEED     = 5

function ENT:Initialize()
    self.CurAimPitch  = 0
    self.CurAimYaw    = 0
    self.CurBarrelRot = 0
end

function ENT:Think()
    local ft = FrameTime()
    self.CurAimPitch  = Lerp(ft * INTERP_SPEED, self.CurAimPitch,  self:GetAimPitch())
    self.CurAimYaw    = Lerp(ft * INTERP_SPEED, self.CurAimYaw,    self:GetAimYaw())
    local spinSpeed   = self:GetBarrelSpin()
    self.CurBarrelRot = (self.CurBarrelRot + spinSpeed * 360 * ft * BARREL_SPIN_MULT) % 360
    self:SetNextClientThink(CurTime())
    return true
end

function ENT:Draw()
    self:DrawModel()

    -- Yaw bone
    local yawBone = self.BoneYaw and self:LookupBone(self.BoneYaw)
    if yawBone then
        self:ManipulateBoneAngles(yawBone, Angle(0, self.CurAimYaw, 0))
    end

    -- Pitch bone
    local pitchBone = self.BonePitch and self:LookupBone(self.BonePitch)
    if pitchBone then
        self:ManipulateBoneAngles(pitchBone, Angle(-self.CurAimPitch, 0, 0))
    end

    -- Optional barrel-spin bone
    if self.BoneBarrels then
        local barrelsBone = self:LookupBone(self.BoneBarrels)
        if barrelsBone then
            self:ManipulateBoneAngles(barrelsBone, Angle(self.CurBarrelRot, 0, 0))
        end
    end

    self:DrawLaser()
end

function ENT:DrawLaser()
    if not self.BoneLaser then return end
    local laserBone = self:LookupBone(self.BoneLaser)
    if not laserBone then return end
    local boneMatrix = self:GetBoneMatrix(laserBone)
    if not boneMatrix then return end
    local laserPos = boneMatrix:GetTranslation()
    local laserDir = boneMatrix:GetAngles():Right()
    local tr = util.TraceLine({ start = laserPos, endpos = laserPos + laserDir * 5000, filter = self })
    local laserColor = self:GetLaserColor()
    render.SetMaterial(Material("effects/laser1"))
    render.DrawBeam(laserPos, tr.HitPos, LASER_WIDTH, 0, 1, laserColor)
    if tr.Hit then
        local dotSize = LASER_DOT_SIZE
        if self:GetState() == self.STATE_ENGAGING then
            dotSize = LASER_DOT_SIZE + math.sin(CurTime() * 10) * 2
        end
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(tr.HitPos, dotSize, dotSize, laserColor)
        render.DrawSprite(tr.HitPos, dotSize * LASER_GLOW_MULT, dotSize * LASER_GLOW_MULT, ColorAlpha(laserColor, 50))
    end
end

function ENT:GetLaserColor()
    local state = self:GetState()
    if     state == self.STATE_ENGAGING   then return Color(255,   0,   0, 200)
    elseif state == self.STATE_SEARCHING  then return Color(255, 255,   0, 200)
    elseif state == self.STATE_WATCHING   then return Color(  0, 255,   0, 200)
    elseif state == self.STATE_OVERHEATED then
        return Color(255, 128 * math.abs(math.sin(CurTime() * 5)), 0, 200)
    else
        return Color(100, 100, 100, 100)
    end
end

function ENT:DrawTranslucent() self:Draw() end
