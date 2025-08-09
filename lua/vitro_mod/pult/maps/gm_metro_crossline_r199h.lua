VitroMod.Pult.Map = {
    Init = function()
        VitroMod.Pult.SwitchesInvert = {}
        VitroMod.Pult.SwitchesInvert['md3'] = true
        VitroMod.Pult.SwitchesInvert['md4'] = true
    end,
    OnSwitch = function(name, to) end,
    OnConnect = function() VitroMod.Pult.GermoGates.Init(ents.FindByName('metalgate_*'), true) end
}
