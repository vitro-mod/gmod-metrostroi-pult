VitroMod.Pult.Map = {
    Init = function()
        rcASNP['TCMD5CH'] = true
        rcASNP['TCMD6CH'] = true
        rcASNP['TC516'] = true
        rcASNP['TC5'] = true
        rcASNP['TC6'] = true
        rcASNP['A3'] = true
        rcASNP['A4'] = true
        rcASNP['TCOL3A'] = true
        rcASNP['TCML5N'] = true
        rcASNP['TCML6N'] = true
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
        VitroMod.Pult.SwitchesInvert['ml3'] = true
        VitroMod.Pult.SwitchesInvert['ml4'] = true
        local intervalRemap = {
            { coords = Vector(1212, 1508, 2026), name = 'md2p' },
            { coords = Vector(4867, -3649, 2020), name = 'md1p' },
            { coords = Vector(-1086, 15010, 2287), name = 'pk2p' },
            { coords = Vector(5203, 14197, 2288), name = 'pk1p' },
            { coords = Vector(14845, 5407, 3095), name = 'pt2p' },
            { coords = Vector(14667, 5417, 3062), name = 'pt2p' },
            { coords = Vector(14238, -776, 3142), name = 'pt1p' },
            { coords = Vector(3253, 4339, 1945), name = 'ps1p' },
            { coords = Vector(1255, 10533, 1945), name = 'ps2p' },
            { coords = Vector(9543, -3536, 1091), name = 'nh2p' },
            { coords = Vector(10284, 3681, 1100), name = 'nh1p' },
            { coords = Vector(-3028, -8771, -153), name = 'ok2p' },
            { coords = Vector(2081, -5145, -158), name = 'ok1p' },
            { coords = Vector(3894, -13685, 494), name = 'rx1p' },
            { coords = Vector(-1969, -11195, 495), name = 'rx2p' },
            { coords = Vector(7359, -16264, -750), name = 'pr1p' },
            { coords = Vector(962, -15495, -753), name = 'pr2p' },
            { coords = Vector(3561, -8771, -1274), name = 'ol1p' },
            { coords = Vector(-1880, -11764, -1272), name = 'ol2p' },
            { coords = Vector(-10790, 7699, -1315), name = 'kr1p' },
            { coords = Vector(-13416, -2860, -2284), name = 'ml2p' },
            { coords = Vector(-9538, 2286, -2283), name = 'ml1p' },
        }

        for _, r in pairs(intervalRemap) do
            for _, v in pairs(ents.FindInSphere(r.coords, 50)) do
                if v:GetClass() ~= 'gmod_track_clock_small' and v:GetClass() ~= 'gmod_track_clock_interval' then continue end
                v:SetName(r.name)
            end
        end
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