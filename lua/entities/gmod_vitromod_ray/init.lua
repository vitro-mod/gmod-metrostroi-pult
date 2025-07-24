AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
include('trig_init.lua')
VitroMod = VitroMod or {}
VitroMod.Rays = VitroMod.Rays or {}
VitroMod.Rays.Name = VitroMod.Rays.Name or 'ray1'
VitroMod.Rays.Status = VitroMod.Rays.Status or {}
VitroMod.Rays.Caption = false

function ENT:Initialize()
	self:SetModel('models/mn_signs/light_sensor.mdl')
	self:SetNW2String('Name', self:GetName())
	self:CreateTrigger()
end

function ENT:Think()
end


function ENT:CreateTrigger()
	local ray = self
	local initialOffset = Vector(0, -82.3, 67.9 + 2)
	local sensorOffset = Vector(-94, -15, -30) + Vector(0, -ray.options.sensorXOffset or 0, ray.options.sensorZOffset or 0)
	local lampOffset = Vector(0, 80, 40) + Vector(0, -ray.options.lampXOffset or 0, ray.options.lampZOffset or 0)
	self.Trigger = ents.Create('gmod_vitromod_ray_trig')
	self.Trigger:SetParent(self)
	self.Trigger:Spawn()
	self.Trigger:SetAngles(self:GetAngles())
	local cbMax = sensorOffset + initialOffset
	local direction = cbMax - lampOffset
	local length = direction:Length()
	local angle = direction:Angle()
	self.Trigger:SetPos(self:LocalToWorld(lampOffset))
	self.Trigger:SetAngles(self:LocalToWorldAngles(angle))
	self.Trigger:SetCollisionBounds(Vector(-0.5,-0.5,-0.5), Vector(length * 1.75 + 0.5, 0.5, 0.5))

	local trig = self.Trigger
	function trig:StartTouch(ent)
		trig.Touching = trig.Touching or {}
		local count = table.Count(trig.Touching)
		if IsValid(ent) then trig.Touching[ent] = true end
		if count == 0 and ray:GetIsActive() then runUpdateHook(ray, false) end
	end
	function trig:EndTouch(ent)
		trig.Touching = trig.Touching or {}
		trig.Touching[ent] = nil
		local count = table.Count(trig.Touching)
		if count == 0 and ray:GetIsActive() then runUpdateHook(ray, true) end
	end
	function runUpdateHook(ray, status)
		hook.Run('VitroMod.Rays.FS', ray:GetName(), status)
		RunConsoleCommand('say', 'Ray ' .. ray:GetName() .. (status and ' FS1' or ' FS0'))
	end
	hook.Add('VitroMod.Rays.FL', 'VitroMod.Rays.FL.' .. ray:EntIndex(), function(name, status)
		if not IsValid(ray) then return end
		if name ~= ray:GetName() then return end

		ray:SetIsActive(status)
		local count = table.Count(trig.Touching or {})
		if count == 0 then runUpdateHook(ray, status) end
	end)
end

VitroMod.Rays.atLook = function(trace, ply, options )
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
	ray.options = options or {}

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

	VitroMod.Rays.send()
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

VitroMod.Rays.send = function(ply)
	if not VitroMod.RayNWAdded then
		util.AddNetworkString('vitromod_ray_data')
		VitroMod.RayNWAdded = true
	end

	local clientData = {}
	for k, v in pairs(ents.FindByClass('gmod_vitromod_ray')) do
		local name = v:GetName()
		clientData[name] = {}
		clientData[name]['pos'] = v:GetPos()
		clientData[name]['status'] = VitroMod.Rays.Status[name] or false
		clientData[name]['options'] = v.options or {}
	end

	net.Start('vitromod_ray_data')
	net.WriteTable(clientData)
	if not ply then
		net.Broadcast()
	else
		net.Send(ply)
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

hook.Add('PlayerSpawn', 'VitroMod.Rays', function(ply) VitroMod.Rays.send(ply) end)
function ENT:OnRemove()
	VitroMod.Rays.send(ply)
	SafeRemoveEntity(self.Trigger)
end
