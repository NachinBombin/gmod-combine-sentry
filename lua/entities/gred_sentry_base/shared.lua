AddCSLuaFile()

ENT.Type            = "anim"
ENT.Base            = "gred_emp_base"
ENT.Author          = "NachinBombin"
ENT.Category        = "Gredwitch Sentries"
ENT.Spawnable       = false
ENT.AdminSpawnable  = false

-- Sentry AI config
ENT.SentryRange         = 3000   -- units
ENT.SentryFOV           = 120    -- degrees
ENT.SentryFireDelay     = 0.1    -- seconds before opening fire on new target
ENT.SentryAcquireTime   = 0.4    -- seconds to acquire target
ENT.SentryAutoAim       = true
ENT.SentryBotMode       = true

-- Combine-friendly classes (will NOT shoot these)
local COMBINE_FRIENDLY = {
    npc_combine_s      = true,
    npc_metropolice    = true,
    npc_combinedropship = true,
    npc_helicopter     = true,
    npc_combinegunship = true,
    npc_strider        = true,
    npc_turret_ceiling = true,
    npc_turret_floor   = true,
    npc_turret_ground  = true,
    npc_manhack        = true,
    npc_scanner        = true,
    npc_cscanner       = true,
}

function ENT:CanEngage(ent)
    if not IsValid(ent) or ent == self then return false end
    if ent:IsNPC() then
        if ent:Health() <= 0 then return false end
        if COMBINE_FRIENDLY[ent:GetClass()] then return false end
    elseif ent:IsPlayer() then
        if not ent:Alive() then return false end
        -- optionally skip players: return false
    else
        return false
    end
    local dist = self:GetPos():Distance(ent:GetPos())
    if dist > self.SentryRange then return false end
    return self:CanSeeTarget(ent)
end

function ENT:CanSeeTarget(ent)
    local tr = util.TraceLine({
        start  = self:GetPos() + Vector(0,0,30),
        endpos = ent:GetPos() + Vector(0,0,30),
        filter = {self, self:GetHull(), self:GetYaw(), self:GetTurret()},
        mask   = MASK_SOLID_BRUSHONLY,
    })
    return tr.Fraction >= 0.99
end
