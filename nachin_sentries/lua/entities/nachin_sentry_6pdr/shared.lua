include("shared.lua") -- nachin_sentry_base will not be found; child overrides only

ENT.Base           = "nachin_sentry_base"
ENT.PrintName      = "[SENTRY] 6-Pdr AT"
ENT.Author         = "kebinresi"
ENT.Category       = "Nachin Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnMenuIcon  = "vgui/entities/gred_emp_6pdr"

ENT.GunModel      = "models/gredwitch/6pdr/6pdr_gun.mdl"
ENT.GunPivotBone  = "6pdr_base"
ENT.GunMuzzleBone = "6pdr_barrel"
ENT.GunBarrelBone = ""
ENT.GunWeaponType = "rocket"
ENT.GunFireRate   = 0.17
ENT.GunDamage     = 180
ENT.GunYawMin     = -45
ENT.GunYawMax     = 45
ENT.GunPitchMin   = -5
ENT.GunPitchMax   = 15
ENT.GunTurnSpeed  = 35
ENT.GunMaxHealth  = 500
ENT.GunRadius     = 3000
ENT.GunShootSound = "gred_emp/6pdr/6pdr_shoot.wav"
ENT.GunMuzzleFX   = "MuzzleEffect"
ENT.GunMuzzleFB   = Vector(33, 0, 28)
