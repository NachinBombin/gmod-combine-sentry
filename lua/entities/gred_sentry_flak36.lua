AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] 37mm Flak 36"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "ins_weapon_rpg_frontblast"
ENT.ShotInterval    = 0.375
ENT.TracerColor     = "Yellow"
ENT.AmmunitionTypes = {
    {"Direct Hit",  "wac_base_40mm"},
    {"Time-fused",  "wac_base_40mm"},
}
ENT.ShootSound      = "gred_emp/flak36/shoot.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "MG"
ENT.HullModel       = "models/gredwitch/flak36/flak36_hull.mdl"
ENT.YawModel        = "models/gredwitch/flak36/flak36_yaw.mdl"
ENT.TurretModel     = "models/gredwitch/flak36/flak36_turret.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(-2,0,24.6584)
ENT.IsAAA           = true
ENT.CanSwitchTimeFuse = true
ENT.SentryRange     = 4000
ENT.PitchRate       = 40
ENT.YawRate         = 40
