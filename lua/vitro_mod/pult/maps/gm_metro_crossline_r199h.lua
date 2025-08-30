VitroMod.Pult.Map = {
    Init = function()
        VitroMod.Pult.SwitchesInvert = {}
        VitroMod.Pult.SwitchesInvert['md3'] = true
        VitroMod.Pult.SwitchesInvert['md4'] = true
        VitroMod.Pult.SwitchesInvert['ok3'] = true
        VitroMod.Pult.SwitchesInvert['ok4'] = true
        VitroMod.Pult.SwitchesInvert['ok5'] = true
        VitroMod.Pult.SwitchesInvert['ok6'] = true
        VitroMod.Pult.SwitchesInvert['d38'] = true
        VitroMod.Pult.SwitchesInvert['d26'] = true
        VitroMod.Pult.SwitchesInvert['d28'] = true
        VitroMod.Pult.SwitchesInvert['d19'] = true
    end,
    OnSwitch = function(name, to) end,
    OnConnect = function()
        VitroMod.Pult.GermoGates.Init(ents.FindByName('metalgate_*'), true)
        local cleanup = {
            byName = {
                wildcards = {'wt_*'},
                exclude = {},
            },
        }

        for _, c in pairs(cleanup.byName.wildcards) do
            for k, v in pairs(ents.FindByName(c)) do
                if cleanup.byName.exclude[v:GetName()] ~= nil then continue end
                SafeRemoveEntity(v)
            end
        end
    end
}
