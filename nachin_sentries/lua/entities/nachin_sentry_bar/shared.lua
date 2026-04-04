include("shared.lua") -- nachin_sentry_base will not be found; child overrides only

ENT.Base           = "nachin_sentry_base"
ENT.PrintName      = "[SENTRY] BAR"
ENT.Author         = "kebinresi"
ENT.Category       = "Nachin Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnMenuIcon  = "vgui/entities/gred_emp_bar"

ENT.GunModel      = "models/gredwitch/bar/bar_gun.mdl"
ENT.GunPivotBone  = "bar_base"
ENT.GunMuzzleBone = "bar_barrel"
ENT.GunBarrelBone = "bar_barrels"
ENT.GunWeaponType = "hitscan"
ENT.GunFireRate   = 9.2
ENT.GunDamage     = 16
ENT.GunYawMin     = -180
ENT.GunYawMax     = 180
ENT.GunPitchMin   = -10
ENT.GunPitchMax   = 45
ENT.GunTurnSpeed  = 75
ENT.GunMaxHealth  = 250
ENT.GunRadius     = 1800
ENT.GunShootSound = "gred_emp/bar/bar_shoot.wav"
ENT.GunMuzzleFX   = "MuzzleEffect"
ENT.GunMuzzleFB   = Vector(18, 0, 35)
