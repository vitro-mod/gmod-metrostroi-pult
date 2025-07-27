ENT.Type = 'anim'
ENT.Base = 'base_gmodentity'

ENT.AdminOnly   = true
ENT.Spawnable   = true
ENT.PrintName   = 'Light Ray'
ENT.Purpose     = 'Light Ray Sensor'

ENT.InitialOffset = Vector(0, -82.3, 67.9)
-- ENT.InitialOffset = Vector(0, 0, 0 )
ENT.Models = {
    ['Lamp'] = {
        ['Model'] = 'models/mn_signs/light_sensor_emitter.mdl',
        ['Offset'] = Vector(0, 80, 40),
        -- ['Offset'] = Vector(0, 0, 0),
        ['Angle'] = Angle(0, 90, 0),
        ['Children'] = {
            ['Light'] = {
                ['Model'] = 'models/mus/direction_lamp_w.mdl',
                ['Offset'] = Vector(-1.65, 0, 2.05),
                ['Angle'] = Angle(0, 180, 0),
                ['Skin'] = 1,
            }
        }
    },
    ['Sensor'] = {
        ['Model'] = 'models/mn_signs/light_sensor.mdl',
        ['Offset'] = Vector(-94, -15, -30),
        ['Angle'] = Angle(0, -90, 0)
    },
}

function ENT:SetupDataTables()
    self:NetworkVar('Bool', 0, 'IsActive')
    self:NetworkVar('Bool', 1, 'Hit')
    self:NetworkVar('Int', 0, 'TrackID')
    self:NetworkVar('Float', 0, 'TrackX')
    self:NetworkVar('Float', 1, 'SensorXOffset')
    self:NetworkVar('Float', 2, 'SensorZOffset')
    self:NetworkVar('Float', 3, 'LampXOffset')
    self:NetworkVar('Float', 4, 'LampZOffset')
end

function ENT:InitializeRays()
    -- print('Initializing rays for ' .. self.Name)
    self.LampOffset = self:GetLampOffset()
    self.SensorOffset = self:GetSensorOffset() + self.InitialOffset
    self.Direction = self:GetDirection()
    self.LampOffsetWorld = self:LocalToWorld(self.LampOffset)
    self.SensorOffsetWorld = self:LocalToWorld(self.SensorOffset)
end

function ENT:GetLampOffset()
    local lampXOffset = self:GetLampXOffset() or 0
    local lampZOffset = self:GetLampZOffset() or 0
    local lampOffset = self.Models['Lamp'].Offset + Vector(0, -lampXOffset, lampZOffset)
    return lampOffset
end

function ENT:GetSensorOffset()
    local sensorXOffset = self:GetSensorXOffset() or 0
    local sensorZOffset = self:GetSensorZOffset() or 0
    local sensorOffset = self.Models['Sensor'].Offset + Vector(0, -sensorXOffset, sensorZOffset)
    return sensorOffset
end

function ENT:GetDirection()
    local sensorOffset = self:GetSensorOffset()
    local lampOffset = self:GetLampOffset()
    local direction = (sensorOffset - lampOffset):GetNormalized()
    return direction
end
