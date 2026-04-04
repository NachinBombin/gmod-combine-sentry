AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 20mm Breda 35"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "muzzleflash_bar_3p"
ENT.ShotInterval    = 0.15
ENT.TracerColor     = "Red"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_20mm"},
    {"Time-fused",  "wac_base_20mm"},
}
ENT.ShootSound      = "gred_emp/common/20mm_01.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/breda35/breda35_mount.mdl"
ENT.TurretModel     = "models/gredwitch/breda35/breda35_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,20)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 3000
ENT.PitchRate       = 40
ENT.YawRate         = 40
