function GetTrainState(wagon, signal)
    if not IsValid(wagon) then return end
    
    local train = wagon
    if MetrostroiExt and MetrostroiExt.DetectHeadWagon then
        train = MetrostroiExt.DetectHeadWagon( wagon, true )
    end
    
    local RN = nil
    local CS = 0 --control state
    local ARS = 0
    local class = train:GetClass()
    local nick = train:GetDriverPly():GetName()
    if train.KV then
        if train.KV.ReverserPosition ~= 0 then CS = 1 end
    elseif train.RV then
        if train.RV.KROPosition ~= 0 and train.RV.KRRPosition == 0 then CS = 1 end
        if train.RV.KRRPosition ~= 0 and train.RV.KROPosition == 0 then CS = 2 end
    elseif train.KR then
        if train.KR.Position ~= 0 then CS = 1 end
    elseif train.Electric and train.Electric.CabActive then
        if train.Electric.CabActive == 1 then CS = 1 end
    end

    if train.KRU then
        if train.KRU.Position > 0 then CS = 2 end
    elseif train.VRU and class ~= 'gmod_subway_81-502' then
        if train.VRU.Value == 0 then CS = 2 end
    elseif train.VRU and class == 'gmod_subway_81-502' then
        if train.VRU.Value == 1 then CS = 2 end
    end

    if class == 'gmod_subway_81-502' then
        if train.Electric.Type == 2 then
            if CS ~= 0 and train.RCAV5.Value == 1 and train.RCAV4.Value == 1 and train.RCAV3.Value == 1 then ARS = 1 end
        elseif train.MARS then
            if CS ~= 0 and train.RCARS.Value == 1 and train.RCBPS.Value == 1 then ARS = 1 end
        end
    elseif class == 'gmod_subway_ezh3' then
        if CS == 1 and train.RUM.Value == 1 then ARS = 1 end
    elseif class == 'gmod_subway_ezh' then
        if CS == 1 and train.RC1.Value == 1 then ARS = 1 end
    elseif class == 'gmod_subway_81-718' then
        if train.KRU.Position ~= 0 then CS = 2 end
        if CS ~= 0 and train.RC.Value == 1 then ARS = 1 end
        if CS ~= 0 and train:ReadTrainWire(87) > 0 then ARS = 2 end
    elseif class == 'gmod_subway_81-720' or class == 'gmod_subway_81-720_1' or class == 'gmod_subway_81-760' or class == 'gmod_subway_81-760a' then
        if CS ~= 0 and train.BARSBlock.Value == 0 and train.ALS.Value == 0 then ARS = 1 end
        if CS ~= 0 and train.ALS.Value == 0 and (train.BARSBlock.Value == 1 or train.BARSBlock.Value == 2) then ARS = 2 end
    elseif class == 'gmod_subway_81-722' or class == 'gmod_subway_81-722_new' or class == 'gmod_subway_81-722_1' then
        if CS ~= 0 and train.RCARS.Value == 1 then
            ARS = 1
            if train.BARSMode.Value ~= 1 then ARS = 2 end
        end
    elseif class == 'gmod_subway_81-717_lvz' or class == 'gmod_subway_81-540_2_lvz' or class == 'gmod_subway_81-540_1' or class == 'gmod_subway_81-7175p' or class == 'gmod_subway_81-540_8' then
        if train.Electric.Type == 5 then
            if CS ~= 0 and train.RC1.Value == 1 then ARS = 1 end
        elseif train.Electric.Type == 3 or train.Electric.Type == 4 then
            if CS ~= 0 and train.RC1.Value == 1 and train.RC2.Value == 1 then ARS = 1 end
            if (CS ~= 0 and train.RC1.Value == 0 and train.RC2.Value == 1) or (CS ~= 0 and train.RC1.Value == 1 and train.RC2.Value == 0) then ARS = 2 end
        end
    elseif train.RC1 and train.ReadTrainWire then
        if CS ~= 0 and train.RC1.Value == 1 then ARS = 1 end
        if CS ~= 0 and train:ReadTrainWire(87) > 0 then ARS = 2 end
    end

    if not RN then
        if train.ASNP and not train.ASNP.Disable and (train:GetNW2Int('ASNP:RouteNumber', 0) ~= 0) then
            RN = train:GetNW2Int('ASNP:RouteNumber', 0)
        elseif train.PAM and train.PAM_VV and train.PAM_VV.Power and train:GetNW2String('PAM:RouteNumber', '') ~= '' then
            RN = tonumber(train:GetNW2String('PAM:RouteNumber', '0'))
            --elseif train.MFDU and not train.MFDU.RouteNumber == 0 and not train.MFDU.RouteNumber < 0 then
        elseif train.MFDU and train.MFDU.RouteNumber and train.MFDU.RouteNumber > 0 then
            RN = train.MFDU.RouteNumber
        elseif train.MFDU and train.MFDU.RouteN and tonumber(train.MFDU.RouteN) > 0 then
            RN = tonumber(train.MFDU.RouteN)
        elseif train.RouteNumber then
            RN = tonumber(train:GetNW2String('RouteNumber', 0))
            if train.RouteNumber.Max == 2 and class ~= 'gmod_subway_81-717_5a' and class ~= 'gmod_subway_81-717_freight' and class ~= 'gmod_subway_81-717_6' and class ~= 'gmod_subway_em508' and class ~= 'gmod_subway_em508t' then RN = RN / 10 end
        elseif train.RouteNumberSys then
            RN = tonumber(train.RouteNumberSys.RouteNumber)
        end
    end

    if not RN then RN = 0 end
    local Type = class:Replace('gmod_subway_', '')
    return {
        rn = RN,
        nick = nick,
        ctrl = CS,
        ars = ARS,
        type = Type,
        newWag = newWag and true or nil,
        newTrain = train,
        wcount = #train.WagonList
    }
end