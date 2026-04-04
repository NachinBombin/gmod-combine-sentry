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
    self.CurAimPitch  = Lerp(ft * INTERP_SPEED, self.CurAimPitch, self:GetAimPitch())
    self.CurAimYaw    = Lerp(ft * INTERP_SPEED, self.CurAimYaw,   self:GetAimYaw())
    local spinSpeed   = self:GetBarrelSpin()
    self.CurBarrelRot = (self.CurBarrelRot + spinSpeed * 360 * ft * BARREL_SPIN_MULT) % 360
    self:SetNextClientThink(CurTime())
    return true
end

function ENT:Draw()
    self:DrawModel()

    local yawBone = self:LookupBone(self.GunPivotBone)
    if yawBone then
        self:ManipulateBoneAngles(yawBone, Angle(0, self.CurAimYaw, 0))
    end

    local pitchBone = self:LookupBone(self.GunMuzzleBone)
    if pitchBone then
        self:ManipulateBoneAngles(pitchBone, Angle(-self.CurAimPitch, 0, 0))
    end

    if self.GunBarrelBone ~= "" then
        local barrelBone = self:LookupBone(self.GunBarrelBone)
        if barrelBone then
            self:ManipulateBoneAngles(barrelBone, Angle(self.CurBarrelRot, 0, 0))
        end
    end

    self:DrawLaser()
end

function ENT:DrawLaser()
    local muzzleBone = self:LookupBone(self.GunMuzzleBone)
    local laserPos, laserDir

    if muzzleBone then
        local bm = self:GetBoneMatrix(muzzleBone)
        if bm then
            laserPos = bm:GetTranslation()
            laserDir = bm:GetAngles():Forward()
        end
    end

    if not laserPos then return end

    local tr = util.TraceLine({ start = laserPos, endpos = laserPos + laserDir * 6000, filter = self })
    local col = self:GetLaserColor()

    render.SetMaterial(Material("effects/laser1"))
    render.DrawBeam(laserPos, tr.HitPos, LASER_WIDTH, 0, 1, col)

    if tr.Hit then
        local dotSize = LASER_DOT_SIZE
        if self:GetState() == self.STATE_ENGAGING then
            dotSize = dotSize + math.sin(CurTime() * 10) * 2
        end
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(tr.HitPos, dotSize, dotSize, col)
        render.DrawSprite(tr.HitPos, dotSize * LASER_GLOW_MULT, dotSize * LASER_GLOW_MULT, ColorAlpha(col, 50))
    end
end

function ENT:GetLaserColor()
    local s = self:GetState()
    if     s == self.STATE_ENGAGING   then return Color(255,   0,   0, 200)
    elseif s == self.STATE_SEARCHING  then return Color(255, 255,   0, 200)
    elseif s == self.STATE_WATCHING   then return Color(  0, 255,   0, 200)
    elseif s == self.STATE_OVERHEATED then
        local f = math.abs(math.sin(CurTime() * 5))
        return Color(255, 128 * f, 0, 200)
    else
        return Color(100, 100, 100, 100)
    end
end

function ENT:DrawTranslucent() self:Draw() end
