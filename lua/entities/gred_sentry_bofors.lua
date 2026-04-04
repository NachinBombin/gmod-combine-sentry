AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 40mm Bofors L/60"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "ins_weapon_rpg_frontblast"
ENT.ShotInterval    = 0.5
ENT.TracerColor     = "Red"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_40mm"},
    {"Time-fused",  "wac_base_40mm"},
}
ENT.ShootSound      = "gred_emp/bofors/shoot.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/bofors/bofors_base_open.mdl"
ENT.YawModel        = "models/gredwitch/bofors/bofors_turret.mdl"
ENT.TurretModel     = "models/gredwitch/bofors/bofors_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(-7,0,37.1763)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 4000
ENT.PitchRate       = 20
ENT.YawRate         = 30
