AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_sentry_base"
ENT.Category        = "Gredwitch Sentries"
ENT.PrintName       = "[SENTRY] M5 3-inch AT Gun"
ENT.Author          = "NachinBombin"
ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MuzzleEffect    = "ins_weapon_rpg_frontblast"
ENT.ShotInterval    = 3
ENT.AmmunitionTypes = {
    {"AP",  "wac_base_75mm"},
    {"HE",  "wac_base_75mm"},
}
ENT.ShootSound      = "^gred_emp/common/75mm.wav"
ENT.OnlyShootSound  = true
ENT.EmplacementType = "Cannon"
ENT.HullModel       = "models/gredwitch/m5/m5_carriage.mdl"
ENT.TurretModel     = "models/gredwitch/m5/m5_gun.mdl"
ENT.Ammo            = -1
ENT.TurretPos       = Vector(0,0,0)
ENT.SentryRange     = 3500
ENT.PitchRate       = 20
ENT.YawRate         = 20
