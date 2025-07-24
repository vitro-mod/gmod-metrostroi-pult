ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.AdminOnly   = true
ENT.Spawnable   = true
ENT.PrintName   = "Light Ray"
ENT.Purpose     = "Light Ray Sensor"

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
    self:NetworkVar("Bool", 0, "IsActive")
end
