AddCSLuaFile( 'cl_init.lua' )
ENT.Type            = "brush"
ENT.Base            = "base_brush"
VitroMod = VitroMod or {}
VitroMod.Triggers = VitroMod.Triggers or {}
VitroMod.Triggers.console = false
util.AddNetworkString("vitromod_trigger")
util.AddNetworkString("vitromod_trigger_one")
util.AddNetworkString("vitromod_trigger_draw")

function ENT:Initialize() 

	VitroMod.Triggers.Entities = VitroMod.Triggers.Entities or {}
	VitroMod.Triggers.Count = VitroMod.Triggers.Count or {}
	self:SetSolid( SOLID_OBB )
	self:SetTrigger( true )
	self.cnt = 0
	VitroMod.Triggers.Count = VitroMod.Triggers.Count or {}	
	VitroMod.Triggers.Count[self:GetName()] = 0
	VitroMod.Triggers.Entities[self:GetName()] = VitroMod.Triggers.Entities[self:GetName()] or {}
	if self.num == nil then 
		self.num = table.insert(VitroMod.Triggers.Entities[self:GetName()], self)
	else
		table.insert(VitroMod.Triggers.Entities[self:GetName()], self.num ,self)
	end
	if self.min and self.max then self:SetCollisionBounds(self.min,self.max) end
	util.AddNetworkString("vitromod_trigger")
	util.AddNetworkString("vitromod_trigger_one")
	util.AddNetworkString("vitromod_trigger_draw")
end

function ENT:StartTouch(entity)

	if entity:GetClass() ~= 'gmod_train_wheels' then return false end

	if VitroMod.Triggers.Count[self:GetName()] == 0 then hook.Run("VitroMod_Trigger_Update",nil,self,1) end
	self.occ = true
	VitroMod.Triggers.Count[self:GetName()] = VitroMod.Triggers.Count[self:GetName()] + 1
	VitroMod.trigSend(self)
end

function ENT:EndTouch(entity)

	if entity:GetClass() ~= 'gmod_train_wheels' then return false end
	
	VitroMod.Triggers.Count[self:GetName()] = VitroMod.Triggers.Count[self:GetName()] - 1
	if VitroMod.Triggers.Count[self:GetName()] == 0 then
		self.occ = false
		-- if rcNames then SendRCInfo(nil,self,0) end
		if rcNames then hook.Run("VitroMod_Trigger_Update",nil,self,0) end
	end
	VitroMod.trigSend(self)
end

scripted_ents.Register(ENT, "gmod_vitromod_trigger")

VitroMod.trigAtLook = function(name)
	local melon = ents.Create( "gmod_vitromod_trigger" ) -- Spawn prop
	if ( !IsValid( melon ) ) then return end -- Safety first
	melon:SetPos( Entity(1):GetEyeTrace().HitPos ) -- Set pos where is player looking
	melon:SetAngles(Entity(1):GetAngles())
	melon:SetAngles(Angle(0,0,0))
	melon:SetName(name)
	local cbMin = Vector(-20,-40,-10)
	local cbMax = Vector(20,40,10)
	melon:SetCollisionBounds(cbMin,cbMax)
	melon:Spawn() -- Instantiate prop
	VitroMod.trigSendAll()
end

VitroMod.moveTrig = function(name, num, pos,ang)
	if not pos then return false end
	VitroMod.Triggers = VitroMod.Triggers or {}
	VitroMod.Triggers.Entities = VitroMod.Triggers.Entities or {}	
	VitroMod.Triggers.Entities[name] = VitroMod.Triggers.Entities[name] or {}
	local needToSpawn = false
	local cbMin = Vector(-20,-40,-10)
	local cbMax = Vector(20,40,10)
	if not VitroMod.Triggers.Entities[name][num] then 
		needToSpawn = true
		melon = ents.Create( "gmod_vitromod_trigger" )
		if ( !IsValid( melon ) ) then return end
		melon:SetName(name)
		melon.min = cbMin
		melon.max = cbMax
	else
		melon = VitroMod.Triggers.Entities[name][num]		
	end
	local s = Vector(0,40,0)
	if ang then
		s:Rotate(ang)
	end
	local spPos = pos + s
	melon:SetPos(spPos)
	melon.beg = pos
	melon.fin = spPos + s
	if ang then
		melon:SetAngles(ang)
	end
	if not needToSpawn then melon:SetCollisionBounds(cbMin,cbMax) end
	if needToSpawn then melon:Spawn() end
	--VitroMod.trigSendAll()
	VitroMod.trigSend(melon)
end

VitroMod.setTrigEnd = function(name, num, pos)
	if not VitroMod.Triggers.Entities[name] then return false end
	if not VitroMod.Triggers.Entities[name][num] then return false end
	if not pos then return false end
	local ent = VitroMod.Triggers.Entities[name][num]
	local beg = ent.beg
	local dist = beg:Distance(pos)
	local cent = beg + (pos - beg) / 2
	local nang = ((pos - beg):Angle()) - Angle(0,90,0)
	local nMin = Vector(-20, -(dist / 2), -10)
	local nMax = Vector(20, dist / 2, 10)
	ent:SetPos(cent)
	ent.fin = pos
	ent:SetAngles(nang)
	ent:SetCollisionBounds(nMin,nMax)
	--VitroMod.trigSendAll()
	VitroMod.trigSend(ent)
