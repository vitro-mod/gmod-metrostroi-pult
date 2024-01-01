AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

VitroMod = VitroMod or {}
VitroMod.Bells = VitroMod.Bells or {}
VitroMod.Bells.Name = VitroMod.Bells.Name or 'bell1'
VitroMod.Bells.Status = VitroMod.Bells.Status or {}
VitroMod.Bells.Caption = false

hook.Add('VitroMod.Bells.Status', 'VitroMod.Bells.Status.set', function(name, status)
	VitroMod.Bells.Status[name] = status
	VitroMod.Bells.sendBell(name)
end)

function ENT:Initialize()
	self:SetModel( "models/stations/station_kolokol1.mdl" )
	self:SetNW2String('Name',self:GetName())
end


function ENT:Think()

end

VitroMod.Bells.atLook = function(trace, ply, name, userOffset, userAngle)
	local bell = ents.Create("gmod_vitromod_bell")
	local hitang = trace.HitNormal:Angle()
	local angles = Angle( hitang[1]+90, hitang[2], hitang[3])
	local offset = Vector(0,0,2.1)
	offset:Rotate(angles)
	bell:SetPos( trace.HitPos + offset + userOffset )
	bell:SetAngles( angles + userAngle )
	local nm = VitroMod.Bells.Name
	if name then nm = name end
	bell:SetName(nm)
	bell:SetNW2String('Name',nm)
	bell:Spawn()
	undo.Create("Bell")
		undo.AddEntity(bell)
		undo.SetPlayer(ply)
	undo.Finish()
	VitroMod.Bells.send()
end

VitroMod.Bells.remove = function(trace)
	for k,v in pairs(ents.FindInSphere(trace.HitPos, 4)) do 
		if v:GetClass() == 'gmod_vitromod_bell' then v:Remove() end
	end
end

VitroMod.Bells.flush = function()
	for k,v in pairs(ents.FindByClass('gmod_vitromod_bell')) do
		SafeRemoveEntity(v)
	end
end

VitroMod.Bells.send = function(ply)
	if not VitroMod.BellNWAdded then 
		util.AddNetworkString("vitromod_bell_data") 
		VitroMod.BellNWAdded = true 
	end
	local clientData = {}
	for k,v in pairs(ents.FindByClass('gmod_vitromod_bell')) do
		local name = v:GetName()
		clientData[name] = {}
		clientData[name]['pos'] = v:GetPos()
		clientData[name]['status'] = VitroMod.Bells.Status[name] or false
	end
	net.Start("vitromod_bell_data")
	net.WriteTable(clientData)
	if not ply then
		net.Broadcast()
	else 
		net.Send(ply) 
	end	
end


VitroMod.Bells.sendBell = function(name, ply, mute)
	--if ply then print(ent:GetName(), ply:GetName(), mute) end
	if not VitroMod.BellNWAdded3 then 
		util.AddNetworkString("vitromod_bell") 
		VitroMod.BellNWAdded3 = true 
	end
	local clientData = {}
	clientData['name'] = name
	clientData['status'] = mute and false or VitroMod.Bells.Status[name]
	net.Start("vitromod_bell")
	net.WriteTable(clientData)
	if not ply then
		net.Broadcast()
	else 
		net.Send(ply) 
	end	
end

VitroMod.Bells.sendCap = function(ply)
	if not VitroMod.BellNWAdded2 then 
		util.AddNetworkString("vitromod_bell_cap") 
		VitroMod.BellNWAdded2 = true 
	end
	net.Start("vitromod_bell_cap")
	net.WriteBool(VitroMod.Bells.Caption)
	net.Broadcast()
	if not ply then return end
	net.Send(ply)
end

hook.Add("PlayerSpawn", 'VitroMod.Bells', function(ply)
	VitroMod.Bells.send(ply)
end)

function ENT:OnRemove()
	VitroMod.Bells.send(ply)
end
