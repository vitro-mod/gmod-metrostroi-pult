ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.AdminOnly   = true
ENT.Spawnable   = true
ENT.PrintName   = "Bell"
ENT.Purpose     = "This is a tunnel bell"

function ENT:OnRemove()
	if SERVER then VitroMod.bellSend() end
	if CLIENT then self:Stp() end
end