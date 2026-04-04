-- sentry_base/shared.lua
-- Shared base for all auto-sentry re-skins.
-- Children set model, fire config and angle limits; AI lives in init.lua.

ENT.Type               = "anim"
ENT.Base               = "base_anim"
ENT.ScriptedEntityType = "ent"   -- required for GMod to render spawnmenu icons
ENT.PrintName          = "Sentry Base"
ENT.Author             = "kebinresi"
ENT.Category           = "Combine Sentries"
ENT.Spawnable          = false   -- base is not directly spawnable
ENT.AdminSpawnable     = false

-- States (shared with combine_sentry)
ENT.STATE_BROKEN     = -1
ENT.STATE_OFF        =  0
ENT.STATE_WATCHING   =  1
ENT.STATE_SEARCHING  =  2
ENT.STATE_ENGAGING   =  3
ENT.STATE_OVERHEATED =  4

-- ── Child-overridable config defaults ──────────────────────────────────────
-- Model
ENT.SentryModel      = "models/error.mdl"

-- Weapon type: "BULLET" or "ROCKET"
ENT.FireType         = "BULLET"

-- Bullet mode
ENT.BulletDamage     = 15
ENT.BulletNum        = 1
ENT.BulletSound      = "weapons/ar2/fire1.wav"
ENT.BulletInaccuracy = 0.02

-- Rocket mode
ENT.RocketDamage     = 150
ENT.RocketRadius     = 200
ENT.RocketSound      = "weapons/rpg/fire1.wav"
ENT.RocketSpeed      = 1200

-- Fire timing (seconds between shots)
ENT.FireInterval     = 1 / 15

-- Turret limits (degrees). YawMin/Max: use -180/180 for full 360.
ENT.YawMin           = -180
ENT.YawMax           =  180
ENT.PitchMin         = -45
ENT.PitchMax         =  45

-- General
ENT.SentryHealth     = 500
ENT.SentryMass       = 150
ENT.TurretRadius     = 1500
ENT.TurnSpeed        = 60

-- Bone names (override per model if needed)
ENT.BoneYaw          = "base"
ENT.BonePitch        = "gun"
ENT.BoneBarrels      = nil
ENT.BoneMuzzle       = nil
ENT.BoneLaser        = nil

-- Muzzle fallback (when no muzzle bone)
ENT.MuzzleFallback   = Vector(40, 0, 20)
ENT.HeightOffset     = 30
-- ───────────────────────────────────────────────────────────────────────────

function ENT:SetupDataTables()
    self:NetworkVar("Int",   0, "State")
    self:NetworkVar("Int",   1, "HP")
    self:NetworkVar("Float", 0, "AimPitch")
    self:NetworkVar("Float", 1, "AimYaw")
    self:NetworkVar("Float", 2, "Heat")
    self:NetworkVar("Float", 3, "BarrelSpin")
end
