-- SENTRY: 3-inch Mortar | grenade | DMG:180 | Range:2000
AddCSLuaFile()
ENT.Type="anim" ENT.Base="base_anim" ENT.PrintName="3-inch Mortar Sentry"
ENT.Category="Combine Sentries" ENT.Spawnable=true ENT.AdminOnly=false ENT.RenderGroup=RENDERGROUP_OPAQUE
local CF={["npc_combine_s"]=true,["npc_combine_camera"]=true,["npc_turret_floor"]=true,["npc_turret_ceiling"]=true,["npc_turret_ground"]=true,["npc_metropolice"]=true,["npc_cscanner"]=true,["npc_clawscanner"]=true,["npc_manhack"]=true,["npc_strider"]=true,["npc_helicopter"]=true,["npc_combinegunship"]=true,["npc_hunter"]=true}
function ENT:Initialize()
  if not SERVER then return end
  self:SetModel("models/weapons/w_smg1.mdl")
  self:SetSolid(SOLID_VPHYSICS) self:PhysicsInit(SOLID_VPHYSICS)
  self:SetHealth(600) self:SetMaxHealth(600)
  local p=self:GetPhysicsObject() if IsValid(p) then p:EnableMotion(false) end
  self.NextFireTime=0 self.FireDelay=3.0 self.BurstCount=0 self.BurstMax=1 self.BurstDelay=5.0
  self.NextBurstTime=0 self.Target=nil self.Range=2000 self.Damage=180 self.AmmoType="grenade"
  self:NextThink(CurTime()+0.1)
end
function ENT:CanEngage(e)
  if not IsValid(e) or e==self then return false end
  if e:IsNPC() then if e:Health()<=0 or CF[e:GetClass()] then return false end
  elseif e:IsPlayer() then if not e:Alive() then return false end
  else return false end
  return self:CanSeeTarget(e)
end
function ENT:CanSeeTarget(e)
  if not IsValid(e) then return false end
  local m=self:GetPos()+Vector(0,0,30) local t=e:GetPos()+Vector(0,0,32)
  if m:Distance(t)>self.Range then return false end
  local tr=util.TraceLine({start=m,endpos=t,filter={self,e},mask=MASK_SHOT})
  return tr.Fraction>=0.98
end
function ENT:FindTarget()
  for _,e in ipairs(ents.FindInSphere(self:GetPos(),self.Range)) do
    if self:CanEngage(e) then return e end
  end return nil
end
function ENT:Fire()
  local t=self.Target if not IsValid(t) then return end
  local m=self:GetPos()+Vector(0,0,30) local tp=t:GetPos()+Vector(0,0,32)
  local d=(tp-m):GetNormalized()
  self:FireBullets({Num=1,Src=m,Dir=d,Spread=Vector(0.05,0.05,0),Tracer=1,Force=30,Damage=self.Damage,AmmoType=self.AmmoType,AttackerTable={self}})
  self:EmitSound("weapons/rpg/rocketfire1.wav",85,math.random(95,105))
  local ef=EffectData() ef:SetOrigin(m) ef:SetNormal(d) util.Effect("MuzzleFlash",ef)
end
function ENT:Think()
  if not SERVER then return end
  local now=CurTime()
  if not IsValid(self.Target) or not self:CanEngage(self.Target) then self.Target=self:FindTarget() end
  if IsValid(self.Target) then
    local m=self:GetPos()+Vector(0,0,30) local tp=self.Target:GetPos()+Vector(0,0,32)
    self:SetAngles(Angle(0,(tp-m):Angle().y,0))
    if now>=self.NextBurstTime and now>=self.NextFireTime then
      if self.BurstCount<self.BurstMax then self:Fire() self.BurstCount=self.BurstCount+1 self.NextFireTime=now+self.FireDelay
      else self.BurstCount=0 self.NextBurstTime=now+self.BurstDelay end
    end
  end
  self:NextThink(now+0.05) return true
end
function ENT:OnTakeDamage(d)
  self:SetHealth(self:Health()-d:GetDamage())
  if self:Health()<=0 then local ef=EffectData() ef:SetOrigin(self:GetPos()) util.Effect("Explosion",ef) self:EmitSound("ambient/explosions/explode_"..math.random(1,9)..".wav") self:Remove() end
end
