local function enableDebug()
    local debug = GetConVar("metrostroi_drawsignaldebug")
    local ars = {
        { "275 Hz",  "0 KM/H" },
        { "N/A Hz",  "No frequency" },
        { "275-N/A", "Absolute stop" },
        nil,
        { "225 Hz", "40 KM/H" },
        nil,
        { "175 Hz", "60 KM/H" },
        { "125 Hz", "70 KM/H" },
        { "75  Hz", "80 KM/H" },
    }
    local cols = {
        R = Color(255, 0, 0),
        Y = Color(255, 255, 0),
        G = Color(0, 255, 0),
        W = Color(255, 255, 255),
        B = Color(0, 0, 255),
    }

    local textColor = cols.W
    local colorGreen = cols.G
    local colorRed = cols.R
    local colorWhite = cols.W
    local signalBg = Color(125, 125, 0, 128)
    local arsBg = Color(255, 125, 0, 128)
    local font = "TargetID"
    if not debug:GetBool() then
        hook.Remove("PreDrawEffects", "MetrostroiSignalDebug")
        return
    end
    hook.Add("PreDrawEffects", "MetrostroiSignalDebug", function()
        for _, sig in pairs(ents.FindByClass("gmod_track_signal")) do
            local shouldDraw = IsValid(sig) and LocalPlayer():GetPos():DistToSqr(sig:GetPos()) < 512 * 512
            if not shouldDraw then continue end
            local pos = sig:LocalToWorld(Vector(48, 0, 150))
            local ang = sig:LocalToWorldAngles(Angle(0, 180, 90))
            cam.Start3D2D(pos, ang, 0.25)
            surface.SetDrawColor(sig.ARSOnly and arsBg or signalBg)
            surface.DrawRect(0, 570, 364, 30)
            if not sig:GetNW2Bool("Debug", false) then
                draw.DrawText("Debug disabled...", font, 5, 0, textColor)
                cam.End3D2D()
                continue
            end

            if not sig.Name then
                draw.DrawText("No data...", font, 5, 0, textColor)
                cam.End3D2D()
                continue
            end

            draw.DrawText(Format("Joint main info (%d)", sig:EntIndex()), font, 5, -60, colorRed)
            draw.DrawText("Signal name: " .. string.Replace(sig.Name, " ", "•"), font, 15, -40, textColor)
            draw.DrawText("TrackID: " .. sig:GetNW2Int("PosID", 0), font, 25, -20, textColor)
            draw.DrawText(Format("PosX: %.02f", sig:GetNW2Float("Pos", 0)), font, 135, -20, textColor)
            draw.DrawText(Format("NextSignalName: %s", sig:GetNW2String("NextSignalName", "N/A")), font, 15, 0, textColor)
            draw.DrawText(Format("TrackID: %s", sig:GetNW2Int("NextPosID", 0)), font, 25, 20, textColor)
            draw.DrawText(Format("PosX: %.02f", sig:GetNW2Float("NextPos", 0)), font, 135, 20, textColor)
            draw.DrawText(Format("Dist: %.02f", sig:GetNW2Float("DistanceToNext", 0)), font, 15, 40, textColor)
            draw.DrawText(Format("PrevSignalName: %s", sig:GetNW2String("PrevSignalName", "N/A")), font, 15, 60,
                textColor)
            draw.DrawText(Format("TrackID: %s", sig:GetNW2Int("PrevPosID", 0)), font, 25, 80, textColor)
            draw.DrawText(Format("PosX: %.02f", sig:GetNW2Float("PrevPos", 0)), font, 135, 80, textColor)
            draw.DrawText(Format("DistPrev: %.02f", sig:GetNW2Float("DistanceToPrev", 0)), font, 15, 100, textColor)
            draw.DrawText(Format("Current route: %d", sig:GetNW2Int("CurrentRoute", -1)), font, 15, 120, textColor)
            draw.DrawText("AB info", font, 5, 160, textColor)
            draw.DrawText(
            Format("Occupied: %s  VKSMet: %s", sig:GetNW2Bool("Occupied", false) and "Y" or "N",
                sig:GetNW2Bool("VKSMet", false) and "Y" or "N"), font, 5, 180, textColor)
            draw.DrawText(Format("Linked to controller: %s", sig:GetNW2Bool("LinkedToController", false) and "Y" or "N"),
                font, 5, 200, textColor)
            draw.DrawText(Format("Num: %d", sig:GetNW2Int("ControllersNumber", 0)), font, 10, 220, textColor)
            draw.DrawText(Format("Controller logic: %s", sig:GetNW2Bool("BlockedByController", false) and "Y" or "N"),
                font, 5, 240, textColor)
            draw.DrawText(
            Format("Autostop: %s  Red: %d",
                not sig.ARSOnly and sig.AutostopPresent and (sig:GetNW2Bool("Autostop") and "Up" or "Down") or "Absent",
                sig:GetNW2Bool("Red") and 1 or 0), font, 5, 260, textColor)
            draw.DrawText(Format("2/6: %s", sig:GetNW2Bool("2/6", false) and "Y" or "N"), font, 5, 280, textColor)
            draw.DrawText(
            Format("FreeBS: %d / %d  L: %d  N: %d", sig:GetNW2Int("FreeBS"), sig:GetNW2Int("FreeBSToPrev"),
                sig:GetNW2Int("ArsThis"), sig:GetNW2Int("ArsNext")), font, 5, 300, textColor)
            draw.DrawText("ARS info", font, 5, 335, colorRed)
            local num = 0
            for i, tbl in pairs(ars) do
                if not tbl then continue end
                if sig:GetNW2Bool("CurrentARS" .. (i - 1), false) then
                    draw.DrawText(Format("(% s)", tbl[1]), font, 5, 355 + num * 20, colorGreen)
                    draw.DrawText(Format("%s", tbl[2]), font, 105, 355 + num * 20, colorGreen)
                else
                    draw.DrawText(Format("(% s)", tbl[1]), font, 5, 355 + num * 20, textColor)
                    draw.DrawText(Format("%s", tbl[2]), font, 105, 355 + num * 20, textColor)
                end

                num = num + 1
            end

            if sig:GetNW2Bool("CurrentARS325", false) or sig:GetNW2Bool("CurrentARS325_2", false) then
                draw.DrawText("(325 Hz)", font, 5, 355 + num * 20, colorGreen)
                draw.DrawText(
                Format("LN:%s Apr0:%s", sig:GetNW2Bool("CurrentARS325", false) and "Y" or "N",
                    sig:GetNW2Bool("CurrentARS325_2", false) and "Y" or "N"), font, 105, 355 + num * 20, colorGreen)
            else
                draw.DrawText("(325 Hz)", font, 5, 355 + num * 20, textColor)
                draw.DrawText(
                Format("LN:%s Apr0:%s", sig:GetNW2Bool("CurrentARS325", false) and "Y" or "N",
                    sig:GetNW2Bool("CurrentARS325_2", false) and "Y" or "N"), font, 105, 355 + num * 20, textColor)
            end

            if not sig.ARSOnly then
                draw.DrawText("Signal info", font, 250, 160, colorRed)
                local ID = 0
                local ID2 = 0
                -- local first = true
                for _, v in ipairs(sig.LensesTBL) do
                    local data
                    if not sig.TrafficLightModels[sig.LightType][v] then
                        data = sig.TrafficLightModels[sig.LightType][#v - 1]
                    else
                        data = sig.TrafficLightModels[sig.LightType][v]
                    end

                    if not data then continue end
                    if v ~= "M" and v ~= "X" then
                        for i = 1, #v do
                            ID2 = ID2 + 1
                            local n = tonumber(sig.Sig[ID2])
                            local State = n == 1 and "X" or (n == 2 and (RealTime() % 1.2 > 0.4)) and "B" or false
                            draw.DrawText(Format(v[i], sig:EntIndex()), font, 250, 160 + ID * 20 + ID2 * 20, cols[v[i]])
                            if State then draw.DrawText(State, font, 280, 160 + ID * 20 + ID2 * 20, cols[v[i]]) end
                        end
                    else
                        ID2 = ID2 + 1
                        draw.DrawText("M", font, 250, 160 + ID * 20 + ID2 * 20, colorWhite)
                        draw.DrawText(sig.Num or "none", font, 280, 160 + ID * 20 + ID2 * 20, colorWhite)
                        --if Metrostroi.RoutePointer[sig.Num[1]] then sig.Models[1][sig.RouteNumber]:SetSkin(Metrostroi.RoutePointer[sig.Num[1]]) end
                    end

                    ID = ID + 1
                end
            end

            cam.End3D2D()
        end
    end)
end

hook.Remove("PreDrawEffects", "MetrostroiSignalDebug")
cvars.AddChangeCallback("metrostroi_drawsignaldebug", enableDebug, "metrostroi_drawsignaldebug_new")
enableDebug()
