include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.SentryTarget    = NULL
    self.SentryAcquired  = 0
    self.SentryFireTimer = 0
end

function ENT:Think()
    self.BaseClass.Think(self)
    if not self.SentryBotMode then return end
    local ct = CurTime()

    -- Scan for target if we don't have one
    if not IsValid(self.SentryTarget) then
        self.SentryTarget = NULL
        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.SentryRange)) do
            if self:CanEngage(ent) then
                self.SentryTarget   = ent
                self.SentryAcquired = ct + self.SentryAcquireTime
                break
            end
        end
        return
    end

    -- Verify current target still valid
    if not self:CanEngage(self.SentryTarget) then
        self.SentryTarget = NULL
        return
    end

    -- Still acquiring
    if ct < self.SentryAcquired then return end

    -- Aim at target
    local targetPos = self.SentryTarget:GetPos() + Vector(0, 0, 30)
    local dir       = (targetPos - self:GetPos()):GetNormalized()
    local ang       = dir:Angle()
    self:SetAngles(Angle(ang.p, ang.y, 0))

    -- Fire
    if ct >= self.SentryFireTimer then
        self:PrimaryAttack()
        self.SentryFireTimer = ct + (self.ShotInterval or 0.1)
    end
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 16
    local ent = ents.Create(ClassName)
    ent:SetPos(SpawnPos)
    ent.Owner   = ply
    ent.Spawner = ply
    ent:Spawn()
    ent:Activate()
    return ent
end
