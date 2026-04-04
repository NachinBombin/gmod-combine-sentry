AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 20mm Flak 38"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "muzzleflash_bar_3p"
ENT.ShotInterval    = 0.1
ENT.TracerColor     = "Yellow"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_20mm"},
    {"Time-fused",  "wac_base_20mm"},
}
ENT.ShootSound      = "gred_emp/common/20mm_01.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/flak38/flak38_hull.mdl"
ENT.YawModel        = "models/gredwitch/flak38/flak38_yaw.mdl"
ENT.TurretModel     = "models/gredwitch/flak38/flak38_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,20)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 3000
ENT.PitchRate       = 40
ENT.YawRate         = 50
