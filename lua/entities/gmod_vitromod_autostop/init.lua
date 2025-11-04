AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("alias.lua")
include("trig_init.lua")

function ENT:Initialize()
    self:SetNoDraw(true)

    if self.Trigger then
        SafeRemoveEntity(self.Trigger)
    end

    self:RetrieveSignal()

    self:CreateTrigger()
end

function ENT:CreateTrigger()
    local autostop = self
    self.Trigger = ents.Create("gmod_vitromod_astoptrig")
    self.Trigger:SetPos(self:LocalToWorld(Vector(50, 0, 0)))
    self.Trigger:SetAngles(self:GetAngles())
    function self.Trigger:StartTouch(ent)
        if not IsValid(ent) then return end
        if ent:GetClass() ~= "gmod_train_wheels" then return end

        local bogey = ent:GetNW2Entity("TrainBogey")
        if not IsValid(bogey) or not bogey:GetNW2Bool("IsForwardBogey") then return end
        local train = bogey:GetNW2Entity("TrainEntity")
        if not IsValid(train) or not train.SubwayTrain or (train.SubwayTrain.WagType ~= 1 and train.SubwayTrain.WagType ~= 0) then return end
        local dPos = self:WorldToLocal(bogey:GetPos()).y
        local right = dPos > 0 and bogey.SpeedSign == 1
        print("Autostop trigger touched by", ent:GetClass(), dPos, right)
        if right and autostop:GetNW2Bool("Closed") then
            train.Pneumatic:TriggerInput("Autostop", 0)
        end
    end

    self.Trigger:Spawn()
end

function ENT:OnRemove()
    SafeRemoveEntity(self.Trigger)
end

function ENT:Think()
    self:RetrieveSignal()

    if IsValid(self.Signal) then
        self:SetNW2Bool("Closed", self.Signal.Red)
    else
        self:SetNW2Bool("Closed", true)
    end

    self:NextThink(CurTime() + 0.2)
end

function ENT:RetrieveSignal()
    if self.config.SignalName and not IsValid(self.Signal) then
        self.Signal = Metrostroi.GetSignalByName(self.config.SignalName)
        self:SetSignal(self.Signal)
    end
end

function ENT:PlayAnim(dir)
    if not self.Inertial or self:GetNW2Bool("Closed") then return end
    self:SetNW2Bool("Dir", dir)
    self:SetNW2Bool("ToPlay", not self:GetNW2Bool("ToPlay"))
end

VitroMod.Devices.VitroModAutostop.atLook = function(trace, ply, settings)
    local autostop
    for k, v in pairs(ents.FindInSphere(trace.HitPos, 50)) do
        if v:GetClass() == "gmod_vitromod_autostop" then
            autostop = v
            break
        end
    end

    if not autostop then autostop = ents.Create("gmod_vitromod_autostop") end
    local pos = trace.HitPos
    local angles = Angle(0, 0, 0)
    local tr = Metrostroi.RerailGetTrackData(trace.HitPos, ply:GetAimVector())
    if tr then pos = tr.centerpos - tr.up * 9.5 end
    if tr then angles = (-tr.right):Angle() end
    autostop:SetPos(pos)
    autostop:SetAngles(angles)
    autostop:SetName(settings.Name or '')
    autostop:SetNW2String("Name", settings.Name or '')
    autostop.config = settings.config
    autostop:Spawn()

    undo.Create("VitroModAutostop")
    undo.AddEntity(autostop)
    undo.SetPlayer(ply)
    undo.Finish()
end

VitroMod.Devices.VitroModAutostop.remove = function(trace)
    for k, v in pairs(ents.FindInSphere(trace.HitPos, 50)) do
        if v:GetClass() == "gmod_vitromod_autostop" then v:Remove() end
    end
end

VitroMod.Devices.VitroModAutostop.flush = function()
    for k, v in pairs(ents.FindByClass("gmod_vitromod_autostop")) do
        SafeRemoveEntity(v)
    end
end
