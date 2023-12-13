include("shared.lua")
include("cl_font.lua")
--------------------------------------------------------------------------------
function ENT:Initialize()
    self.Sig = ""
    self.OldName = ""
    self.Models = {{},{},{},{}}
    self.Signals = {}
    self.Anims = {}
    self.PixVisibleHandlers = {}
	self.Sprites = {}
	self.Lights = {}
	self.PTs = {}
    self.NumLit = {}
end
function ENT:Animate(clientProp, value, min, max, speed, damping, stickyness)
    local id = clientProp
    if not self.Anims[id] then
        self.Anims[id] = {}
        self.Anims[id].val = value
        self.Anims[id].V = 0.0
    end

    if damping == false then
        local dX = speed * self.DeltaTime
        if value > self.Anims[id].val then
            self.Anims[id].val = self.Anims[id].val + dX
        end
        if value < self.Anims[id].val then
            self.Anims[id].val = self.Anims[id].val - dX
        end
        if math.abs(value - self.Anims[id].val) < dX then
            self.Anims[id].val = value
        end
    else
        -- Prepare speed limiting
        local delta = math.abs(value - self.Anims[id].val)
        local max_speed = 1.5*delta / self.DeltaTime
        local max_accel = 0.5 / self.DeltaTime

        -- Simulate
        local dX2dT = (speed or 128)*(value - self.Anims[id].val) - self.Anims[id].V * (damping or 8.0)
        if dX2dT >  max_accel then dX2dT =  max_accel end
        if dX2dT < -max_accel then dX2dT = -max_accel end

        self.Anims[id].V = self.Anims[id].V + dX2dT * self.DeltaTime
        if self.Anims[id].V >  max_speed then self.Anims[id].V =  max_speed end
        if self.Anims[id].V < -max_speed then self.Anims[id].V = -max_speed end

        self.Anims[id].val = math.max(0,math.min(1,self.Anims[id].val + self.Anims[id].V * self.DeltaTime))

        -- Check if value got stuck
        if (math.abs(dX2dT) < 0.001) and stickyness and (self.DeltaTime > 0) then
            self.Anims[id].stuck = true
        end
    end
    return min + (max-min)*self.Anims[id].val
end
--------------------------
-- MAIN SPAWN FUNCTIONS --
--------------------------
function ENT:SpawnMainModels(pos,ang,LenseNum,add)
    local TLM = self.TrafficLightModels[self.LightType]
    for k,v in pairs(TLM) do
        if type(v) == "string" and not k:find("long") then
            local idx = add and v..add or v
            if IsValid(self.Models[1][idx]) then break else
                local k_long = k.."_long"
                if TLM[k_long] and LenseNum > (self.LongThreshold[self.LightType] or 2) then
                    self.Models[1][idx] = ClientsideModel(TLM[k_long],RENDERGROUP_OPAQUE)
                    self.LongOffset = TLM[k.."_long_pos"]
                else
                    self.Models[1][idx] = ClientsideModel(v,RENDERGROUP_OPAQUE)
                end
                self.Models[1][idx]:SetPos(self:LocalToWorld(pos))
                self.Models[1][idx]:SetAngles(self:LocalToWorldAngles(ang))
                self.Models[1][idx]:SetParent(self)
            end
        end
    end
end

function ENT:SpawnHead(ID,model,pos,ang,glass,notM,add)
    if not IsValid(self.Models[1][ID]) then
        self.Models[1][ID] = ClientsideModel(model,RENDERGROUP_OPAQUE)
        self.Models[1][ID]:SetPos(self:LocalToWorld(pos))
        self.Models[1][ID]:SetAngles(self:LocalToWorldAngles(ang))
        self.Models[1][ID]:SetParent(self)
    end
    if self.RN and self.RN == self.RouteNumbers.sep then
        self.RN = self.RN + 1
    end
    local id = self.RN
    local rouid = id and "rou"..id
    if rouid and not IsValid(self.Models[1][rouid]) then
        local rnadd = ((self.RouteNumbers[id] and self.RouteNumbers[id][1] ~= "X") and (self.RouteNumbers[id][3] and not self.RouteNumbers[id][2] and "2" or "") or "5")
        local LampIndicator = self.TrafficLightModels[self.LightType].LampIndicator
        self.Models[1][rouid] = ClientsideModel(LampIndicator.model..rnadd..".mdl",RENDERGROUP_OPAQUE)
        self.Models[1][rouid]:SetPos(self:LocalToWorld(pos-self.RouteNumberOffset*(self.Left and LampIndicator[1] or LampIndicator[2])))
        self.Models[1][rouid]:SetAngles(self:GetAngles())
        self.Models[1][rouid]:SetParent(self)
        if self.RouteNumbers[id] then self.RouteNumbers[id].pos = pos-self.RouteNumberOffset*(self.Left and LampIndicator[1] or LampIndicator[2]) end
        self.RN = self.RN + 1
    end
    if notM then
        if glass then
            local ID_glass = tostring(ID).."_glass"
            for i,tbl in pairs(glass) do
                local ID_glassi = ID_glass..i
                if not IsValid(self.Models[1][ID_glassi]) then  --NEWLENSES
                    self.Models[1][ID_glassi] = ClientsideModel(tbl[1],RENDERGROUP_OPAQUE)
                    self.Models[1][ID_glassi]:SetPos(self:LocalToWorld(pos+tbl[2]*(add and Vector(-1,1,1) or 1)))
                    self.Models[1][ID_glassi]:SetAngles(self:LocalToWorldAngles(ang))
                    self.Models[1][ID_glassi]:SetParent(self)
                end
            end
        end
    end
end

