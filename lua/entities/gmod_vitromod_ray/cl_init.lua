include('shared.lua')

VitroMod = VitroMod or {}
VitroMod.Rays = VitroMod.Rays or {}
VitroMod.RayCap = VitroMod.RayCap or false
net.Receive("vitromod_ray_data", function(len, ply)
    VitroMod.Rays = net.ReadTable()
	for k,v in pairs(ents.FindByClass('gmod_vitromod_ray')) do
		v:RemoveModels()
		v.ModelsCreated = false
	end
end)

net.Receive("vitromod_ray_cap", function(len, ply)
    VitroMod.RayCap = net.ReadBool()
end)

net.Receive("vitromod_ray", function(len, ply)
	local rec = net.ReadTable()
	if VitroMod.Rays[rec.name] ~= nil then
		VitroMod.Rays[rec.name]['status'] = rec.status
	end
end)

local function hudName(name, ent)
	if not ent then return end
	if not VitroMod.RayCap then return end

	--for name,ent in pairs( VitroMod.Rays ) do
		local point = ent.pos
		local data2D = point:ToScreen() -- Gets the position of the entity on your screen
		if ( not data2D.visible ) then return end
		draw.SimpleText( name , "DermaLarge", data2D.x, data2D.y, Color( ent.status and 0 or 255, 255, ent.status and 0 or 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	--end
end

function ENT:Initialize(arguments)
    -- print('a')
end

function ENT:Think()
	self.name = self.name or self:GetNW2String('Name')
	if not VitroMod.Rays[self.name] then return false end
	local status = VitroMod.Rays[self.name].status
	-- --&& LocalPlayer():GetPos():DistToSqr( self:GetPos() ) > 7200*7200 )
	-- if self:IsDormant()  or not status or self.Removing then 
	-- 	self:Stop()
	-- else
	-- 	self:Play()
	-- end
	
	if self:IsDormant() then 
		hook.Remove( "HUDPaint", "VitroMod.Rays.Caption"..self:EntIndex())
	else
		hook.Add( "HUDPaint", "VitroMod.Rays.Caption"..self:EntIndex(), function() hudName(self.name, VitroMod.Rays[self.name]) end)
	end

    if not self.ModelsCreated then 
        self:CreateModels()
        self.ModelsCreated = true
    end
end

function ENT:Draw()
    -- self:DrawModel()
  end

ENT.Models = {
    ["Lamp"] = {["Model"] = "models/mn_signs/light_sensor_emitter.mdl", ["Offset"] = Vector(0,80,40), ["Angle"] = Angle(0,90,0)},
    ["Sensor"] = {["Model"] = "models/mn_signs/light_sensor.mdl", ["Offset"] = Vector(94,-15,-30), ["Angle"] = Angle(0,-90,0)},
    ["Light"] = {["Model"] = "models/mus/direction_lamp_w.mdl", ["Offset"] = Vector(0,80-1.7,40+2), ["Angle"] = Angle(0,-90,0)},
}

function ENT:CreateModels()
    self.ClientSideModels = {}
    for k,v in pairs(self.Models) do
        self.ClientSideModels[k] = ClientsideModel(v.Model)
		local pos = Vector(v.Offset:Unpack())
		pos:Rotate(self:GetAngles())
        self.ClientSideModels[k]:SetPos(self:GetPos() + pos)
        self.ClientSideModels[k]:SetAngles(self:GetAngles() + v.Angle)
        self.ClientSideModels[k]:Spawn()
    end
end

function ENT:RemoveModels()
    for k,v in pairs(self.ClientSideModels) do
        SafeRemoveEntity(self.ClientSideModels[k])
        self.ClientSideModels[k] = nil
    end
    self.ClientSideModels = {}
end

function ENT:OnRemove()
	self:RemoveModels()
end
