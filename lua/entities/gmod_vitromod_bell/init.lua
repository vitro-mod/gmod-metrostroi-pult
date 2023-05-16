AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

VitroMod = VitroMod or {}
VitroMod.Bells = VitroMod.Bells or {}
VitroMod.BellName = VitroMod.BellName or 'bell1'
VitroMod.BellCap = false

function ENT:Initialize()
	self:SetModel( "models/stations/station_kolokol1.mdl" )
end

function ENT:Ring(pitch)
	self.snd = true
	VitroMod.bellSendRing(self)
end

function ENT:Stop()
	self.snd = false
	VitroMod.bellSendRing(self)
end

function ENT:Think()

end

VitroMod.bellAtLook = function(trace, ply, name, userOffset)
	local bell = ents.Create("gmod_vitromod_bell")
	local hitang = trace.HitNormal:Angle()
	local angles = Angle( hitang[1]+90, hitang[2], hitang[3])
	local offset = Vector(0,0,2.1)
	offset:Rotate(angles)
	userOffset:Rotate(angles)
	bell:SetPos( trace.HitPos + offset + userOffset )
	bell:SetAngles( angles )
	local nm = VitroMod.BellName
	if name then nm = name end
	bell:SetName(nm)
	bell:Spawn()
	undo.Create("Bell")
		undo.AddEntity(bell)
		undo.SetPlayer(ply)
	undo.Finish()
	VitroMod.bellSend()
end

VitroMod.bellRemove = function(trace)
	for k,v in pairs(ents.FindInSphere(trace.HitPos, 4)) do 
		if v:GetClass() == 'gmod_vitromod_bell' then v:Remove() end
	end
end

VitroMod.bellFlush = function()
	for k,v in pairs(ents.FindByClass("gmod_vitromod_bell")) do 
		VitroMod.bellSendRing(v,nil,true) 
		SafeRemoveEntity(v)
	end
end

VitroMod.bellSend = function()
	if not VitroMod.BellNWAdded then 
		util.AddNetworkString("vitromod_bell_data") 
		VitroMod.BellNWAdded = true 
	end
	VitroMod.Bells.ClientData = {}
	for k,v in pairs(ents.FindByClass('gmod_vitromod_bell')) do
		VitroMod.Bells.ClientData[k] = {}
		VitroMod.Bells.ClientData[k]['name'] = v:GetName()
		VitroMod.Bells.ClientData[k]['pos'] = v:GetPos()
	end
	net.Start("vitromod_bell_data")
	net.WriteTable(VitroMod.Bells.ClientData)
	net.Broadcast()		
end


VitroMod.bellSendRing = function(ent, ply, mute)
	--if ply then print(ent:GetName(), ply:GetName(), mute) end
	if not VitroMod.BellNWAdded3 then 
		util.AddNetworkString("vitromod_bell") 
		VitroMod.BellNWAdded3 = true 
	end
	net.Start("vitromod_bell")
	net.WriteEntity(ent)
	if not mute then net.WriteBool(ent.snd)
	else net.WriteBool(false) end
	--if not ply then net.Broadcast()
	if not ply then
		net.SendPVS( ent:GetPos() )
	else 
		net.Send(ply) 
	end
end

VitroMod.bellSendCap = function(ply)
	if not VitroMod.BellNWAdded2 then 
		util.AddNetworkString("vitromod_bell_cap") 
		VitroMod.BellNWAdded2 = true 
	end
	net.Start("vitromod_bell_cap")
	net.WriteBool(VitroMod.BellCap)
	net.Broadcast()
	if not ply then return end
	net.Send(ply)
end

VitroMod.bellScape = function(name, zMin, zMax)
	VitroMod.Bells = VitroMod.Bells or {}
	VitroMod.Bells.Scapes = VitroMod.Bells.Scapes or {}
	VitroMod.Bells.Scapes[name] = VitroMod.Bells.Scapes[name] or {}
	local bells = ents.FindByName(name.."*")
	hook.Add("PlayerPostThink", name, function(ply)
		VitroMod.bellDoScape(ply, bells, name, zMin, zMax)
	end)
	hook.Add("PlayerSpawn", name..'Sp', function(ply)
		VitroMod.bellDoScape(ply, bells, name, zMin, zMax)	
	end)
end

VitroMod.bellDoScape = function(ply, bells, name, zMin, zMax)
	local canHear = ply:GetPos()[3] > zMin and ply:GetPos()[3] < zMax
	VitroMod.Bells.Scapes[name][ply] = VitroMod.Bells.Scapes[name][ply] or false
	if canHear != VitroMod.Bells.Scapes[name][ply] then
		--print(name, ply:GetName(), canHear and 'come' or 'leave')
		VitroMod.Bells.Scapes[name][ply] = canHear
		for k,v in pairs(bells) do
			local send = function() VitroMod.bellSendRing(v, ply, not canHear) end
			timer.Simple(0, send)
		end
	end	
end

VitroMod.bellScapeInit = function()
	if game.GetMap() == "gm_metro_kalinin_v2" then
		VitroMod.bellScape("BLNK", 9240, 9485)
		VitroMod.bellScape("BLNV", 8500, 9200)
		VitroMod.bellScape("BLSE", 6511, 6833)
		VitroMod.bellScape("BLMR", 3934, 4256)
		VitroMod.bellScape("BLTR", 3255, 3700)
	end
end

hook.Add("VitroModBellsLoaded", "VitroModBellScapes", VitroMod.bellScapeInit)