end

VitroMod.trigFlush = function()
	for k,v in pairs(ents.FindByClass('gmod_vitromod_trigger')) do
		SafeRemoveEntity(v)
	end
	local sc = VitroMod.Triggers.sendToClient
	VitroMod.Triggers = {}
	VitroMod.Triggers.sendToClient = sc
	VitroMod.Triggers.Entities = {}
	VitroMod.Triggers.Count = {}
	VitroMod.trigSendAll()
end

VitroMod.trigRemove = function(name, num)
	print(name, num)
	if not name then return false end
	if not VitroMod.Triggers.Entities[name] then return true end
	VitroMod.Triggers.ClientData = VitroMod.Triggers.ClientData or {}
	if num == nil then
		for k,v in pairs(VitroMod.Triggers.Entities[name]) do
			SafeRemoveEntity(v)
		end
		VitroMod.Triggers.Entities[name] = nil
		VitroMod.Triggers.ClientData[name] = nil
	else
		SafeRemoveEntity(VitroMod.Triggers.Entities[name][num])
		VitroMod.Triggers.Entities[name][num] = nil
		VitroMod.Triggers.ClientData[name] = VitroMod.Triggers.ClientData[name] or {}
		VitroMod.Triggers.ClientData[name][num] = nil
		if #VitroMod.Triggers.Entities[name] == 0 then
			VitroMod.Triggers.Entities[name] = nil
		end
	end
	VitroMod.Triggers.Count[name] = nil
	--VitroMod.trigSendAll()
	net.Start("vitromod_trigger_one")
	net.WriteString(name)
	net.WriteTable({})
	net.Broadcast()	
end
VitroMod.trigSend = function(ent)
	if not VitroMod.Triggers.sendToClient then return false end
	if not ent then return false end
	if not VitroMod.NWAddedOne then util.AddNetworkString("vitromod_trigger_one") end
	VitroMod.NWAddedOne = true
	VitroMod.Triggers.ClientData = VitroMod.Triggers.ClientData or {}
	local name = ''
	if ent and ent.num then
		local clMin, clMax = ent:GetCollisionBounds()
		name = ent:GetName()
		VitroMod.Triggers.ClientData[name] = VitroMod.Triggers.ClientData[name] or {}
		VitroMod.Triggers.ClientData[name][ent.num] = {min = clMin, max = clMax, angle = ent:GetAngles(), pos = ent:GetPos(), num = ent.num, beg = ent.beg, fin = ent.fin, occ = ent.occ}	
		VitroMod.Triggers.ClientData[name].occ = VitroMod.Triggers.Count[name] ~= 0
	end
	net.Start("vitromod_trigger_one")
	net.WriteString(name)
	net.WriteTable(VitroMod.Triggers.ClientData[name])
	net.Broadcast()	
end
VitroMod.trigSendAll = function()
	if not VitroMod.Triggers.sendToClient then return false end
	if not VitroMod.NWAdded then util.AddNetworkString("vitromod_trigger") end
	VitroMod.NWAdded = true
	VitroMod.Triggers.ClientData = VitroMod.Triggers.ClientData or {}
	--VitroMod.Triggers.ClientData = {}
	for k,v in pairs(VitroMod.Triggers.Entities) do
		for k2,v2 in pairs(VitroMod.Triggers.Entities[k]) do
			local name = k
			local ent = v2
			local num = v2.num
			local clMin, clMax = ent:GetCollisionBounds()			
			--VitroMod.Triggers.ClientData[name] = {}
			VitroMod.Triggers.ClientData[name] = VitroMod.Triggers.ClientData[name] or {}
			VitroMod.Triggers.ClientData[name][ent.num] = {min = clMin, max = clMax, angle = ent:GetAngles(), pos = ent:GetPos(), num = ent.num, beg = ent.beg, fin = ent.fin, occ = ent.occ}	
			VitroMod.Triggers.ClientData[name].occ = VitroMod.Triggers.Count[name] ~= 0
		end
	end
	net.Start("vitromod_trigger")
	--PrintTable(VitroMod.Triggers.ClientData)
	net.WriteTable(VitroMod.Triggers.ClientData)
	net.Broadcast()
end
VitroMod.trigSendFlush = function()
	net.Start("vitromod_trigger")
	net.WriteTable({})
	net.Broadcast()		
end
VitroMod.trigInit = true
concommand.Add("vitromod_trigger_td", function( ply, cmd, args )
	if not ply:IsAdmin() then return false end
	if not VitroMod.NWAddedDraw then util.AddNetworkString("vitromod_trigger_draw") end
	VitroMod.NWAddedDraw = true
    VitroMod.Triggers.sendToClient = not VitroMod.Triggers.sendToClient
	net.Start("vitromod_trigger_draw")
	net.WriteBool(VitroMod.Triggers.sendToClient)
	net.Broadcast()
	if VitroMod.Triggers.sendToClient then VitroMod.trigSendAll() end
end)