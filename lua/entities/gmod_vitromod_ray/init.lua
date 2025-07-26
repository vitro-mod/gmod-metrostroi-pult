AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
VitroMod = VitroMod or {}
VitroMod.Rays = VitroMod.Rays or {}
VitroMod.Rays.Name = VitroMod.Rays.Name or 'ray1'
VitroMod.Rays.Status = VitroMod.Rays.Status or {}
VitroMod.Rays.Caption = false
function ENT:Initialize()
	self.Name = self:GetName()
	self:InitializeRays()
	self:SetModel('models/mn_signs/light_sensor.mdl')
	self:SetNW2String('Name', self:GetName())
	self.FirstTrace = true
	hook.Add('VitroMod.Rays.FL', 'VitroMod.Rays.FL.' .. self:EntIndex(), function(name, status)
		if not IsValid(self) then return end
		if name ~= self:GetName() then return end
		if not status then
			self.FirstTrace = true
		end
		self:SetIsActive(status)
	end)
	-- self:CreateTrigger()
end

function ENT:Think()
	if not self:GetIsActive() then return end
	local oldHit = self:GetHit()
	local startPos = self.LampOffsetWorld
	local endPos = self.SensorOffsetWorld
	local tr = util.TraceLine({
		start = startPos,
		endpos = endPos,
		filter = self,
		mask = MASK_SHOT
	})

	if tr.Hit and (not oldHit or self.FirstTrace) then
		self.tr = tr
		-- print('Ray ' .. self:GetName() .. ' hit something: ' .. tostring(tr.Entity))
		hook.Run('VitroMod.Rays.FS', self:GetName(), false)
	elseif not tr.Hit and (oldHit or self.FirstTrace) then
		-- print('Ray ' .. self:GetName() .. ' stopped hitting ' .. tostring(self.tr and self.tr.Entity or 'something'))
		-- if self.tr and IsValid(self.tr.Entity) then print(self.tr.Entity:GetVelocity():Length() * 0.01875 * 3.6) end
		hook.Run('VitroMod.Rays.FS', self:GetName(), true)
	end

	self.FirstTrace = false
	self:SetHit(tr.Hit)
end

VitroMod.Rays.atLook = function(trace, ply, options)
	local name = options.name
	local needSpawn = true
	for k, v in pairs(ents.FindInSphere(trace.HitPos, 100)) do
		if v:GetClass() == 'gmod_vitromod_ray' and v:EntIndex() == VitroMod.Rays.LastRay then needSpawn = false end
	end

	local ray = needSpawn and ents.Create('gmod_vitromod_ray') or Entity(VitroMod.Rays.LastRay)
	local hitang = trace.HitNormal:Angle()
	local angles = Angle(hitang[1] + 90, hitang[2], hitang[3])
	local offset = Vector(0, 0, 2.1)
	offset:Rotate(angles)
	local pos = trace.HitPos
	local ang = angles
	local tr = Metrostroi.RerailGetTrackData(trace.HitPos, ply:GetAimVector())
	if tr then pos = tr.centerpos + offset end
	if tr then ang = tr.forward:Angle() end
	ray:SetPos(pos)
	ray:SetAngles(ang)
	ray:SetSensorXOffset(options.sensorXOffset or 0)
	ray:SetSensorZOffset(options.sensorZOffset or 0)
	ray:SetLampXOffset(options.lampXOffset or 0)
	ray:SetLampZOffset(options.lampZOffset or 0)
	local nm = VitroMod.Rays.Name
	if name then nm = name end
	if needSpawn then
		ray:SetName(nm)
		ray:SetNW2String('Name', nm)
		ray:Spawn()
		VitroMod.Rays.LastRay = ray:EntIndex()
		undo.Create('Ray')
		undo.AddEntity(ray)
		undo.SetPlayer(ply)
		undo.Finish()
	end
end

VitroMod.Rays.remove = function(trace)
	for k, v in pairs(ents.FindInSphere(trace.HitPos, 100)) do
		if v:GetClass() == 'gmod_vitromod_ray' then v:Remove() end
	end
end

VitroMod.Rays.flush = function()
	for k, v in pairs(ents.FindByClass('gmod_vitromod_ray')) do
		SafeRemoveEntity(v)
	end
end

VitroMod.Rays.sendCap = function(ply)
	if not VitroMod.RayNWAdded2 then
		util.AddNetworkString('vitromod_ray_cap')
		VitroMod.RayNWAdded2 = true
	end

	net.Start('vitromod_ray_cap')
	net.WriteBool(VitroMod.Rays.Caption)
	net.Broadcast()
	if not ply then return end
	net.Send(ply)
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Trigger)
end

function ENT:GetMetrostroiSaveTable()
	return {
		Name = self:GetName(),
		Pos = self:GetPos(),
		Angles = self:GetAngles(),
		SensorXOffset = self:GetSensorXOffset(),
		SensorZOffset = self:GetSensorZOffset(),
		LampXOffset = self:GetLampXOffset(),
		LampZOffset = self:GetLampZOffset(),
	}
end

function ENT:MetrostroiLoad(data)
	self:SetName(data.Name)
	self:SetPos(data.Pos)
	self:SetAngles(data.Angles)
	self:SetSensorXOffset(data.SensorXOffset)
	self:SetSensorZOffset(data.SensorZOffset)
	self:SetLampXOffset(data.LampXOffset)
	self:SetLampZOffset(data.LampZOffset)
end
