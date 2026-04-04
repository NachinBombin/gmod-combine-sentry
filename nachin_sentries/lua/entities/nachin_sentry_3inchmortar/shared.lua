include("shared.lua") -- nachin_sentry_base will not be found; child overrides only

ENT.Base           = "nachin_sentry_base"
ENT.PrintName      = "[SENTRY] 3-inch Mortar"
ENT.Author         = "kebinresi"
ENT.Category       = "Nachin Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnMenuIcon  = "vgui/entities/gred_emp_3inchmortar"

ENT.GunModel      = "models/gredwitch/3inchmortar/3inchmortar_gun.mdl"
ENT.GunPivotBone  = "3inchmortar_base"
ENT.GunMuzzleBone = "3inchmortar_barrel"
ENT.GunBarrelBone = ""
ENT.GunWeaponType = "rocket"
ENT.GunFireRate   = 0.42
ENT.GunDamage     = 200
ENT.GunYawMin     = -180
ENT.GunYawMax     = 180
ENT.GunPitchMin   = 45
ENT.GunPitchMax   = 85
ENT.GunTurnSpeed  = 30
ENT.GunMaxHealth  = 400
ENT.GunRadius     = 2000
ENT.GunShootSound = "gred_emp/3inchmortar/mortar_shoot.wav"
ENT.GunMuzzleFX   = "MuzzleEffect"
ENT.GunMuzzleFB   = Vector(10, 0, 50)
