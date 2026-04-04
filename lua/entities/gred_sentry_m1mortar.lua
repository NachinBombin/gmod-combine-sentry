AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] M1 Mortar"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "gred_arti_muzzle_blast"
ENT.ShotInterval    = 3
ENT.AmmunitionTypes = {
    {"HE",    "wac_base_mortar"},
    {"Smoke", "wac_base_mortar"},
}
ENT.ShootSound      = "gred_emp/mortars/shoot.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "Cannon"
ENT.HullModel       = "models/gredwitch/m1mortar/m1mortar_base.mdl"
ENT.TurretModel     = "models/gredwitch/m1mortar/m1mortar_barrel.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,0)
ENT.IsHowitzer      = true
ENT.SentryRange     = 3000
ENT.PitchRate       = 20
ENT.YawRate         = 20
