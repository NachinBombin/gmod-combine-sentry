AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] M2A1 Howitzer"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "gred_arti_muzzle_blast"
ENT.ShotInterval    = 5
ENT.AmmunitionTypes = {
    {"Direct Hit", "wac_base_75mm"},
    {"Time-fused", "wac_base_75mm"},
}
ENT.ShootSound      = "^gred_emp/common/75mm.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "Cannon"
ENT.HullModel       = "models/gredwitch/m2a1/m2a1_carriage.mdl"
ENT.TurretModel     = "models/gredwitch/m2a1/m2a1_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,0)
ENT.IsHowitzer      = true
ENT.SentryRange     = 4000
ENT.PitchRate       = 15
ENT.YawRate         = 15