function ENT:SetLight(ID,ID2,pos,ang,skin,State,Change)
    local IsStateAboveZero = State > 0
    local IDID2 = ID..ID2
    local IsModelValid = IsValid(self.Models[3][IDID2])
    if IsModelValid then
        if IsStateAboveZero then 
            if Change then 
                self.Models[3][IDID2]:SetColor(Color(255,255,255,State*255))
            end
        else
            self.Models[3][IDID2]:Remove()
        end
    elseif IsStateAboveZero then
        self.Models[3][IDID2] = ClientsideModel(self.TrafficLightModels[self.LightType].LampBase.model,RENDERGROUP_OPAQUE)
        self.Models[3][IDID2]:SetPos(self:LocalToWorld(pos))
        self.Models[3][IDID2]:SetAngles(self:LocalToWorldAngles(ang))
        self.Models[3][IDID2]:SetSkin(skin)
        self.Models[3][IDID2]:SetParent(self)
        self.Models[3][IDID2]:SetRenderMode(RENDERMODE_TRANSCOLOR)
        self.Models[3][IDID2]:SetColor(Color(255,255,255,State*255))
    end
	
	self.Sprites[IDID2] = {
        pos = self:LocalToWorld(pos+Vector(0,32,0)), 
        bri = State, col = Metrostroi.Lenses[self.SpriteConverter[skin+1]], 
        mul = Metrostroi.SigTypeSpriteMul[self.LightType] * self.SpriteMultiplier[skin+1]
    }
	
	local distSqr = (EyePos() - self.Sprites[IDID2].pos):LengthSqr()
	local distZ = math.abs(EyePos().z - self.Sprites[IDID2].pos.z)
	
	if true and IsStateAboveZero and distZ < 256 and (distSqr < 4096*4096) then
		if not IsValid(self.PTs[IDID2]) then self.PTs[IDID2] = ProjectedTexture() end
		if IsValid(self.PTs[IDID2]) then 
			self.PTs[IDID2]:SetEnableShadows( (distSqr < 1024*1024) and true or false )
			self.PTs[IDID2]:SetTexture( "effects/flashlight001" )
			self.PTs[IDID2]:SetColor( self.Sprites[IDID2].col )
			self.PTs[IDID2]:SetFarZ( 300 )
			self.PTs[IDID2]:SetFOV( 45 )
			self.PTs[IDID2]:SetPos( self.Sprites[IDID2].pos )
			self.PTs[IDID2]:SetBrightness( self.Sprites[IDID2].bri )
			local ptAng = self:LocalToWorldAngles(ang)
			ptAng:Add(Angle(0,90,0))
			self.PTs[IDID2]:SetAngles( ptAng )
			self.PTs[IDID2]:Update()
		end
	else
		if IsValid(self.PTs[IDID2]) then self.PTs[IDID2]:Remove() end
	end
end

function ENT:SpawnLetter(i,model,pos,letter,double)
    local LetMaterials = self.TrafficLightModels[self.LightType].LetMaterials.str
    local LetMaterialsStart = LetMaterials.."let_start"
    local LetMaterialsletter = LetMaterials..letter
    if double ~= false and not IsValid(self.Models[2][i]) and (self.Double or not self.Left) and (not letter:match("s[1-3]") or letter == "s3" or self.Double and self.Left) then
        self.Models[2][i] = ClientsideModel(model,RENDERGROUP_OPAQUE)
        self.Models[2][i]:SetAngles(self:LocalToWorldAngles(Angle(0,180,0)))
        self.Models[2][i]:SetPos(self:LocalToWorld(self.BasePosition+pos))
        self.Models[2][i]:SetParent(self)
        for k,v in pairs(self.Models[2][i]:GetMaterials()) do
            if v:find(LetMaterialsStart) then
                self.Models[2][i]:SetSubMaterial(k-1,LetMaterialsletter)
            end
        end
    end
    local id = i.."d"
    if not double and not IsValid(self.Models[2][id]) and (self.Double or self.Left) and (not letter:match("s[1-3]") or letter == "s3" or self.Double and not self.Left) then
        self.Models[2][id] = ClientsideModel(model,RENDERGROUP_OPAQUE)
        self.Models[2][id]:SetAngles(self:LocalToWorldAngles(Angle(0,180,0)))
        self.Models[2][id]:SetPos(self:LocalToWorld((self.BasePosition+pos)*Vector(-1,1,1)))
        self.Models[2][id]:SetParent(self)
        for k,v in pairs(self.Models[2][id]:GetMaterials()) do
            if v:find(LetMaterialsStart) then
                self.Models[2][id]:SetSubMaterial(k-1,LetMaterialsletter)
            end
        end
    end
end

function ENT:OnRemove()
    self:RemoveModels()
	hook.Remove( "PostDrawTranslucentRenderables", self)
	self:RemovePTs()
end

function ENT:RemoveModels(final)
    if self.Models and  self.Models.have then
        for _,v in pairs(self.Models) do if type(v) == "table" then for _,v1 in pairs(v) do v1:Remove() end end end
    end
    self.NumLit = {}
    self.Models = {{},{},{},{}}
    self.ModelsCreated = false
end

function ENT:RemovePTs()
	if not self.PTs then return end
    for k,v in pairs(self.PTs) do
        if IsValid(v) then v:Remove() end
    end
end

net.Receive("metrostroi-signal", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent.LightType = net.ReadInt(4)
    ent.Name = net.ReadString()
    --ent.Name = " BUDAPEiT"..string.gsub(ent.Name,"[A-Za-z]*","")
    ent.Lenses = net.ReadString()
    ent.ARSOnly = ent.Lenses == "ARSOnly"
    ent.RouteNumberSetup = net.ReadString()
    ent.Left = net.ReadBool()
    ent.Double = net.ReadBool()
    ent.DoubleL = net.ReadBool()
    ent.AutostopPresent = net.ReadBool()
    if not ent.ARSOnly then
        ent.LensesTBL = string.Explode("-",ent.Lenses)
    end
    if ent.RemoveModels then ent:RemoveModels() end
end)

function ENT:Think()
    local CurTime = CurTime()
    --self:SetNextClientThink(CurTime + 0.027)
    self.PrevTime = self.PrevTime or RealTime()
    self.DeltaTime = (RealTime() - self.PrevTime)
    self.PrevTime = RealTime()
	
	local blink = RealTime() % 0.54 > 0.27
    if self:IsDormant() or Metrostroi and Metrostroi.ReloadClientside then
        if not self.ReloadModels and self.ModelsCreated then
            self:OnRemove()
        end
        return true
    end

    if self.ReloadModels then
        self.ReloadModels = false
        self:RemoveModels()
    end

    if not self.Name then
        if self.sended and (CurTime - self.sended) > 0 then
            self.sended = nil
        end
        if not self.sended then
            net.Start("metrostroi-signal")
                net.WriteEntity(self)
            net.SendToServer()
            self.sended = CurTime + 1.5
        end
        return true
    end
    local TLM = self.TrafficLightModels[self.LightType]

    if not self.ModelsCreated then
        local ID = 0
        local ID2 = 0
        -- Create new clientside models
        if not self.ARSOnly then
            --SPAWN A OLD ROUTE Numbers
            --оператор # съедает больше производительности, чем исопльзование своей переменной с хранением количества элементов в таблице
            --поэтому добавляю каунтеры
            --TODO вообще сравнить бы это здесь xD
            local rn1 = {}
            local rn1N = 0
            local rn2 = {}
            self.RouteNumbers = {}
            self.SpecRouteNumbers = {}
            for i=1,#self.RouteNumberSetup do
                local CurRN = self.RouteNumberSetup[i]
                --[[
                    self.OldRouteNumberSetup[1] = "1234D",
                    self.OldRouteNumberSetup[2] = "WKFX",
                    self.OldRouteNumberSetup[3] = "LR"
                    rn1 заполняется если CurRN содержит что либо из self.OldRouteNumberSetup[1]
                    rn2 заполняется если CurRN содержит что либо из self.OldRouteNumberSetup[2]
                    SpecRouteNumbers заполняется если CurRN содержит что либо из self.OldRouteNumberSetup[3]
                    rn1 - цифробуквенные
                    rn2 - W-20КМ, K-КГУ, F-стрела вверх, X-пустой (для длинного кронштейна)
                    и SpecRouteNumbers - особые маршрутники, редко используются (стрелы влево вправо)
                ]]
                if self.OldRouteNumberSetup[1]:find(CurRN) then
                    rn1N = table.insert(rn1,CurRN)
                elseif self.OldRouteNumberSetup[2]:find(CurRN) then
                    table.insert(rn2,CurRN)
                elseif self.OldRouteNumberSetup[3]:find(CurRN) then
                    table.insert(self.SpecRouteNumbers,{CurRN,CurRN == "F"})
                end
            end
            for i=1,rn1N,2 do
                table.insert(self.RouteNumbers,{rn1[i],rn1[i+1],true})
            end
            for k,v in pairs(rn2) do
                table.insert(self.RouteNumbers,{v})
            end
            self.Arrow = nil

            for k,v in pairs(self.SpecRouteNumbers) do
                if not v[2] then
                    self.Arrow = k
                    self.SpecRouteNumbers = v
                    break
                end
            end
            local LenseNum = self.Arrow and 1 or 0
            local OneLense = self.Arrow == nil
            for k,v in ipairs(self.LensesTBL) do
                if k > 1 and v:find("[RGBWYM]+") then
                    OneLense = false
                end
                for i=1,#v do
                    if v[i]:find("[RGBWYM]") then
                        LenseNum = LenseNum+1
                    end
                end
            end
            if LenseNum == 0 then OneLense = false end
            LenseNum = 0
            local oneItemHeadCount = 0
            for k,v in pairs(self.LensesTBL) do
                if #v > 1 then
                    LenseNum = LenseNum + 1
                else
                    oneItemHeadCount = oneItemHeadCount + 1
                end
            end
            if oneItemHeadCount > 1 then 
                LenseNum = LenseNum + oneItemHeadCount
            end
            local offset = self.RenderOffset[self.LightType] or Vector(0, 0, 0)
            self.LongOffset = self.LongOffset or Vector(0, 0, 0)
            if not self.Left or self.Double then self:SpawnMainModels(self.BasePosition,Angle(0, 0, 0),LenseNum) end
            if self.Left or self.Double then self:SpawnMainModels(self.BasePosition*Vector(-1,1,1),Angle(0,180,0),LenseNum,self.Double and "d" or nil) end


            if not self.RouteNumbers.sep and #self.RouteNumbers > 1 then
                self.RouteNumbers.sep = 2
            elseif not self.RouteNumbers.sep and #self.RouteNumbers > 0 then
                self.RouteNumbers.sep = 1
            end
            if self.RouteNumbers.sep and self.RouteNumbers[self.RouteNumbers.sep][1] ~= "X" then
                local id = self.RouteNumbers.sep
                local rnadd = self.RouteNumbers[id][3] and not self.RouteNumbers[id][2] and "3" or "4"
                self.Models[1]["rous"] = ClientsideModel(TLM.LampIndicator.model..rnadd..".mdl",RENDERGROUP_OPAQUE)
                self.RouteNumbers[id].pos = (self.BasePosition+offset+self.LongOffset-TLM.LampIndicator[3])
                if self.Left then self.RouteNumbers[id].pos = self.RouteNumbers[id].pos*TLM.LampIndicator[4] end
                self.Models[1]["rous"]:SetPos(self:LocalToWorld(self.RouteNumbers[id].pos))
                self.Models[1]["rous"]:SetAngles(self:GetAngles())
                self.Models[1]["rous"]:SetParent(self)
            end
            if #self.RouteNumbers > 0 and (#self.RouteNumbers ~= 1 or not self.RouteNumbers.sep) then
                self.RN = 1
                self.RouteNumberOffset = TLM.RouteNumberOffset
                offset = offset + self.RouteNumberOffset*(self.Left and Vector(-1,1,1) or 1)
            else
                self.RouteNumberOffset = nil
                self.RN = nil
            end
            if self.AutostopPresent then
                if not IsValid(self.Models[1]["autostop"]) then
                    self.Models[1]["autostop"] = ClientsideModel(self.AutostopModel[1],RENDERGROUP_OPAQUE)
                    self.Models[1]["autostop"]:SetPos(self:LocalToWorld(self.BasePosition+self.AutostopModel[2]))
                    self.Models[1]["autostop"]:SetAngles(self:GetAngles())
                    self.Models[1]["autostop"]:SetParent(self)
                end
            end
            self.NamesOffset = Vector(0, 0, 0)
            -- Create traffic light models
            --if self.LightType > 2 then self.LightType = 2 end
            --if self.LightType < 0 then self.LightType = 0 end
            local first = true
			local assembled = false
			self.RouteHeads = self.RouteHeads or {}
            for _,v in ipairs(self.LensesTBL) do
                local data
                if not TLM[v] then
					if not TLM['single'] then 
						data = TLM[#v-1] 
					else
						data = TLM[0]
						assembled = true
					end
                else
                    if v == "M" then
                        self.RouteNumber = ID
                    end
                    if v[#v] == "M" then
                        self.RouteNumber = ID
                    end
                    data = TLM[v]
                end
				local notM = v~="M"
				if assembled and v[#v] == 'M' then data = TLM['M'] notM = false self.RouteNumber = ID end
                if not data then continue end			
                local vec = data[1]
				if assembled then curoffset = Vector(0,0,TLM['kronOff'] + TLM['step'] * #v) end
                if first then
                    first = false
                else
					if not assembled then offset = offset - vec
					else offset = offset - curoffset end
                end
                self.NamesOffset = self.NamesOffset + vec
				if assembled then self.LongOffset = Vector(0,0,0) end
                local offsetAndLongOffset = offset + self.LongOffset
				--SpawnHead(ID,model,pos,ang,glass,notM,add)
                if not self.Left or self.Double then    self:SpawnHead(ID,data[2],self.BasePosition + offsetAndLongOffset,Angle(0, 0, 0),data[3] and data[3].glass,notM) end
                if self.Left or self.Double then self:SpawnHead((self.Double and ID.."d" or ID),(not TLM.noleft) and data[2]:Replace(".mdl","_mirror.mdl") or data[2],self.BasePosition*Vector(-1,1,1) + offsetAndLongOffset,Angle(0, 0, 0),data[3] and data[3].glass,notM,true) end

                if v ~= "M" then
                    for i = 1,#v do
						local lnum = assembled and 1 or i
						local lenOff = data[3][i-1]
						local lenM = v[#v-i] == 'M'
						local lenMdl = TLM.single
						if lenM then lenMdl = TLM.M end
						if assembled then lenOff = TLM['single'][3][0] - Vector(0,0,TLM['step'] * (i-#v)) end
						--if assembled then lenOff = Vector(0,0,100) end
                        ID2 = ID2 + 1
						if assembled and i < #v then
							if not self.Left or self.Double then    self:SpawnHead(ID..ID2,lenMdl[2],self.BasePosition + offsetAndLongOffset + Vector(0,0,TLM['step']*i),Angle(0, 0, 0),lenMdl[3] and lenMdl[3].glass,not lenM) end
							if self.Left or self.Double then self:SpawnHead((self.Double and ID..ID2.."d" or ID..ID2),(not TLM.noleft) and lenMdl[2]:Replace(".mdl","_mirror.mdl") or lenMdl[2],self.BasePosition*Vector(-1,1,1) + offsetAndLongOffset + Vector(0,0,TLM['step']*i),Angle(0, 0, 0),lenMdl[3] and lenMdl[3].glass,not lenM,true) end					
						end						
                        if not self.Signals[ID2] then self.Signals[ID2] = {} end
                        
                        self.PixVisibleHandlers[ID..ID2] = util.GetPixelVisibleHandle()
                        if self.DoubleL then 
                            self.PixVisibleHandlers[ID..ID2.."x"] = util.GetPixelVisibleHandle()
                        end
                    end
                elseif self.UseRoutePointerFont then
                    if not self.Left or self.Double then self:SpawnPointerLamps(ID, self.BasePosition + TLM.M[3] + offsetAndLongOffset, TLM.M[4], TLM.M[5], TLM.M[6], TLM.M[7]) end
                    if self.Left or self.Double then self:SpawnPointerLamps(ID.."il", self.BasePosition*Vector(-1,1,1) + TLM.M[3] + offsetAndLongOffset, TLM.M[4], TLM.M[5], TLM.M[6], TLM.M[7]) end
                end
                ID = ID + 1
            end
            if self.Arrow then
                local id = self.Arrow
                self.Models[1]["roua"] = ClientsideModel(TLM.LampIndicator.model.."4.mdl",RENDERGROUP_OPAQUE)
                self.SpecRouteNumbers.pos = (self.BasePosition+offset+self.LongOffset-TLM.LampIndicator[5])*(self.Left and TLM.LampIndicator[6] or 1) - (self.RouteNumberOffset or Vector(0, 0, 0))
                self.Models[1]["roua"]:SetPos(self:LocalToWorld(self.SpecRouteNumbers.pos))
                self.Models[1]["roua"]:SetAngles(self:LocalToWorldAngles(self.Left and Angle(-90,0,0) or Angle(90,0,0)))
                self.Models[1]["roua"]:SetParent(self)
            end
            offset = self.RenderOffset[self.LightType]+(OneLense and TLM.name_one or TLM.name)+(OneLense and self.RouteNumberOffset or Vector(0, 0, 0))
            if self.LightType == 1 then
                offset = offset - self.NamesOffset
            end
            --local double = self.LightType ~= 1 and string.find(self.Name,"^[A-Z][A-Z]")
            local double = self.LightType ~= 1 and string.find(self.Name,"^[%a%p][%a%p]")
            if double then
				if not self.Left or self.Double then
					self:SpawnLetter(0,TLM.SignLetterSmall.model,offset - TLM.SignLetterSmall[2],(Metrostroi.LiterWarper[self.Name[0+1]] or self.Name[0+1]),true)
					self:SpawnLetter(1,TLM.SignLetterSmall.model,offset - TLM.SignLetterSmall[1],(Metrostroi.LiterWarper[self.Name[1+1]] or self.Name[1+1]),true)
				end
				if self.Left or self.Double then
					self:SpawnLetter(0,TLM.SignLetterSmall.model,offset - TLM.SignLetterSmall[1],(Metrostroi.LiterWarper[self.Name[0+1]] or self.Name[0+1]),false)
					self:SpawnLetter(1,TLM.SignLetterSmall.model,offset - TLM.SignLetterSmall[2],(Metrostroi.LiterWarper[self.Name[1+1]] or self.Name[1+1]),false)
				end
            end
            local min = 0
            for i = double and 2 or 0,#self.Name-1 do
                local id = (double and i-1 or i) - min
                if double and i == 2 then offset = offset + TLM.DoubleOffset end
                if self.Name[i+1] == " " then continue end
                if self.Name[i+1] == "/" then min = min + 1; continue end
                --if not IsValid(self.Models[2][i]) then
                self:SpawnLetter(i,TLM.SignLetter.model,offset - Vector(0,0,id*TLM.SignLetter.z),(Metrostroi.LiterWarper[self.Name[i+1]] or self.Name[i+1]))
                --end
            end
            if self.Name and self.Name:match("(/+)$") then
                local i = #self.Name
                local id = (double and i-1 or i) - min
                self:SpawnLetter(i,TLM.SignLetter.model,offset - Vector(0,0,id*TLM.SignLetter.z),Format("s%d",math.min(3,#self.Name:match("(/+)$"))))
            end
        else
            local k = "m1"
			
			if TLM.arsletter and (self.Name:StartWith('TC') or self.Name:StartWith('  ')) then
				local name = self.Name
				local offset = TLM.name 
				local angle = TLM.name_s_ang
				
				name = string.Replace(name, " ", "")
				name = string.Replace(name, "/", "")
				name = string.Replace(name, "TC", "")
				name = string.Replace(name, "REP", "")
				name = string.Replace(name, "CH", "")
				name = string.Replace(name, "J", "")
				if (self.Left) then name = string.reverse(name) end

				offset = TLM.name_out
				
				if self.Left then offset = offset - Vector(10, 0, 0) end
				offset = offset - Vector((5.85/2) * (3 - (#name)), 0, 0)

				for i = 0, #name-1 do
					local id = i
					self:SpawnLetter(i, TLM.SignLetter.model, offset - Vector(id*5.85,0,0),(Metrostroi.LiterWarper[name[i+1]] or name[i+1]), not self.Left and true or false, angle)
				end
			end

            if not IsValid(self.Models[1][k]) then
                local v = TLM["m1"]
                self.Models[1][k] = ClientsideModel(v,RENDERGROUP_OPAQUE)
                self.Models[1][k]:SetPos(self:LocalToWorld(self.BasePosition*(self.Left and Vector(-1,1,1) or 1)))
                self.Models[1][k]:SetAngles(self:LocalToWorldAngles(self.Left and Angle(-1,1,1) or Angle(1,1,1)))
                self.Models[1][k]:SetParent(self)
            end
        end
        self.Models.have = true
        self.ModelsCreated = true
		hook.Add( "PostDrawTranslucentRenderables", self, self.LightSprites)
    else
        --TODO
        if self.AutostopPresent then
            if IsValid(self.Models[1]["autostop"]) then
                self.Models[1]["autostop"]:SetPoseParameter("position",self:Animate("Autostop", self:GetNW2Bool("Autostop") and 1 or 0, 0,1, 0.4,false))
            end
        end


        self.Sig = self:GetNW2String("Signal","")
        self.Num = self:GetNW2String("Number",nil)
        if self.OldNum ~= self.Num and self.OldNum == '' then
            self.NextNumWork = CurTime + 1
        end
		self.OldNum = self.Num
		
        if (self.NextNumWork or CurTime) - CurTime > 0 then
            self.Num = ""
        end
		
        if self.ARSOnly then return true end
        local offset = (self.RenderOffset[self.LightType] or Vector(0, 0, 0))
        if self.RouteNumberOffset then offset = offset + self.RouteNumberOffset*(self.Left and Vector(-1,1) or Vector(1,1)) end
        local ID = 0
        local ID2 = 0
        local first = true
		local assembled = false
        self.rnIdx = 1
        for _,v in ipairs(self.LensesTBL) do
            local data		
			if not TLM[v] then
				if not TLM['single'] then 
					data = TLM[#v-1] 
				else
					data = TLM[0]
					assembled = true
				end
			else
                data = TLM[v]
            end
            if not data then continue end
			local notM = v~="M"
			if assembled and v[#v] == 'M' then data = TLM['M'] notM = false end			
			local vec = data[1]
			
			if assembled then curoffset = Vector(0,0,TLM['kronOff'] + TLM['step'] * #v) end
			if first then
				first = false
			else
				if not assembled then offset = offset - vec
				else offset = offset - curoffset end
			end			
			
			self.rnNums = {}
            --self.NamesOffset = self.NamesOffset + data[1]
            if v~="M" then
				self.rnNums[v] = 0
				for i = 1,#v-1 do
					if v[i] == "M" then self.rnNums[v] = self.rnNums[v] + 1 end
				end
                for i = 1,#v do
                    ID2 = ID2 + 1
					local lenOff = data[3][i-1]
					if assembled then lenOff = TLM['single'][3][0] - Vector(0,0,TLM['step'] * (i-#v)) end
					if v[#v-i] == "M" then
						if (not self.Double or self.DoubleL or not self.Left) and Metrostroi.RoutePointer[self.Num[self.rnNums[v] + 1 - self.rnIdx]] and IsValid(self.Models[1][ID..ID2]) then self.Models[1][ID..ID2]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnNums[v] + 1 - self.rnIdx]]) end
						if (self.Double and self.DoubleL or self.Left) and Metrostroi.RoutePointer[self.Num[self.rnNums[v] + 1 - self.rnIdx]] and IsValid(self.Models[1][ID..ID2.."d"]) then self.Models[1][ID..ID2.."d"]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnNums[v] + 1 - self.rnIdx]]) end
						self.rnIdx = self.rnIdx + 1
					end
                    local n = tonumber(self.Sig[ID2])
                    if n and self.Signals[ID2].RealState ~= (n > 0) then
                        self.Signals[ID2].RealState = n > 0
						--0.5 время между началом погасания выключаемого и началом включения включаемого
                        self.Signals[ID2].Stop = CurTime + 0.1
                    end
                    if self.Signals[ID2].Stop and CurTime-self.Signals[ID2].Stop > 0 then
                        self.Signals[ID2].Stop = nil
                    end
					--Animate(clientProp, value, min, max, speed, damping, stickyness)
					if v[i] == "M" then 
						i = i - 1
						continue 
					end
                    --local State = self:Animate(ID.."/"..i,  ((n == 1 or (n == 2 and blink)) and not self.Signals[ID2].Stop) and 1 or 0,  0,1, blink and 256 or 128)
					local State = ((n == 1 or (n == 2 and blink)) and not self.Signals[ID2].Stop) and 1 or 0
                    if not IsValid(self.Models[3][ID..ID2]) and State > 0 then self.Signals[ID2].State = nil end
                    local offsetAndLongOffset = offset + self.LongOffset
					if not self.DoubleL then
						self:SetLight(ID,ID2,self.BasePosition*(self.Left and Vector(-1,1,1) or 1) + offsetAndLongOffset + lenOff*(self.Left and Vector(-1,1,1) or 1),Angle(0, 0, 0),self.SignalConverter[v[i]]-1,State,self.Signals[ID2].State ~= State)
					else
						self:SetLight(ID,ID2,self.BasePosition + offsetAndLongOffset + lenOff,Angle(0, 0, 0),self.SignalConverter[v[i]]-1,State,self.Signals[ID2].State ~= State)
						self:SetLight(ID,ID2.."x",self.BasePosition*Vector(-1,1,1) + offsetAndLongOffset + lenOff*Vector(-1,1,1),Angle(0, 0, 0),self.SignalConverter[v[i]]-1,State,self.Signals[ID2].State ~= State)
					end
                    self.Signals[ID2].State = State
                end
            else
                if not self.UseRoutePointerFont then
                    if (not self.Double or self.DoubleL or not self.Left) and Metrostroi.RoutePointer[self.Num[self.rnIdx]] and IsValid(self.Models[1][ID]) then self.Models[1][ID]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnIdx]]) end
				    if (self.Double and self.DoubleL or self.Left) and Metrostroi.RoutePointer[self.Num[self.rnIdx]] and IsValid(self.Models[1][ID.."d"]) then self.Models[1][ID.."d"]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnIdx]]) end
                else
                    if Metrostroi.RoutePointerFont[self.Num[self.rnIdx]] and (not self.NumLit[ID] or self.NumLit[ID] ~= self.Num[self.rnIdx]) then
                        if (not self.Double or self.DoubleL or not self.Left) then self:UpdatePointerLamps(ID, TLM.M[8], TLM.M[9]) end
                        if (self.Double and self.DoubleL or self.Left) then self:UpdatePointerLamps(ID.."il", TLM.M[8], TLM.M[9]) end
                        self.NumLit[ID] = self.Num[self.rnIdx]
                    end
                end
                self.rnIdx = self.rnIdx + 1
            end
			if v[#v] == "M" and assembled then
				if (not self.Double or self.DoubleL or not self.Left) and Metrostroi.RoutePointer[self.Num[self.rnIdx]] and IsValid(self.Models[1][ID]) then self.Models[1][ID]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnIdx]]) end
				if (self.Double and self.DoubleL or self.Left) and Metrostroi.RoutePointer[self.Num[self.rnIdx]] and IsValid(self.Models[1][ID.."d"]) then self.Models[1][ID.."d"]:SetSkin(Metrostroi.RoutePointer[self.Num[self.rnIdx]]) end
                self.rnIdx = self.rnIdx + 1
			end
            ID = ID + 1
        end

        local LampIndicatorModels_numb_mdl = TLM.LampIndicator.model.."_numb_l.mdl"
        local LampIndicatorModels_lamp_mdl = TLM.LampIndicator.model.."_lamp.mdl"
        for k,v in pairs(self.RouteNumbers) do
            if k == "sep" then continue end
            local rou1k = "rou1"..k
            local State1 = self:Animate(rou1k,self.Num:find(v[1]) and 1 or 0,   0,1, 256)
            local State2
            --if v[3] then
            local rou2k = "rou2"..k
            if v[2] then State2 = self:Animate(rou2k,self.Num:find(v[2])and 1 or 0,     0,1, 256) end
            if not IsValid(self.Models[3][rou1k]) and State1 > 0 then
                self.Models[3][rou1k] = ClientsideModel(v[3] and LampIndicatorModels_numb_mdl or LampIndicatorModels_lamp_mdl,RENDERGROUP_OPAQUE)
                self.Models[3][rou1k]:SetPos(self:LocalToWorld(v.pos + self.OldRouteNumberSetup[4]))
                self.Models[3][rou1k]:SetAngles(self:GetAngles())
                self.Models[3][rou1k]:SetParent(self)
                self.Models[3][rou1k]:SetSkin(v[3] and self.OldRouteNumberSetup[5][v[1]] or self.OldRouteNumberSetup[6][v[1]] or tonumber(v[1])-1)
                self.Models[3][rou1k]:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self.Models[3][rou1k]:SetColor(Color(255, 255, 255, 0))
            end
            if IsValid(self.Models[3][rou1k]) then
                if State1 > 0 then
                    self.Models[3][rou1k]:SetColor(Color(255,255,255,State1*255))
                elseif State1 == 0 then
                    self.Models[3][rou1k]:Remove()
                end
            end
            if not IsValid(self.Models[3][rou2k]) and v[3] and v[2] and State2 > 0 then
                self.Models[3][rou2k] = ClientsideModel(LampIndicatorModels_numb_mdl,RENDERGROUP_OPAQUE)
                self.Models[3][rou2k]:SetPos(self:LocalToWorld(v.pos + self.OldRouteNumberSetup[4] + TLM.RouteNumberOffset2))
                self.Models[3][rou2k]:SetAngles(self:GetAngles())
                self.Models[3][rou2k]:SetParent(self)
                self.Models[3][rou2k]:SetSkin(self.OldRouteNumberSetup[5][v[2]] or tonumber(v[2])-1)
                self.Models[3][rou2k]:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self.Models[3][rou2k]:SetColor(Color(255, 255, 255, 0))
            end
            if IsValid(self.Models[3][rou2k]) then
                if State2 > 0 then
                    self.Models[3][rou2k]:SetColor(Color(255,255,255,State2*255))
                elseif State2 == 0 then
                    self.Models[3][rou2k]:Remove()
                end
            end
        end
        if self.Arrow then
            local State = self:Animate("roua",self.Num:find(self.SpecRouteNumbers[1]) and 1 or 0,   0,1, 256)
            if not IsValid(self.Models[3]["roua"]) and State > 0 then
                self.Models[3]["roua"] = ClientsideModel(LampIndicatorModels_lamp_mdl,RENDERGROUP_OPAQUE)
                self.SpecRouteNumbers.pos = (self.BasePosition+offset-TLM.SpecRouteNumberOffset)-(self.RouteNumberOffset or Vector(0, 0, 0))+TLM.RouteNumberOffset3
                if self.Left then self.SpecRouteNumbers.pos = self.SpecRouteNumbers.pos*TLM.SpecRouteNumberOffset2 end
                self.Models[3]["roua"]:SetPos(self.Models[1]["roua"]:LocalToWorld(TLM.RouaOffset))
                self.Models[3]["roua"]:SetAngles(self.Models[1]["roua"]:LocalToWorldAngles(Angle(180,0,0)))
                self.Models[3]["roua"]:SetParent(self)
                if self.Left then
                    if self.Num[1] == "L" then
                        self.Models[3]["roua"]:SetSkin(self.OldRouteNumberSetup[6]["R"] or 0)
                    else
                        self.Models[3]["roua"]:SetSkin(self.OldRouteNumberSetup[6]["L"] or 0)
                    end
                else
                    self.Models[3]["roua"]:SetSkin(self.OldRouteNumberSetup[6][self.Num[1]] or 0)
                end
                self.Models[3]["roua"]:SetRenderMode(RENDERMODE_TRANSCOLOR)
                self.Models[3]["roua"]:SetColor(Color(255, 255, 255, 0))
            end
            if IsValid(self.Models[3]["roua"]) then
                if State > 0 then
                    self.Models[3]["roua"]:SetColor(Color(255,255,255,State*255))
                elseif State == 0 then
                    self.Models[3]["roua"]:Remove()
                end
            end
        end
        --self.SpecRouteNumbers
    end
    return true
end
local cols = {
    R = Color(200,0,0),
    Y = Color(200,200,0),
    G = Color(0,200,0),
    W = Color(200,200,200),
    B = Color(0,0,200),
}
function ENT:Draw()
    -- Draw model
    self:DrawModel()
end

function ENT:LightSprites()
	if not self.Sprites then return end
	for k,v in pairs(self.Sprites) do
		self:Sprite(v.pos, self:GetAngles(), v.col, v.bri, v.mul, k)
	end	
end

function ENT:Sprite(pos, ang, col, bri, mul, handlerKey )
    if bri <= 0 then return end
    local Visible = 0
    if self.PixVisibleHandlers[handlerKey] then
	    Visible = util.PixelVisible( pos, 1, self.PixVisibleHandlers[handlerKey] )
    end
	if ( ( Visible ) and ( Visible > 0.1 ) ) then
		local fw = ang:Forward()
		fw:Rotate(Angle(0,90,0))
		local view = EyePos() - pos
		local dist = view:LengthSqr()
		view:Normalize()
		local viewdot = view:Dot( fw )
		viewdot = viewdot
		if ( viewdot > 0 ) then
			Visible = Visible * viewdot
			local s = bri ^ 0.5 * math.Clamp(dist ^ 0.5 /32,64,384) * mul
			--local s = bri ^ 0.5 * math.Clamp(dist/20,48,256)
			s = s * Visible
			render.SetMaterial( self.SpriteMat )
			render.DrawSprite( pos, s, s, col )
		end
	end	
end

function ENT:SpawnPointerLamps(ID, InitPos, StepX, StepY, Scale, mdl)
    local xf = 0;
    local yf = 0;

    for i=1,#Metrostroi.RoutePointerFont[""] do
        self.Models[4][ID..i] = ClientsideModel(mdl,RENDERGROUP_OPAQUE)
        self.Models[4][ID..i]:SetPos(self:LocalToWorld((InitPos - Vector(xf * StepX, 0, yf * StepY)) ))
        self.Models[4][ID..i]:SetAngles(self:LocalToWorldAngles(Angle(0,90,0)))
        self.Models[4][ID..i]:SetModelScale(Scale)
        self.Models[4][ID..i]:SetParent(self)
        self.Models[4][ID..i]:SetNoDraw(true)
        self.PixVisibleHandlers['m'..ID..i] = util.GetPixelVisibleHandle()

        xf = xf + 1
        if xf == 5 then
            xf = 0
            yf = yf + 1
        end
    end
end

function ENT:UpdatePointerLamps(ID, SpriteColor, SpriteMultiplier)
    local pos = Vector(0,0.5,0)
    pos:Rotate(self:GetAngles())

    for i=1,#Metrostroi.RoutePointerFont[""] do
        if not IsValid(self.Models[4][ID..i]) then return end
        local state = Metrostroi.RoutePointerFont[self.Num[self.rnIdx]][i]
        local IDi = ID..i
        local mIDi = 'm'..ID..i
        self.Models[4][IDi]:SetSkin(state and 1 or 0)
        self.Models[4][IDi]:SetNoDraw(not state)
        if state or self.Sprites[mIDi] then
            self.Sprites[mIDi] = {
                pos = self.Models[4][IDi]:GetPos() + pos, 
                bri = state and 1 or 0, 
                col = Metrostroi.Lenses[SpriteColor], 
                mul = SpriteMultiplier
            }
        end
    end
end

local debug = GetConVar("metrostroi_drawsignaldebug")

local ars = {
    {"275 Hz", "0 KM/H"},
    {"N/A Hz", "No frequency"},
    {"275-N/A", "Absolute stop"},
    nil,
    {"225 Hz", "40 KM/H"},
    nil,
    {"175 Hz", "60 KM/H"},
    {"125 Hz", "70 KM/H"},
    {"75  Hz", "80 KM/H"},
}



local function enableDebug()
    if debug:GetBool() then
        hook.Add("PreDrawEffects","MetrostroiSignalDebug",function()
            for _,sig in pairs(ents.FindByClass("gmod_track_signal")) do
                if IsValid(sig) and LocalPlayer():GetPos():DistToSqr(sig:GetPos()) < 384*384 then
                    local pos = sig:LocalToWorld(Vector(48,0,150))
                    local ang = sig:LocalToWorldAngles(Angle(0,180,90))
                    cam.Start3D2D(pos, ang, 0.25)

                        if sig:GetNW2Bool("Debug",false) then
                            surface.SetDrawColor(sig.ARSOnly and 255 or 125, 125, 0, 255)
                            surface.DrawRect(0, -60, 364, 210)
                            if not sig.ARSOnly then
                                surface.DrawRect(0, 155, 240, 170)
                                surface.DrawRect(0, 330, 240, 190)
                                surface.SetDrawColor(0,0,0, 255)
                                surface.DrawRect(245, 155, 119, 365)
                            else
                                surface.DrawRect(0, 155, 364, 150)
                                surface.DrawRect(0, 310, 364, 190)
                            end

                            if sig.Name then
                                draw.DrawText(Format("Joint main info (%d)",sig:EntIndex()),"Trebuchet24",5,-60,Color(200,0,0,255))
                                draw.DrawText("Signal name: "..sig.Name,"Trebuchet24",          15, -40,Color(0, 0, 0, 255))
                                draw.DrawText("TrackID: "..sig:GetNW2Int("PosID",0),"Trebuchet24",  25, -20,Color(0, 0, 0, 255))
                                    draw.DrawText(Format("PosX: %.02f",sig:GetNW2Float("Pos",0)),"Trebuchet24", 135, -20,Color(0, 0, 0, 255))
                                draw.DrawText(Format("NextSignalName: %s",sig:GetNW2String("NextSignalName","N/A")),"Trebuchet24",  15, 0,Color(0, 0, 0, 255))
                                draw.DrawText(Format("TrackID: %s",sig:GetNW2Int("NextPosID",0)),"Trebuchet24", 25, 20,Color(0, 0, 0, 255))
                                    draw.DrawText(Format("PosX: %.02f",sig:GetNW2Float("NextPos",0)),"Trebuchet24", 135, 20,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Dist: %.02f",sig:GetNW2Float("DistanceToNext",0)),"Trebuchet24",  15, 40,Color(0, 0, 0, 255))
                                draw.DrawText(Format("PrevSignalName: %s",sig:GetNW2String("PrevSignalName","N/A")),"Trebuchet24",  15, 60,Color(0, 0, 0, 255))
                                draw.DrawText(Format("TrackID: %s",sig:GetNW2Int("PrevPosID",0)),"Trebuchet24", 25, 80,Color(0, 0, 0, 255))
                                    draw.DrawText(Format("PosX: %.02f",sig:GetNW2Float("PrevPos",0)),"Trebuchet24", 135, 80,Color(0, 0, 0, 255))
                                draw.DrawText(Format("DistPrev: %.02f",sig:GetNW2Float("DistanceToPrev",0)),"Trebuchet24",  15, 100,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Current route: %d",sig:GetNW2Int("CurrentRoute",-1)),"Trebuchet24",   15, 120,Color(0, 0, 0, 255))

                                draw.DrawText("AB info","Trebuchet24",5,160,Color(200,0,0,255))
                                draw.DrawText(Format("Occupied: %s",sig:GetNW2Bool("Occupied",false) and "Y" or "N"),"Trebuchet24",5,180,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Linked to controller: %s",sig:GetNW2Bool("LinkedToController",false) and "Y" or "N"),"Trebuchet24",5,200,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Num: %d",sig:GetNW2Int("ControllersNumber",0)),"Trebuchet24",10,220,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Controller logic: %s",sig:GetNW2Bool("BlockedByController",false) and "Y" or "N"),"Trebuchet24",5,240,Color(0, 0, 0, 255))
                                draw.DrawText(Format("Autostop: %s",not sig.ARSOnly and sig.AutostopPresent and (sig:GetNW2Bool("Autostop") and "Up" or "Down") or "No present"),"Trebuchet24",5,260,Color(0, 0, 0, 255))
                                draw.DrawText(Format("2/6: %s",sig:GetNW2Bool("2/6",false) and "Y" or "N"),"Trebuchet24",5,280,Color(0, 0, 0, 255))
                                draw.DrawText(Format("FreeBS: %d  L: %d  N: %d",sig:GetNW2Int("FreeBS"),sig:GetNW2Int("ArsThis"),sig:GetNW2Int("ArsNext")),"Trebuchet24",5,300,Color(0, 0, 0, 255))
                                draw.DrawText("ARS info","Trebuchet24",5,335,Color(200,0,0,255))
                                local num = 0
                                for i,tbl in pairs(ars) do
                                    if not tbl then continue end
                                    if sig:GetNW2Bool("CurrentARS"..(i-1),false) then
                                        draw.DrawText(Format("(% s)",tbl[1]),"Trebuchet24",5,355+num*20,Color(0,100,0,255))
                                        draw.DrawText(Format("%s",tbl[2]),"Trebuchet24",105,355+num*20,Color(0,100,0,255))
                                    else
                                        draw.DrawText(Format("(% s)",tbl[1]),"Trebuchet24",5,355+num*20,Color(0, 0, 0, 255))
                                        draw.DrawText(Format("%s",tbl[2]),"Trebuchet24",105,355+num*20,Color(0, 0, 0, 255))
                                    end
                                    num = num+1
                                end
                                if sig:GetNW2Bool("CurrentARS325",false) or sig:GetNW2Bool("CurrentARS325_2",false) then
                                    draw.DrawText("(325 Hz)","Trebuchet24",5,355+num*20,Color(0,100,0,255))
                                    draw.DrawText(Format("LN:%s Apr0:%s",sig:GetNW2Bool("CurrentARS325",false) and "Y" or "N",sig:GetNW2Bool("CurrentARS325_2",false) and "Y" or "N"),"Trebuchet24",105,355+num*20,Color(0,100,0,255))
                                else
                                    draw.DrawText("(325 Hz)","Trebuchet24",5,355+num*20,Color(0, 0, 0, 255))
                                    draw.DrawText(Format("LN:%s Apr0:%s",sig:GetNW2Bool("CurrentARS325",false) and "Y" or "N",sig:GetNW2Bool("CurrentARS325_2",false) and "Y" or "N"),"Trebuchet24",105,355+num*20,Color(0, 0, 0, 255))
                                end

                                if not sig.ARSOnly then
                                    draw.DrawText("Signal info","Trebuchet24",250,160,Color(200,0,0,255))
                                    local ID = 0
                                    local ID2 = 0
                                    local first = true
                                    for _,v in ipairs(sig.LensesTBL) do
                                        local data
                                        if not sig.TrafficLightModels[sig.LightType][v] then
                                            data = sig.TrafficLightModels[sig.LightType][#v-1]
                                        else
                                            data = sig.TrafficLightModels[sig.LightType][v]
                                        end
                                        if not data then continue end

                                        --sig.NamesOffset = sig.NamesOffset + data[1]
                                        if v ~= "M" then
                                            for i = 1,#v do
                                                ID2 = ID2 + 1
                                                local n = tonumber(sig.Sig[ID2])
                                                local State = n == 1 and "X" or (n == 2 and (RealTime() % 1.2 > 0.4)) and "B" or false
                                                draw.DrawText(Format(v[i],sig:EntIndex()),"Trebuchet24",250,160 + ID*20 + ID2*20,cols[v[i]])
                                                if State then
                                                    draw.DrawText(State,"Trebuchet24",280,160 + ID*20 + ID2*20,cols[v[i]])
                                                end
                                            end
                                        else
                                            ID2 = ID2 + 1
                                            draw.DrawText("M","Trebuchet24",250,160 + ID*20 + ID2*20,Color(200,200,200))
                                            draw.DrawText(sig.Num or "none","Trebuchet24",280,160 + ID*20 + ID2*20,Color(200,200,200))

                                            --if Metrostroi.RoutePointer[sig.Num[1]] then sig.Models[1][sig.RouteNumber]:SetSkin(Metrostroi.RoutePointer[sig.Num[1]]) end
                                        end

                                        ID = ID + 1
                                    end
                                end
                            else
                                draw.DrawText("No data...","Trebuchet24",5,0,Color(0, 0, 0, 255))
                            end
                        else
                            surface.SetDrawColor(sig.ARSOnly and 255 or 125, 125, 0, 255)
                            surface.DrawRect(0, 0, 364, 25)
                            draw.DrawText("Debug disabled...","Trebuchet24",5,0,Color(0, 0, 0, 255))
                        end
                    cam.End3D2D()
                end
            end
        end)
    else
        hook.Remove("PreDrawEffects","MetrostroiSignalDebug")
    end
end
hook.Remove("PreDrawEffects","MetrostroiSignalDebug")
cvars.AddChangeCallback( "metrostroi_drawsignaldebug", enableDebug)
enableDebug()

--Metrostroi.OptimisationPatch()