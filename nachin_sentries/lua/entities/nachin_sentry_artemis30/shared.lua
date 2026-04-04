include("shared.lua") -- nachin_sentry_base will not be found; child overrides only

ENT.Base           = "nachin_sentry_base"
ENT.PrintName      = "[SENTRY] Artemis 30"
ENT.Author         = "kebinresi"
ENT.Category       = "Nachin Sentries"
ENT.Spawnable      = true
ENT.AdminSpawnable = true
ENT.SpawnMenuIcon  = "vgui/entities/gred_emp_artemis30"

ENT.GunModel      = "models/gredwitch/artemis30/artemis30_gun.mdl"
ENT.GunPivotBone  = "artemis30_base"
ENT.GunMuzzleBone = "artemis30_barrel"
ENT.GunBarrelBone = "artemis30_barrels"
ENT.GunWeaponType = "hitscan"
ENT.GunFireRate   = 3.3
ENT.GunDamage     = 45
ENT.GunYawMin     = -180
ENT.GunYawMax     = 180
ENT.GunPitchMin   = -5
ENT.GunPitchMax   = 90
ENT.GunTurnSpeed  = 50
ENT.GunMaxHealth  = 550
ENT.GunRadius     = 3000
ENT.GunShootSound = "gred_emp/artemis30/artemis30_shoot.wav"
ENT.GunMuzzleFX   = "MuzzleEffect"
ENT.GunMuzzleFB   = Vector(30, 0, 50)
