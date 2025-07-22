local function getFile(path,name,id)
    local data,found
    if file.Exists(Format(path..".txt",name),"DATA") then
        --print(Format("Metrostroi: Loading %s definition...",id))
        data= util.JSONToTable(file.Read(Format(path..".txt",name),"DATA"))
        found = true
    end
    if not data and file.Exists(Format(path..".lua",name),"LUA") then
        --print(Format("Metrostroi: Loading default %s definition...",id))
        data= util.JSONToTable(file.Read(Format(path..".lua",name),"LUA"))
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

local function loadTrigs(name, keep)
    name = name or game.GetMap()

    --local trig_ents = ents.FindByClass("gmod_vitromod_trigger")
    --for k,v in pairs(trig_ents) do SafeRemoveEntity(v) end
	VitroMod.trigFlush()

    if keep then return end
    local triggers = getFile("metrostroi_data/triggers_%s",name,"Trigger")
    if not triggers then return end

     for k,v in pairs(triggers) do
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
	--VitroMod.trigSendAll()
end

local function loadBells(name, keep)
    name = name or game.GetMap()

    VitroMod.Bells.flush()

    if keep then return end
    local bells = getFile("metrostroi_data/bells_%s",name,"Bell")
    if not bells then return end

     for k,v in pairs(bells) do
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

hook.Add("Initialize", "Metrostroi_VitroModInitialize", function()
    timer.Simple(2.0, function() 
		loadTrigs() 
		loadBells()
	end)
end)

timer.Simple(2, function()                  --�������� ����� �������� ����

local m_save = Metrostroi.Save
function Metrostroi.Save(name)

    m_save(name)

    if not file.Exists("metrostroi_data","DATA") then
        file.CreateDir("metrostroi_data")
    end
    name = name or game.GetMap()

    -- Format signs, signal, switch data
    local triggers = {}
    local trig_ents = ents.FindByClass("gmod_vitromod_trigger")
    
    for k,v in pairs(trig_ents) do
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
    local data = util.TableToJSON(triggers, true)
    file.Write(string.format("metrostroi_data/triggers_%s.txt", name), data)
	
    local bells = {}
    local bell_ents = ents.FindByClass("gmod_vitromod_bell")
    
    for k,v in pairs(bell_ents) do
        table.insert(bells, {
            Pos = v:GetPos(),
            Angles = v:GetAngles(),
			Name = v:GetName(),
        })
    end
    local data = util.TableToJSON(bells, true)
    file.Write(string.format("metrostroi_data/bells_%s.txt", name), data)	
end

local m_load = Metrostroi.Load
function Metrostroi.Load(name,keep_signs)
    m_load(name,keep_signs)
    loadTrigs(name,keep_signs)
	loadBells(name,keep_signs)
	timer.Simple(1, function() hook.Run("Metrostroi.Signalling.Load") end)
end

end)                                        --��������� ���� ������� � ���������
