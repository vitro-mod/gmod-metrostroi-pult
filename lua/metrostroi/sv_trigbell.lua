local function getFile(path, name, id)
    local data, found
    if file.Exists(Format(path .. ".txt", name), "DATA") then
        --print(Format("Metrostroi: Loading %s definition...",id))
        data = util.JSONToTable(file.Read(Format(path .. ".txt", name), "DATA"))
        found = true
    end

    if not data and file.Exists(Format(path .. ".lua", name), "LUA") then
        --print(Format("Metrostroi: Loading default %s definition...",id))
        data = util.JSONToTable(file.Read(Format(path .. ".lua", name), "LUA"))
        found = true
    end

    if not found then
        --print(Format("%s definition file not found: %s",id,Format(path,name)))
        return
    elseif not data then
        --print(Format("Parse error in %s %s definition JSON",id,Format(path,name)))
        return
    end
    return data
end

local SPATIAL_CELL_WIDTH = 1024
local SPATIAL_CELL_HEIGHT = 256

local function spatialPosition(pos)
    return math.floor(pos.x / SPATIAL_CELL_WIDTH),
        math.floor(pos.y / SPATIAL_CELL_WIDTH),
        math.floor(pos.z / SPATIAL_CELL_HEIGHT)
end

local function addLookup(node)
    local kx, ky, kz = spatialPosition(node.pos)

    Metrostroi.SpatialLookup[kz] = Metrostroi.SpatialLookup[kz] or {}
    Metrostroi.SpatialLookup[kz][kx] = Metrostroi.SpatialLookup[kz][kx] or {}
    Metrostroi.SpatialLookup[kz][kx][ky] = Metrostroi.SpatialLookup[kz][kx][ky] or {}
    table.insert(Metrostroi.SpatialLookup[kz][kx][ky], node)
end

