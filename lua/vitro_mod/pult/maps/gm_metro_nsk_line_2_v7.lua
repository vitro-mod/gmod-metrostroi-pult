VitroMod.Pult.Map = {
    Init = function()
        VitroMod.Pult.SwitchesInvert = {}
        local renameTable = {
            {
                gm = 'zn_switch1',
                pult = 'trackswitch_zn1'
            },
            {
                gm = 'zn_switch4',
                pult = 'trackswitch_zn2'
            },
            {
                gm = 'trackswitch_pg1',
                pult = 'trackswitch_gm1'
            },
            {
                gm = 'trackswitch_pg2',
                pult = 'trackswitch_gm2'
            },
        }

        for _, r in pairs(renameTable) do
            for k, v in pairs(ents.FindByName(r.gm)) do
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
    OnSwitch = function(name, to) end,
    OnConnect = function()
        VitroMod.Pult.GermoGates.Init(ents.FindByName('gate_*'))
        for k, ent in pairs(ents.FindByClass('gmod_track_signal_controller')) do
            if not IsValid(ent) then continue end
            if not IsValid(ent.SignalEntity) then continue end
            ent.SignalEntity.Controllers = {}
            ent:Remove()
        end

        local cleanup = {
            byClass = {
                wildcards = {'trigger_multiple'},
                exclude = {},
                excludeNames = {'adminlock', 'ukpt'},
            },
        }

        for _, c in pairs(cleanup.byClass.wildcards) do
            for k, v in pairs(ents.FindByClass(c)) do
                if cleanup.byClass.exclude[v:GetClass()] ~= nil then continue end
                for k2, nameToExclude in pairs(cleanup.byClass.excludeNames) do
                    if string.find(v:GetName(), nameToExclude) then goto continue2 end
                end

                SafeRemoveEntity(v)
                ::continue2::
            end
        end
    end
}