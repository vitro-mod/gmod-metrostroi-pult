include('shared.lua')
VitroMod = VitroMod or {}
VitroMod.Rays = VitroMod.Rays or {}
VitroMod.RayCap = VitroMod.RayCap or false
net.Receive('vitromod_ray_data', function(len, ply)
	VitroMod.Rays = net.ReadTable()
	for k, v in pairs(ents.FindByClass('gmod_vitromod_ray')) do
		v:RemoveModels()
		v.ModelsCreated = false
	end
end)

net.Receive('vitromod_ray_cap', function(len, ply) VitroMod.RayCap = net.ReadBool() end)
net.Receive('vitromod_ray', function(len, ply)
	local rec = net.ReadTable()
	if VitroMod.Rays[rec.name] ~= nil then VitroMod.Rays[rec.name]['status'] = rec.status end
end)

local function hudName(name, ent)
	if not ent then return end
	if not VitroMod.RayCap then return end
	--for name,ent in pairs( VitroMod.Rays ) do
	local point = ent.pos
	local data2D = point:ToScreen() -- Gets the position of the entity on your screen
	if not data2D.visible then return end
	draw.SimpleText(name, 'DermaLarge', data2D.x, data2D.y, Color(ent.status and 0 or 255, 255, ent.status and 0 or 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	--end
end

-- function ENT:Initialize(arguments)
-- end
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
		hook.Remove('HUDPaint', 'VitroMod.Rays.Caption' .. self:EntIndex())
	else
		hook.Add('HUDPaint', 'VitroMod.Rays.Caption' .. self:EntIndex(), function() hudName(self.name, VitroMod.Rays[self.name]) end)
	end

	if not self.ModelsCreated then
		self:CreateModels()
		self.ModelsCreated = true
	end
end

function ENT:Draw()
	-- self:DrawModel()
end

ENT.InitialOffset = Vector(0, -78, 67.9 + 3)
ENT.Models = {
	['Lamp'] = {
		['Model'] = 'models/mn_signs/light_sensor_emitter.mdl',
		['Offset'] = Vector(0, 80, 40),
		['Angle'] = Angle(0, 90, 0)
	},
	['Sensor'] = {
		['Model'] = 'models/mn_signs/light_sensor.mdl',
		['Offset'] = Vector(-94, -15, -30),
		['Angle'] = Angle(0, -90, 0)
	},
	['Light'] = {
		['Model'] = 'models/mus/direction_lamp_w.mdl',
		['Offset'] = Vector(0, -1.7, 2),
		['Angle'] = Angle(0, -90, 0)
	},
}

function ENT:CreateModels()
	local sensorOffset = self.Models['Sensor'].Offset + Vector(0, -(VitroMod.Rays[self.name].options.sensorXOffset or 0), VitroMod.Rays[self.name].options.sensorZOffset or 0)
	-- local sensorOffset = self.Models['Sensor'].Offset
	local lampOffset = self.Models['Lamp'].Offset + Vector(0, -(VitroMod.Rays[self.name].options.lampXOffset or 0), VitroMod.Rays[self.name].options.lampZOffset or 0)
	-- local lampOffset = self.Models['Lamp'].Offset
	local direction = (self.InitialOffset + sensorOffset - lampOffset):GetNormalized()
	local directionAngle = direction:Angle()
	-- print('Direction:', direction)
	-- print('Direction Angle:', directionAngle)
	self.ClientSideModels = {}
	for k, v in pairs(self.Models) do
		self.ClientSideModels[k] = ClientsideModel(v.Model)
		self.ClientSideModels[k]:SetParent(self)
		self.ClientSideModels[k]:Spawn()
		local offset = v.Offset or Vector(0, 0, 0)
		local angle = v.Angle or Angle(0, 0, 0)
		if k == 'Sensor' then
			offset = sensorOffset
			self.ClientSideModels[k]:AddCallback('BuildBonePositions', function(ent, numbones)
				local mat = ent:GetBoneMatrix(1)
				if not mat then return end
				-- x - across track
				-- y - vertical
				-- z - along track
				mat:SetAngles(self:LocalToWorldAngles(Angle(0, 90 + directionAngle[2], 90 + directionAngle[1])))
				ent:SetBoneMatrix(1, mat)
			end)
		elseif k == 'Lamp' then
			offset = lampOffset
			angle = Angle(-directionAngle[1], 180 + directionAngle[2], 0)
		elseif k == 'Light' then
			if not IsValid(self.PT) then self.PT = ProjectedTexture() end
			self.PT:SetPos(self.ClientSideModels['Lamp']:GetPos())
			local lmpang = self.ClientSideModels['Lamp']:GetAngles()
			self.PT:SetAngles(Angle(lmpang[1] + 180, lmpang[2], lmpang[3]))
			self.PT:SetEnableShadows(true)
			self.PT:SetTexture('effects/flashlight001')
			self.PT:SetColor(Color(255, 255, 255))
			self.PT:SetFarZ(300)
			self.PT:SetFOV(3)
			self.PT:SetBrightness(5)
			self.PT:Update()
		end

		local position = self:LocalToWorld(offset)
		local angles = self:LocalToWorldAngles(angle)
		self.ClientSideModels[k]:SetPos(position)
		self.ClientSideModels[k]:SetAngles(angles)
	end
end

function ENT:RemoveModels()
	if IsValid(self.PT) then self.PT:Remove() end
	if not self.ClientSideModels then return end
	for k, v in pairs(self.ClientSideModels) do
		SafeRemoveEntity(self.ClientSideModels[k])
		self.ClientSideModels[k] = nil
	end

	self.ClientSideModels = {}
end

function ENT:OnRemove()
	self:RemoveModels()
end