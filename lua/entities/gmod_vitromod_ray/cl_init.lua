include('shared.lua')
VitroMod = VitroMod or {}
VitroMod.RayCap = VitroMod.RayCap or false
net.Receive('vitromod_ray_cap', function(len, ply) VitroMod.RayCap = net.ReadBool() end)
function ENT:HudName()
	if not self.Name then return end
	if not VitroMod.RayCap then return end
	local point = self:GetPos()
	local data2D = point:ToScreen() -- Gets the position of the entity on your screen
	if not data2D.visible then return end
	draw.SimpleText(self.Name, 'DermaLarge', data2D.x, data2D.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:LightSprites()
	if not self.LightSprite then return end
	self:Sprite(self.LightSprite.pos, self.LightSprite.ang, self.LightSprite.col, self.LightSprite.bri, self.LightSprite.mul)
end

function ENT:Sprite(pos, ang, col, bri, mul)
	if not self.PixVisibleHandler then self.PixVisibleHandler = util.GetPixelVisibleHandle() end
	if bri <= 0 then return end
	local Visible = util.PixelVisible(pos, 1, self.PixVisibleHandler)
	if Visible <= 0.1 then return end
	local fw = ang:Forward()
	local view = EyePos() - pos
	local dist = view:Length()
	view:Normalize()
	local viewdot = math.Clamp(view:Dot(fw), 0, 1)
	local s = Visible * viewdot * bri * math.Clamp(dist / 32, 64, 256) * mul
	render.SetMaterial(self.SpriteMat)
	render.DrawSprite(pos, s, s, col)
end

function ENT:Initialize(arguments)
	self.Name = self:GetNW2String('Name', 'Ray')
	self.DebugConvar = GetConVar('metrostroi_drawsignaldebug')
	self:InitializeRays()
	self:SetRenderBounds(self.LampOffset, self.SensorOffset)
	local ray = self
	hook.Add('HUDPaint', 'VitroMod.Rays.Caption' .. self:EntIndex(), function()
		-- if not IsValid(ray) then return end
		if ray:IsDormant() then return end
		ray:HudName()
	end)
	self.IdleColor = Color(255, 255, 255)
	self.ClearColor = Color(0, 255, 0)
	self.HitColor = Color(255, 0, 0)
end

function ENT:Think()
	if self:IsDormant() then
		self:OnRemove()
		return
	end

	self.PrevTime = self.PrevTime or RealTime()
	self.DeltaTime = RealTime() - self.PrevTime
	self.PrevTime = RealTime()
	if not self.ModelsCreated then
		self:CreateModels()
		self.ModelsCreated = true
	else
		local blink = RealTime() % 1.58 > 0.64
		local status = self:GetIsActive()
		local value = Either(status, 1, 0)
		local State = self:AnimateFade('PT', value, 0, 1, value and 128 or 64)
		self:UpdateProjectedTexture(State * 5)
	end
end

function ENT:Draw()
	if not self.DebugConvar:GetBool() then return end
	-- print('Drawing ray from ' .. tostring(startPos) .. ' to ' .. tostring(endPos))
	render.SetColorMaterial()
	render.DrawLine(self.LampOffsetWorld, self.SensorOffsetWorld, self:GetIsActive() and (self:GetHit() and self.HitColor or self.ClearColor) or self.IdleColor, true)
end

ENT.SpriteMat = Material('sprites/light_ignorez')
ENT.Anims = ENT.Anims or {}
ENT.LampColor = ENT.LampColor or Color(0, 0, 0, 0)
function ENT:CreateModels()
	self.Color = Color(0, 0, 0, 0)
	local sensorOffset = self.SensorOffset - self.InitialOffset
	local lampOffset = self.LampOffset
	local direction = (sensorOffset + self.InitialOffset - lampOffset):GetNormalized()
	local directionAngle = direction:Angle()
	self.ClientSideModels = {}
	for k, v in pairs(self.Models) do
		self.ClientSideModels[k] = ClientsideModel(v.Model)
		self.ClientSideModels[k]:SetParent(self)
		self.ClientSideModels[k]:Spawn()
		local offset = v.Offset or Vector(0, 0, 0)
		local angle = v.Angle or Angle(0, 0, 0)
		if v.Children then
			for childName, childData in pairs(v.Children) do
				local childModel = ClientsideModel(childData.Model, RENDERGROUP_OPAQUE)
				childModel:SetParent(self.ClientSideModels[k])
				childModel:SetRenderMode(RENDERMODE_TRANSCOLOR)
				childModel:Spawn()
				childModel:SetLocalPos(childData.Offset)
				childModel:SetLocalAngles(childData.Angle)
				childModel:SetNoDraw(true)
				if childData.Skin then childModel:SetSkin(childData.Skin) end
				self.ClientSideModels[childName] = childModel
			end
		end

		if k == 'Sensor' then
			offset = sensorOffset
			self.ClientSideModels[k]:AddCallback('BuildBonePositions', function(ent, numbones)
				local mat = ent:GetBoneMatrix(1)
				if not mat then return end
				-- x - across track,  y - vertical, z - along track
				mat:SetAngles(self:LocalToWorldAngles(Angle(0, 90 + directionAngle[2], 90 + directionAngle[1])))
				ent:SetBoneMatrix(1, mat)
			end)
		elseif k == 'Lamp' then
			offset = lampOffset
			angle = Angle(-directionAngle[1], 180 + directionAngle[2], 0)
		end

		local position = self:LocalToWorld(offset)
		local angles = self:LocalToWorldAngles(angle)
		self.ClientSideModels[k]:SetPos(position)
		self.ClientSideModels[k]:SetAngles(angles)
	end

	if not IsValid(self.PT) then self.PT = ProjectedTexture() end
	-- local angle = Angle(-directionAngle[1], 180 + directionAngle[2], 0)
	local lmpang = self:LocalToWorldAngles(Angle(-directionAngle[1], 180 + directionAngle[2], 0))
	local ptang = Angle(lmpang[1] + 180, lmpang[2], lmpang[3])
	local ptpos = self.ClientSideModels['Light']:GetPos()
	self:CreateProjectedTexture(ptpos, ptang)
	local ray = self
	hook.Add('PostDrawTranslucentRenderables', 'RaySprites_' .. self:EntIndex(), function() ray:LightSprites() end)
end

local function ColorLerp(color, brightness)
	local minBrightness = 0
	local maxBrightness = 5
	local t = math.Clamp((brightness - minBrightness) / (maxBrightness - minBrightness), 0, 1)
	color.r = Lerp(t, 255, 255)
	color.g = Lerp(t, 80, 200)
	color.b = Lerp(t, 40, 160)
	color.a = 255
end

function ENT:CreateProjectedTexture(position, angles, brightness)
	if not IsValid(self.PT) then self.PT = ProjectedTexture() end
	self.PT:SetPos(position)
	self.PT:SetAngles(angles)
	self.PT:SetEnableShadows(true)
	self.PT:SetTexture('effects/flashlight001')
	self.PT:SetFarZ(400)
	self.PT:SetFOV(3)
	self.PT:SetBrightness(0)
end

function ENT:UpdateProjectedTexture(brightness)
	if not self.Color then return end
	ColorLerp(self.Color, brightness)
	local lightModel = self.ClientSideModels['Light']
	self.LightSprite = {
		pos = lightModel:GetPos(),
		ang = lightModel:GetAngles(),
		bri = brightness / 12,
		col = self.Color,
		mul = 1
	}

	if IsValid(lightModel) then
		-- lightModel:SetSkin(1)
		lightModel:SetColor4Part(self.Color.r, self.Color.g + 20, self.Color.b + 20, brightness / 5 * 255)
		lightModel:SetNoDraw(brightness <= 0)
	end

	if IsValid(self.PT) then
		self.PT:SetBrightness(brightness)
		self.PT:SetColor(self.Color)
		self.PT:Update()
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
	self.ModelsCreated = false
end

function ENT:OnRemove()
	self:RemoveModels()
	hook.Remove('HUDPaint', 'VitroMod.Rays.Caption' .. self:EntIndex())
	hook.Remove('PostDrawTranslucentRenderables', 'RaySprites_' .. self:EntIndex())
end

function ENT:AnimateFade(clientProp, value, min, max, speed, damping, stickyness)
	local id = clientProp
	if not self.Anims[id] then
		self.Anims[id] = {}
		self.Anims[id].val = value
		self.Anims[id].V = 0.0
	end

	if damping == false then
		local dX = speed * self.DeltaTime
		if value > self.Anims[id].val then self.Anims[id].val = self.Anims[id].val + dX end
		if value < self.Anims[id].val then self.Anims[id].val = self.Anims[id].val - dX end
		if math.abs(value - self.Anims[id].val) < dX then self.Anims[id].val = value end
	else
		-- Prepare speed limiting
		local delta = math.abs(value - self.Anims[id].val)
		local max_speed = 1.5 * delta / self.DeltaTime
		local max_accel = 0.5 / self.DeltaTime
		-- Simulate
		local dX2dT = (speed or 128) * (value - self.Anims[id].val) - self.Anims[id].V * (damping or 8.0)
		if dX2dT > max_accel then dX2dT = max_accel end
		if dX2dT < -max_accel then dX2dT = -max_accel end
		self.Anims[id].V = self.Anims[id].V + dX2dT * self.DeltaTime
		if self.Anims[id].V > max_speed then self.Anims[id].V = max_speed end
		if self.Anims[id].V < -max_speed then self.Anims[id].V = -max_speed end
		self.Anims[id].val = math.max(0, math.min(1, self.Anims[id].val + self.Anims[id].V * self.DeltaTime))
		-- Check if value got stuck
		if (math.abs(dX2dT) < 0.001) and stickyness and (self.DeltaTime > 0) then self.Anims[id].stuck = true end
	end
	return min + (max - min) * self.Anims[id].val
end