local function loadTracks(name)
    local track = getFile("metrostroi_data/track_%s", name, "Track") or {}
    -- Quick small hack to load tracks as well
    if Metrostroi.TrackEditor then
        Metrostroi.TrackEditor.Paths = track
    end

    -- Prepare spatial lookup table
    Metrostroi.SpatialLookup = {}

    -- Create paths definition
    Metrostroi.Paths = {}
    for pathID, path in pairs(track) do
        local currentPath = { id = pathID }
        Metrostroi.Paths[pathID] = currentPath

        -- Count length of path and offset in every node
        currentPath.length = 0
        local prevPos, prevNode
        for nodeID, nodePos in pairs(path) do
            -- Count distance
            local distance = 0
            if prevPos then
                distance = prevPos:Distance(nodePos) * 0.01905
                currentPath.length = currentPath.length + distance
            end

            -- Add a node
            currentPath[nodeID] = {
                id = nodeID,
                path = currentPath,

                pos = nodePos,
                x = currentPath.length,
                prev = prevNode,
            }
            if prevNode then
                prevNode.next = currentPath[nodeID]
                prevNode.dir = (nodePos - prevNode.pos):GetNormalized()
                prevNode.vec = nodePos - prevNode.pos
                prevNode.length = distance
            end

            -- Add to spatial lookup
            addLookup(currentPath[nodeID])
            prevPos = nodePos
            prevNode = currentPath[nodeID]
        end

        if prevNode then
            prevNode.next = nil
            prevNode.dir = Vector(0, 0, 0)
            prevNode.vec = Vector(0, 0, 0)
            prevNode.length = 0
        end
    end

    -- Find places where tracks link up together
    for pathID, path in pairs(Metrostroi.Paths) do
        if #path == 0 then break end
        -- Find position of end nodes
        local node1, node2 = path[1], path[#path]
        local ignore_path = path
        if game.GetMap():find("orange") and node1.path.id == 1 then
            ignore_path = nil
            --print(node1)
        end
        local pos1 = Metrostroi.GetPositionOnTrack(node1.pos, nil, { ignore_path = ignore_path })
        local pos2 = Metrostroi.GetPositionOnTrack(node2.pos, nil, { ignore_path = ignore_path })
        -- Create connection
        local join1, join2
        if pos1[1] then join1 = pos1[1].node1 end
        if pos2[1] then join2 = pos2[1].node1 end

        -- Record it
        if join1 then
            join1.branches = join1.branches or {}
            table.insert(join1.branches, { pos1[1].x, node1 })
            node1.branches = node1.branches or {}
            table.insert(node1.branches, { node1.x, join1 })
        end
        if join2 then
            join2.branches = join2.branches or {}
            table.insert(join2.branches, { pos2[1].x, node2 })
            node2.branches = node2.branches or {}
            table.insert(node2.branches, { node2.x, join2 })
        end
    end
end

local function loadSigns(name, keep)
    if keep then return end
    local signs = getFile("metrostroi_data/signs_%s", name, "Signal")

    if not signs then return end

    local signals_ents = ents.FindByClass("gmod_track_signal")
    for k, v in pairs(signals_ents) do SafeRemoveEntity(v) end
    local switch_ents = ents.FindByClass("gmod_track_switch")
    for k, v in pairs(switch_ents) do SafeRemoveEntity(v) end
    local signs_ents = ents.FindByClass("gmod_track_signs")
    for k, v in pairs(signs_ents) do SafeRemoveEntity(v) end

    -- Create new entities (add a delay so the old entities clean up)
    print("Metrostroi: Loading signs, signals, switches...")
    local version
    version = signs.Version
    if not version then
        print("Metrostroi: This signs file is incompatible with signs version")
        signs = nil
    else
        signs.Version = nil
    end
    local TwoToSix = false
    if version ~= 1.2 then
        print(Format("Metrostroi: !!Converting from version %.1f!! signals converted to %s.", version, TwoToSix and "2/6" or "1/5"))
        if game.GetMap():find("gm_mus_loop") then
            TwoToSix = true
        end
    end
    for k, v in pairs(signs) do
        local ent = ents.Create(v.Class)
        if IsValid(ent) then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            if v.Class == "gmod_track_switch" then
                ---CHANGE
                ent:SetChannel(v.Channel or 1)
                ent.LockedSignal = v.LockedSignal
                ent.NotChangePos = v.NotChangePos
                ent.Invertred = v.Invertred
                ent.Name = v.Name,
                    ent:Spawn()
            end
            if v.Class == "gmod_track_signal" and v.Routes then
                ent:MetrostroiLoad(v, version, TwoToSix)
                ent:Spawn()
            elseif v.Class == "gmod_track_signs" then
                ent.SignType = v.SignType
                ent.YOffset = v.YOffset
                ent.ZOffset = v.ZOffset
                ent.Left = v.Left,
                    ent:Spawn()
                ent:SendUpdate()
            elseif v.Class == "gmod_track_signal" then
                ent:Remove()
            end
        end
    end
end

local function loadAutoSigns(name, keep)
    if keep then return end
    local auto = getFile("metrostroi_data/auto_%s", name, "Autodrive")

    if not auto then return end
    local auto_ents = ents.FindByClass("gmod_track_autodrive_plate")
    for _, v in pairs(auto_ents) do SafeRemoveEntity(v) end
    Metrostroi.HaveSBPP = false
    Metrostroi.HaveAuto = false
    for k, v in pairs(auto) do
        local ent = ents.Create("gmod_track_autodrive_plate")
        if IsValid(ent) and v.Model then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            ent.PlateType = v.Type
            ent.Right = v.Right
            ent.Mode = v.Mode
            ent.Model = v.Model
            ent.StationID = v.StationID
            ent.StationPath = v.StationPath
            ent.UPPS = v.UPPS
            ent.DistanceToOPV = v.DistanceToOPV

            ent.SBPPType = v.SBPPType
            ent.IsDeadlock = v.IsDeadlock
            ent.DriveMode = v.DriveMode
            ent.RightDoors = v.RightDoors
            ent.WTime = v.WTime
            ent.RKPos = v.RKPos

            ent:SetModel(ent.Model)
            ent:Spawn()
            --[[ if ent.PlateType <= 2 then
                Metrostroi.HaveAuto = true
            end--]]
            if ent.SBPPType == 3 and not ent.BrakeProps then
                ent.BrakeProps = {}
                for i = -1, 1, 2 do
                    local entL = ents.Create("gmod_track_autodrive_plate")
                    entL.Model = "models/metrostroi/signals/autodrive/rfid.mdl"
                    entL:SetPos(v.Pos + (v.Angles:Right() * (-1.5 * i) / 0.01905))
                    entL:SetModel(v.Model)
                    entL:SetAngles(v.Angles)
                    entL:Spawn()
                    entL.Linked = ent
                    entL.SBPPType = ent.SBPPType
                    entL.PlateType = METROSTROI_SBPPSENSOR
                    table.insert(ent.BrakeProps, entL)
                end
            end
        end
    end
end

local function loadPAData(name)
    local pa = getFile("metrostroi_data/pa_%s", name, "PAData")

    if not pa then return end
    Metrostroi.PAMConfTest = pa
    if pa.markers then
        for k, v in pairs(pa.markers) do
            if not v.TrackPath or not v.TrackX then continue end
            local ent = ents.Create("gmod_track_pa_marker")
            if IsValid(ent) then
                ent:SetPos(v.Pos)
                ent:SetAngles(v.Angles)
                if Metrostroi.Paths[v.TrackPath] then
                    ent:SetTrackPosition(Metrostroi.Paths[v.TrackPath], v.TrackX)
                end
                ent.TrackPath = v.TrackPath
                ent.TrackX = v.TrackX
                ent.PAType = v.PAType
                if ent.PAType == 1 then
                    ent.PAStationPath = tonumber(v.PAStationPath)
                    ent.PAStationID = tonumber(v.PAStationID)
                    ent.PAStationName = v.PAStationName
                    ent.PALastStation = v.PALastStation
                    ent.PAStationRightDoors = v.PAStationRightDoors
                    ent.PAStationHorlift = v.PAStationHorlift
                    ent.PAStationHasSwtiches = v.PAStationHasSwtiches
                    ent.PAStationCorrection = tonumber(v.PAStationCorrection)
                    if ent.PALastStation then
                        ent.PALastStationName = v.PALastStationName
                        ent.PAWrongPath = v.PAWrongPath
                        ent.PADeadlockStart = tonumber(v.PADeadlockStart)
                        ent.PADeadlockEnd = tonumber(v.PADeadlockEnd)
                        ent.PALineChange = v.PALineChange
                        if ent.PALineChange then
                            ent.PALineChangeStationPath = tonumber(v.PALineChangeStationPath)
                            ent.PALineChangeStationID = tonumber(v.PALineChangeStationID)
                        end
                    end
                end
                ent:Spawn()
            end
        end
    end
    Metrostroi.PARebuildStations()
end

local function loadTrigs(name, keep)
    name = name or game.GetMap()
    --local trig_ents = ents.FindByClass("gmod_vitromod_trigger")
    --for k,v in pairs(trig_ents) do SafeRemoveEntity(v) end
    VitroMod.trigFlush()
    if keep then return end
    local triggers = getFile("metrostroi_data/triggers_%s", name, "Trigger")
    if not triggers then return end
    for k, v in pairs(triggers) do
        local ent = ents.Create("gmod_vitromod_trigger")
        if IsValid(ent) then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            ent:SetName(v.Name)
            ent.num = v.Num
            ent.beg = v.Beg
            ent.fin = v.Fin
            ent.min = v.Min
            ent.max = v.Max
            ent:Spawn()
        end
        --PrintTable(triggers)
    end

    VitroMod.trigSendAll()
end

local function loadBells(name, keep)
    name = name or game.GetMap()
    VitroMod.Bells.flush()
    if keep then return end
    local bells = getFile("metrostroi_data/bells_%s", name, "Bell")
    if not bells then return end
    for k, v in pairs(bells) do
        local ent = ents.Create("gmod_vitromod_bell")
        if IsValid(ent) then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            ent:SetName(v.Name)
            ent:Spawn()
        end
        --PrintTable(bells)
    end
    --VitroMod.bellSend()
    --hook.Run("VitroModBellsLoaded")
end

local function loadDevices(name, keep)
    if keep then return end
    local mapName = game.GetMap()
    if not VitroMod or not VitroMod.Devices then return end
    for k, v in pairs(VitroMod.Devices) do
        v:flush()
    end

    local devices = getFile("metrostroi_data/devices_%s", mapName, "Device")
    if not devices then return end
    for k, v in pairs(devices) do
        local deviceConfig = VitroMod.Devices[v.Type]
        if not deviceConfig then continue end
        local ent = ents.Create(deviceConfig.class)
        if not IsValid(ent) then continue end
        ent:SetPos(v.Pos)
        ent:SetAngles(v.Angles)
        ent:SetName(v.Name)
        ent:SetNW2String('Name', v.Name or '')
        ent.config = v.Config
        ent:Spawn()
    end
end

local function loadRays(name, keep)
    name = name or game.GetMap()
    VitroMod.Rays.flush()
    if keep then return end
    local rays = getFile("metrostroi_data/rays_%s", name, "Ray")
    print("Loading rays for map:", name)
    if not rays then return end
    for k, v in pairs(rays) do
        local ent = ents.Create("gmod_vitromod_ray")
        if IsValid(ent) then
            ent:MetrostroiLoad(v)
            ent:Spawn()
        end
    end
end

local function saveTriggers(map)
    -- Format signs, signal, switch data
    local triggers = {}
    local trig_ents = ents.FindByClass("gmod_vitromod_trigger")
    for k, v in pairs(trig_ents) do
        local clMin, clMax = v:GetCollisionBounds()
        table.insert(triggers, {
            Pos = v:GetPos(),
            Angles = v:GetAngles(),
            Name = v:GetName(),
            Min = clMin,
            Max = clMax,
            Num = v.num,
            Beg = v.beg,
            Fin = v.fin,
        })
    end

    local json = util.TableToJSON(triggers, true)
    file.Write(string.format("metrostroi_data/triggers_%s.txt", map), json)
end

local function saveBells(map)
    local bells = {}
    local bell_ents = ents.FindByClass("gmod_vitromod_bell")
    for k, v in pairs(bell_ents) do
        table.insert(bells, {
            Pos = v:GetPos(),
            Angles = v:GetAngles(),
            Name = v:GetName(),
        })
    end

    local json = util.TableToJSON(bells, true)
    file.Write(string.format("metrostroi_data/bells_%s.txt", map), json)
end

local function saveRays(map)
    local rays = {}
    local ray_ents = ents.FindByClass("gmod_vitromod_ray")
    for k, v in pairs(ray_ents) do
        table.insert(rays, v:GetMetrostroiSaveTable())
    end

    local json = util.TableToJSON(rays, true)
    file.Write(string.format("metrostroi_data/rays_%s.txt", map), json)
end

local function saveDevices(map)
    if not VitroMod or not VitroMod.Devices then return end
    local devices = {}
    for device, data in pairs(VitroMod.Devices) do
        for k, v in pairs(ents.FindByClass(data.class)) do
            table.insert(devices, {
                Type = device,
                Name = v:GetName(),
                Pos = v:GetPos(),
                Angles = v:GetAngles(),
                Config = v.config,
            })
        end
    end

    local json = util.TableToJSON(devices, true)
    file.Write(string.format("metrostroi_data/devices_%s.txt", map), json)
end

hook.Add("Initialize", "Metrostroi_VitroModInitialize", function()
    timer.Simple(2.0, function()
        loadTrigs()
        loadBells()
        loadDevices()
        loadRays()
    end)
end)

timer.Simple(2, function()
    function Metrostroi.Save(name)
        if not file.Exists("metrostroi_data", "DATA") then
            file.CreateDir("metrostroi_data")
        end
        name = name or game.GetMap()

        -- Format signs, signal, switch data
        local signs = {}
        local signals_ents = ents.FindByClass("gmod_track_signal")
        if not signals_ents then print("Metrostroi: Signs file is corrupted!") end
        for k, v in pairs(signals_ents) do
            if not Metrostroi.ARSSubSections[v] then
                local Routes = table.Copy(v.Routes)
                for k, v in pairs(Routes) do
                    v.LightsExploded = nil
                    v.IsOpened = nil
                end
                table.insert(signs, v:GetMetrostroiSaveTable())
            end
        end
        local switch_ents = ents.FindByClass("gmod_track_switch")
        for k, v in pairs(switch_ents) do
            table.insert(signs, {
                Class = "gmod_track_switch",
                Pos = v:GetPos(),
                Angles = v:GetAngles(),
                Name = v.Name,
                Channel = v:GetChannel(),
                NotChangePos = v.NotChangePos,
                LockedSignal = v.LockedSignal,
                Invertred = v.Invertred,
            })
        end
        local signs_ents = ents.FindByClass("gmod_track_signs")
        for k, v in pairs(signs_ents) do
            table.insert(signs, {
                Class = "gmod_track_signs",
                Pos = v:GetPos(),
                Angles = v:GetAngles(),
                SignType = v.SignType,
                YOffset = v.YOffset,
                ZOffset = v.ZOffset,
                Left = v.Left,
            })
        end
        signs.Version = Metrostroi.SignalVersion
        -- Save data
        print("Metrostroi: Saving signs and track definition...")
        local data = util.TableToJSON(signs, true)
        file.Write(string.format("metrostroi_data/signs_%s.txt", name), data)
        print(Format("Saved to metrostroi_data/signs_%s.txt", name))

        saveTriggers(name)
        saveBells(name)
        saveDevices(name)
        saveRays(name)

        local auto = {}
        local auto_ents = ents.FindByClass("gmod_track_autodrive_plate")
        for k, v in pairs(auto_ents) do
            if not v.Linked then
                table.insert(auto, {
                    Pos = v:GetPos(),
                    Angles = v:GetAngles(),
                    Type = v.PlateType,
                    Right = v.Right,
                    Mode = v.Mode,
                    Model = v.Model,
                    StationID = v.StationID,
                    StationPath = v.StationPath,

                    --UPPS
                    UPPS = v.UPPS,
                    DistanceToOPV = v.DistanceToOPV,

                    SBPPType = v.SBPPType,
                    IsDeadlock = v.IsDeadlock,
                    DriveMode = v.DriveMode,
                    RightDoors = v.RightDoors,
                    WTime = v.WTime,
                    RKPos = v.RKPos,
                })
            end
        end
        print("Metrostroi: Saving auto definition...")
        local adata = util.TableToJSON(auto, true)
        file.Write(string.format("metrostroi_data/auto_%s.txt", name), adata)
        print(Format("Saved to metrostroi_data/auto_%s.txt", name))

        local pa_ents = ents.FindByClass("gmod_track_pa_marker")
        if Metrostroi.PAMConfTest then
            print("Metrostroi: Saving PAData definition...")
            local pa = table.Copy(Metrostroi.PAMConfTest)
            pa.markers = {}
            for k, v in pairs(pa_ents) do
                if not v.UPPS and v.PAType == 1 then
                    table.insert(pa.markers, {
                        Pos = v:GetPos(),
                        Angles = v:GetAngles(),
                        PAType = v.PAType,
                        PAStationPath = tonumber(v.PAStationPath),
                        PAStationID = tonumber(v.PAStationID),
                        PAStationName = v.PAStationName,
                        PALastStation = v.PALastStation,
                        PAWrongPath = v.PALastStation and v.PAWrongPath,
                        PADeadlockStart = v.PALastStation and v.PADeadlockStart,
                        PADeadlockEnd = v.PALastStation and v.PADeadlockEnd,
                        PALineChange = v.PALastStation and v.PALineChange,
                        PALineChangeStationPath = v.PALastStation and v.PALineChange and tonumber(v.PALineChangeStationPath),
                        PALineChangeStationID = v.PALastStation and v.PALineChange and tonumber(v.PALineChangeStationID),
                        PALastStationName = v.PALastStation and v.PALastStationName or nil,
                        PAStationRightDoors = v.PAStationRightDoors,
                        PAStationHorlift = v.PAStationHorlift,
                        PAStationHasSwtiches = v.PAStationHasSwtiches,
                        PAStationCorrection = tonumber(v.PAStationCorrection),
                        TrackPath = v.TrackPath,
                        TrackX = v.TrackX,
                    })
                end
            end
            local data = util.TableToJSON(pa, true)
            file.Write(string.format("metrostroi_data/pa_%s.txt", name), data)
            print(Format("Saved to metrostroi_data/pa_%s.txt", name))
        end
    end

    function Metrostroi.Load(name, keep_signs)
        name = name or game.GetMap()

        loadTracks(name)

        -- Initialize stations list
        Metrostroi.UpdateStations()
        -- Print info
        Metrostroi.PrintStatistics()

        -- Ignore updates to prevent created/removed switches from constantly updating table of positions
        Metrostroi.IgnoreEntityUpdates = true
        loadSigns(name, keep_signs)
        loadAutoSigns(name, keep_signs)

        loadTrigs(name, keep_signs)
        loadBells(name, keep_signs)
        loadDevices(name, keep_signs)
        loadRays(name, keep_signs)

        local pa_ents = ents.FindByClass("gmod_track_pa_marker")
        for _, v in pairs(pa_ents) do SafeRemoveEntity(v) end
        loadPAData(name)
        timer.Simple(0.05, function()
            -- No more ignoring updates
            Metrostroi.IgnoreEntityUpdates = false
            -- Load ARS entities
            Metrostroi.UpdateSignalEntities()
            -- Load switches
            Metrostroi.UpdateSwitchEntities()
            -- Add additional ARS sections
            Metrostroi.UpdateARSSections()
        end)

        -- Initialize signs
        print("Metrostroi: Initializing signs...")
        Metrostroi.InitializeSigns()

        timer.Simple(1, function() hook.Run("Metrostroi.Signalling.AfterLoad") end)
    end
end)
