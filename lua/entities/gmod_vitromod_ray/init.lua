AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')
VitroMod = VitroMod or {}
VitroMod.Rays = VitroMod.Rays or {}
VitroMod.Rays.Name = VitroMod.Rays.Name or 'ray1'
VitroMod.Rays.Status = VitroMod.Rays.Status or {}
VitroMod.Rays.Caption = false
hook.Add('VitroMod.Rays.Status', 'VitroMod.Rays.Status.set', function(name, status)
	VitroMod.Rays.Status[name] = status
	VitroMod.Rays.sendRay(name)
end)

function ENT:Initialize()
	self:SetModel('models/mn_signs/light_sensor.mdl')
	self:SetNW2String('Name', self:GetName())
end

function ENT:Think()
end

VitroMod.Rays.atLook = function(trace, ply, name, options )
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

VitroMod.Rays.sendRay = function(name, ply, mute)
	--if ply then print(ent:GetName(), ply:GetName(), mute) end
	if not VitroMod.RayNWAdded3 then
		util.AddNetworkString('vitromod_ray')
		VitroMod.RayNWAdded3 = true
	end

	local clientData = {}
	clientData['name'] = name
	clientData['status'] = mute and false or VitroMod.Rays.Status[name]
	net.Start('vitromod_ray')
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
end