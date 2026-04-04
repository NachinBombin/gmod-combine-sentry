ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PrintName       = "Nachin Sentry Base"
ENT.Author          = "kebinresi"
ENT.Category        = "Nachin Sentries"
ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.GunModel        = "models/error.mdl"
ENT.GunPivotBone    = ""
ENT.GunMuzzleBone   = ""
ENT.GunBarrelBone   = ""
ENT.GunWeaponType   = "hitscan"
ENT.GunFireRate     = 10
ENT.GunDamage       = 15
ENT.GunYawMin       = -180
ENT.GunYawMax       =  180
ENT.GunPitchMin     = -45
ENT.GunPitchMax     =  45
ENT.GunTurnSpeed    =  60
ENT.GunMaxHealth    =  500
ENT.GunRadius       = 1500
ENT.GunShootSound   = "weapons/ar2/fire1.wav"
ENT.GunMuzzleFX     = "MuzzleEffect"
ENT.GunMuzzleFB     = Vector(34, 0, 55)

ENT.STATE_BROKEN     = -1
ENT.STATE_OFF        =  0
ENT.STATE_WATCHING   =  1
ENT.STATE_SEARCHING  =  2
ENT.STATE_ENGAGING   =  3
ENT.STATE_OVERHEATED =  4

function ENT:SetupDataTables()
    self:NetworkVar("Int",   0, "State")
    self:NetworkVar("Int",   1, "HP")
    self:NetworkVar("Float", 0, "AimPitch")
    self:NetworkVar("Float", 1, "AimYaw")
    self:NetworkVar("Float", 2, "Heat")
    self:NetworkVar("Float", 3, "BarrelSpin")
end
