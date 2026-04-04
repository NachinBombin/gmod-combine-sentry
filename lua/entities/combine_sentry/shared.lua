-- combine_sentry/shared.lua
-- Exact same structure as sentry_m2hmg/shared.lua.
-- Uses ENT.Base = "sentry_base" so model, rendering and AI all come from there.
-- SpawnIcon reuses the gred_emp_m2.png that ships with the Gredwitch Base addon.

ENT.Base           = "sentry_base"
ENT.PrintName      = "Combine Sentry"
ENT.Author         = "kebinresi"
ENT.Category       = "Combine Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnIcon      = "entities/gred_emp_m2.png"

ENT.SentryModel      = "models/gredwitch/m2.mdl"
ENT.FireType         = "BULLET"
ENT.BulletDamage     = 35
ENT.BulletNum        = 1
ENT.BulletInaccuracy = 0.015
ENT.BulletSound      = "weapons/emplacement/gun_shoot1.wav"
ENT.FireInterval     = 60 / 525
ENT.YawMin           = -180
ENT.YawMax           =  180
ENT.PitchMin         = -10
ENT.PitchMax         =  50
ENT.BoneYaw          = "base"
ENT.BonePitch        = "gun"
ENT.MuzzleFallback   = Vector(45, 0, 15)
