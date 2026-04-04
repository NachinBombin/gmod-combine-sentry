AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] GPF 155mm"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "gred_arti_muzzle_blast"
ENT.ShotInterval    = 5
ENT.AmmunitionTypes = {
    {"HE",   "wac_base_152mm"},
    {"Smoke","wac_base_152mm"},
}
ENT.ShootSound      = "^gred_emp/common/152mm.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "Cannon"
ENT.HullModel       = "models/gredwitch/gpf155/gpf155_carriage.mdl"
ENT.TurretModel     = "models/gredwitch/gpf155/gpf155_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,0)
ENT.IsHowitzer      = true
ENT.SentryRange     = 6000
ENT.PitchRate       = 15
ENT.YawRate         = 15
