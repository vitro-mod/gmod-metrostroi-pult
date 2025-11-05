ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.AdminOnly = true
ENT.Spawnable = false
ENT.PrintName = "Autostop"
ENT.Purpose = "Autostop"

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Signal")
end

VitroMod = VitroMod or {}
VitroMod.Devices = VitroMod.Devices or {}
VitroMod.Devices.VitroModAutostop = {
    name = "VitroModAutostop",
    class = "gmod_vitromod_autostop",
    config = {
        {
            name = "Signal name",
            varName = "SignalName",
            varType = "text",
            offset = Vector(0,0,9.5-1.5-1.5),
        },
    },
}
