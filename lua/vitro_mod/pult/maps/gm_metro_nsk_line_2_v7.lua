VitroMod.Pult.Map = {
    Init = function()
        VitroMod.Pult.SwitchesInvert = {}

        local renameTable = {
            {gm = 'zn_switch1', pult = 'trackswitch_zn1'},
            {gm = 'zn_switch4', pult = 'trackswitch_zn2'},
            {gm = 'trackswitch_pg1', pult = 'trackswitch_gm1'},
            {gm = 'trackswitch_pg2', pult = 'trackswitch_gm2'},
        }
        for _,r in pairs(renameTable) do
            for k,v in pairs(ents.FindByName(r.gm)) do
                v:SetName(r.pult)
            end
        end

        rcASNP['TC277'] = true
        rcASNP['TC377'] = true
        rcASNP['TC477'] = true
        rcASNP['TC577'] = true
        rcASNP['TC677'] = true

        rcASNP['TC378'] = true
        rcASNP['TC478'] = true
        rcASNP['TC578'] = true
        rcASNP['TC678'] = true
        rcASNP['TC778'] = true
    end,
    OnSwitch = function(name, to)
    end,
    OnConnect = function()
        VitroMod.Pult.GermoGates.Init(ents.FindByName('gate_*'))
    end
}
