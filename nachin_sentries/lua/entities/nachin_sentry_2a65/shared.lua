include("shared.lua") -- nachin_sentry_base will not be found; child overrides only

ENT.Base           = "nachin_sentry_base"
ENT.PrintName      = "[SENTRY] 2A65 Howitzer"
ENT.Author         = "kebinresi"
ENT.Category       = "Nachin Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnMenuIcon  = "vgui/entities/gred_emp_2a65"

ENT.GunModel      = "models/gredwitch/2a65/2a65_gun.mdl"
ENT.GunPivotBone  = "2a65_base"
ENT.GunMuzzleBone = "2a65_barrel"
ENT.GunBarrelBone = ""
ENT.GunWeaponType = "rocket"
ENT.GunFireRate   = 0.1
ENT.GunDamage     = 400
ENT.GunYawMin     = -45
ENT.GunYawMax     = 45
ENT.GunPitchMin   = 10
ENT.GunPitchMax   = 65
ENT.GunTurnSpeed  = 20
ENT.GunMaxHealth  = 900
ENT.GunRadius     = 5500
ENT.GunShootSound = "gred_emp/2a65/2a65_shoot.wav"
ENT.GunMuzzleFX   = "MuzzleEffect"
ENT.GunMuzzleFB   = Vector(50, 0, 40)
