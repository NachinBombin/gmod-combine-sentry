AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 128mm Flak 40 Zwilling"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "gred_arti_muzzle_blast"
ENT.ShotInterval    = 1.5
ENT.TracerColor     = "Yellow"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_128mm"},
    {"Time-fused",  "wac_base_128mm"},
}
ENT.ShootSound      = "^gred_emp/common/128mm.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/flak40z/flak40z_hull.mdl"
ENT.YawModel        = "models/gredwitch/flak40z/flak40z_yaw.mdl"
ENT.TurretModel     = "models/gredwitch/flak40z/flak40z_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,60)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 6000
ENT.PitchRate       = 25
ENT.YawRate         = 25
