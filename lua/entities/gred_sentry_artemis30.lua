AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 30mm Artemis 30"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "muzzleflash_bar_3p"
ENT.ShotInterval    = 0.0375
ENT.TracerColor     = "Yellow"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_30mm"},
    {"Time-fused",  "wac_base_30mm"},
}
ENT.ShootSound      = "gred_emp/common/20mm_01.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/artemis30/artemis30_base_open.mdl"
ENT.YawModel        = "models/gredwitch/artemis30/artemis30_shield.mdl"
ENT.TurretModel     = "models/gredwitch/artemis30/artemis30_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,64)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 4000
ENT.PitchRate       = 40
ENT.YawRate         = 40
