-- combine_sentry/shared.lua
-- Inherits the full AI from sentry_base just like every other sentry.
-- Uses the Gredwitch M2HB model + icon (already shipped by the parent addon).
-- The ONLY difference from sentry_m2hmg is the faction gate in sentry_base:
-- Combine-faction NPCs are never targeted.

ENT.Base          = "sentry_base"
ENT.PrintName     = "Combine Sentry (M2HB)"
ENT.Author        = "kebinresi"
ENT.Category      = "Combine Sentries"
ENT.Spawnable     = true
ENT.AdminSpawnable = true
ENT.SpawnIcon     = "entities/gred_emp_m2.png"

-- Model shipped by Gredwitch Base addon
ENT.SentryModel      = "models/gredwitch/m2.mdl"

-- Weapon config
ENT.FireType         = "BULLET"
ENT.BulletDamage     = 35
ENT.BulletNum        = 1
ENT.BulletInaccuracy = 0.015
ENT.BulletSound      = "weapons/emplacement/gun_shoot1.wav"
ENT.FireInterval     = 60 / 525

-- Turret limits
ENT.YawMin  = -180
ENT.YawMax  =  180
ENT.PitchMin = -10
ENT.PitchMax =  50

-- Bone names (Gredwitch M2 rig)
ENT.BoneYaw   = "base"
ENT.BonePitch = "gun"
ENT.MuzzleFallback = Vector(45, 0, 15)
