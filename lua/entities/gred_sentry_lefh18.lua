AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] leFH 18 Howitzer"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "gred_arti_muzzle_blast"
ENT.ShotInterval    = 5
ENT.AmmunitionTypes = {
    {"HE",   "wac_base_105mm"},
    {"HEAT", "wac_base_105mm"},
}
ENT.ShootSound      = "^gred_emp/common/105mm.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "Cannon"
ENT.HullModel       = "models/gredwitch/lefh18/lefh18_carriage.mdl"
ENT.TurretModel     = "models/gredwitch/lefh18/lefh18_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,0)
ENT.IsHowitzer      = true
ENT.SentryRange     = 5000
ENT.PitchRate       = 15
ENT.YawRate         = 15
