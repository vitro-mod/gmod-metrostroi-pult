VitroMod = VitroMod or {}
VitroMod.Pult = VitroMod.Pult or {}

VitroMod.Pult.HandleMessage = function(txt)
    --RunConsoleCommand('say','READ :: ',txt) -- debug.debug
    if string.sub(txt, 1, 2) == 'SW' then
        for k, v in pairs(string.Explode(';', txt)) do
            if v ~= '' then
                local name = string.sub(string.Explode('_', v)[1], 3)
                local pos = string.Explode('_', v)[2]
                local to
                if VitroMod.Pult.SwitchesInvert[name] ~= nil then
                    to = pos == '+'
                else
                    to = pos ~= '+'
                end

                sw(name, to)
                VitroMod.Pult.Map.OnSwitch(name, to)
                VitroMod.Pult.GermoGates.Switch(name, to)
            end
        end
    elseif string.sub(txt, 1, 2) == 'EP' then
        for k, v in pairs(string.Explode(';', txt)) do
            if v == '' then continue end
            local name = string.sub(string.Explode('_', v)[1], 3)
            swEpk(name)
        end
    elseif string.sub(txt, 1, 2) == 'LT' then
        local ltmtMsg = string.Explode(':', txt)
        for k, v in pairs(string.Explode(';', ltmtMsg[1])) do
            --RunConsoleCommand('say',string.Explode('-',v)[1],string.Explode('-',v)[2])
            local signalParams = string.Explode('-', v)
            local signalName = signalParams[1]
            local signal = Metrostroi.GetSignalByName(signalName)
            if signal then
                signal.ControllerLogic = true
                signal.Sig = tostring(signalParams[2])
                signal:SetNW2String('Signal', signal.Sig)
                signal.Red = tobool(signalParams[3])
                signal.AutoEnabled = not tobool(signalParams[4])
                signal:SetNW2Bool('Autostop', signal.AutoEnabled)
                signal.ControllerLogicCheckOccupied = true
            end
        end
    elseif string.sub(txt, 1, 2) == 'RT' then
        local ltmtMsg = txt --string.Explode(':',txt)
        --RunConsoleCommand('say',txt)
        for k, v in pairs(string.Explode(';', ltmtMsg)) do
            --RunConsoleCommand('say',string.Explode('-',v)[1],string.Explode('-',v)[2])
            local signal = Metrostroi.GetSignalByName(string.Explode('-', v)[1])
            if signal then
                signal.ControllerLogic = true
                signal.RouteNumberReplace = tostring(string.Explode('-', v)[2])
                signal:SetNW2String('Number', signal.RouteNumberReplace)
            end

            local pointer = ents.FindByName(string.Explode('-', v)[1])[1]
            if pointer and pointer:GetClass() == 'gmod_vitromod_pointer' then pointer:SetNW2String('State', tostring(string.Explode('-', v)[2])) end
        end
    elseif string.sub(txt, 1, 2) == 'MK' and Minsk and Minsk.MK then
        local ltmtMsg = txt
        for k, v in pairs(string.Explode(';', ltmtMsg)) do
            local MKName = string.Explode('-', v)[1]
            local check = string.Explode('-', v)[2]
            if check == '0' then
                Minsk.MK.Unlock(MKName)
            elseif check == '1' then
                Minsk.MK.Lock(MKName)
            end
        end
    elseif string.sub(txt, 1, 2) == 'FR' then
        local ltmtMsg = string.sub(txt, 3)
        for _, v in pairs(string.Explode(';', ltmtMsg)) do
            if v then
                local signBoxName = string.Explode('_', v)[1]
                local signBoxFreq = string.Explode('_', v)[2]
                --local signBoxNextFreq = string.Explode('_',v)[3]
                local signBoxFreeBS = string.Explode('_', v)[3]
                local signal = Metrostroi.GetSignalByName(signBoxName)
                if signal then
                    signal.ControllerLogic = true
                    signal.ControllerLogicOverride325Hz = true
                    signal.ControllerLogicCheckOccupied = true
                    signal.ARSSpeedLimit = tonumber(signBoxFreq)
                    signal.FreeBS = tonumber(signBoxFreeBS)
                    signal.Override325Hz = false
                    if signal.ARSLastNextLimit and signal.ARSSpeedLimit and signal.ARSLastNextLimit >= signal.ARSSpeedLimit and signal.ARSSpeedLimit > 2 then
                        --signal.ARSLastNextLimit = signal.ARSNextSpeedLimit
                        --signal.ARSNextSpeedLimit = nil
                        signal.Override325Hz = true
                    end
                end
            end
        end
    elseif string.sub(txt, 1, 2) == 'FN' then
        local ltmtMsg = string.sub(txt, 3)
        for _, v in pairs(string.Explode(';', ltmtMsg)) do
            if v then
                local signBoxName = string.Explode('_', v)[1]
                local signBoxNextFreq = string.Explode('_', v)[2]
                local signal = Metrostroi.GetSignalByName(signBoxName)
                if signal then
                    signal.ControllerLogic = true
                    signal.ControllerLogicOverride325Hz = true
                    signal.ControllerLogicCheckOccupied = true
                    signal.Override325Hz = false
                    signal.ARSNextSpeedLimit = tonumber(signBoxNextFreq)
                    if not signal.ARSNextSpeedLimit then signal.ARSNextSpeedLimit = 0 end
                    if not signal.ARSSpeedLimit then signal.ARSSpeedLimit = 0 end
                    signal.ARSLastNextLimit = signal.ARSNextSpeedLimit
                    if signal.ARSNextSpeedLimit >= signal.ARSSpeedLimit and signal.ARSSpeedLimit > 2 then
                        --signal.ARSNextSpeedLimit = nil
                        signal.Override325Hz = true
                    end
                end
            end
        end
    elseif string.sub(txt, 1, 2) == 'BL' then
        local ltmtMsg = string.sub(txt, 3)
        for k, v in pairs(string.Explode(';', ltmtMsg)) do
            local bellName = string.sub(v, 1, -3)
            local bellStatus = string.sub(v, -1)
            hook.Run('VitroMod.Bells.Status', bellName, bellStatus == '1' and true or false)
        end
    elseif string.sub(txt, 1, 2) == 'LM' then
        local ltmtMsg = string.sub(txt, 3)
        for k, v in pairs(string.Explode(';', ltmtMsg)) do
            local lampName = string.sub(v, 1, -3)
            local lampStatus = string.sub(v, -1)
            for _, ent in pairs(ents.FindByName(lampName)) do
                if lampStatus == '0' then
                    ent:SetSkin(0) -- выключить лампу
                elseif lampStatus == '1' then
                    ent:SetSkin(1) -- включить лампу
                end
            end
        end
    elseif string.sub(txt, 1, 2) == 'IN' then
        local msg = string.sub(txt, 3)
        local name = string.Explode(';', msg)[2]
        VitroMod.Pult.IntervalClocks.Reset(name)
    elseif string.sub(txt, 1, 3) == 'BV_' then
        local json = string.Explode(';', string.sub(txt, 4))[1]
        local bvs = util.JSONToTable(json)
        VitroMod.Pult.GermoGates.UpdateLocks(bvs)
    elseif string.sub(txt, 1, 2) == 'FL' then
        local ltmtMsg = string.sub(txt, 3)
        for k, v in pairs(string.Explode(';', ltmtMsg)) do
            if string.len(v) > 0 then
                local name = 'FS' .. string.Explode('_', v)[1]
                local status = string.Explode('_', v)[2] == '1'
                hook.Run('VitroMod.Rays.FL', name, status)
            end
        end
    elseif txt == 'OKFIRST' then
        firstConnect = true
    elseif txt == 'ASNP_UPD' then
        if SendRNs then SendRNs(true) end
    end
end
