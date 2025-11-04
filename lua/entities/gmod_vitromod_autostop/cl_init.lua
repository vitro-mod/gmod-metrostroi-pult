include("shared.lua")

function ENT:Initialize()
    self.AnimState = 0
    self.Pitch = math.random(75, 110)
end

function ENT:Think()
    if self:IsDormant() then return self:OnRemove() end
    self.PrevTime = self.PrevTime or RealTime()
    self.DeltaTime = RealTime() - self.PrevTime
    self.PrevTime = RealTime()
    if not self.ModelsCreated or not IsValid(self.Model) then
        self.ModelsCreated = self:CreateModels()
        return
    end

    local state = self:GetNW2Bool("Closed")
    self.Model:SetPoseParameter("position", self:Animate(state and 1 or 0, 0, 1, 0.4))
end

function ENT:Animate(value, min, max, speed)
    local dX = speed * self.DeltaTime
    if value > self.AnimState then self.AnimState = self.AnimState + dX end
    if value < self.AnimState then self.AnimState = self.AnimState - dX end
    if math.abs(value - self.AnimState) < dX then self.AnimState = value end
    return min + (max - min) * self.AnimState
end

function ENT:CreateModels()
    local signal = self:GetSignal()
    if not IsValid(signal) then return false end
    if signal.LightType == nil then return false end
    self.Model = ClientsideModel(signal.AutostopModel[signal.LightType][1], RENDERGROUP_OPAQUE)
    local pos = signal.BasePos[signal.LightType] + signal.AutostopModel[signal.LightType][2]
    self.Model:SetPos(self:LocalToWorld(pos))
    self.Model:SetAngles(self:GetAngles())
    self.Model:SetParent(self)
    return true
end

function ENT:OnRemove()
    SafeRemoveEntity(self.Model)
    self.ModelsCreated = false
end
