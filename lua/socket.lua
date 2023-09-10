VitroMod = VitroMod or {}
VitroMod.Pult = VitroMod.Pult or {}
VitroMod.Pult.WhiteList = VitroMod.Pult.WhiteList or {}
VitroMod.Pult.WhiteList.Rc = VitroMod.Pult.WhiteList.Rc or {}
VitroMod.Pult.WhiteList.Control = VitroMod.Pult.WhiteList.Control or {}
VitroMod.Pult.SwitchesInvertAll = false
require("gwsockets")
pings = 0
timer.Remove("ping")
include('config.lua')
include('Maps.lua')
local mapName = game.GetMap()
local handshake = VitroMod.Pult.Name..'! '..VitroMod.Pult.Key
if VitroMod.Pult.Urls[mapName] then sck = GWSockets.createWebSocket(VitroMod.Pult.Urls[mapName]) end
sck:closeNow()
function sck:onConnected()
	print("VitroPult: connected to SCB server")
	--PultDefaultCleanup()
	VitroMod.Pult.Maps[mapName].OnConnect()
	--RunConsoleCommand("say","WebSocket connected to server")
	self:write(handshake)
	if VitroMod.Pult.Name == 'MASTER' then
		VitroMod.Pult.UpdateIntervals()
		self:write("RCs_"..util.TableToJSON(rcTriggers))
		self:write("SWS_"..util.TableToJSON(VitroMod.Pult.SwitchesControl))
		self:write("BUs_"..util.TableToJSON(rcNamesOcc))
		self:write("INs_"..util.TableToJSON(VitroMod.Pult.Intervals))
	end
	SendRNs()
	if Minsk and Minsk.MK then self:write("MKs_"..util.TableToJSON(Minsk.MK.GetTableMKInfo())) end
	if not firstConnect then
		WriteToSocket("FIRST")
	else
		WriteToSocketSimple("RECON")
	end
	rcASNPmsg = {}
end

-- function sck:onDisconnected()
	-- RunConsoleCommand("say","WebSocket disconnected")
-- end
function sck:onMessage(txt)
	if txt then
		--RunConsoleCommand("say","READ :: ",txt) -- debug.debug
		if string.sub(txt, 1, 2 ) == "SW" then
			for k,v in pairs(string.Explode( ";", txt )) do
				if v ~= '' then 
					local name = string.sub(string.Explode("_", v)[1], 3)
					local pos = string.Explode("_", v)[2]
					local to
					if VitroMod.Pult.SwitchesInvert[name] ~= nil then
						to = pos == '+'
					else 
						to = pos ~= '+'
					end
					sw(name, to)
					VitroMod.Pult.Maps[mapName].OnSwitch(name, to)
				end
			end
		elseif string.sub(txt, 1, 2 ) == "LT" then
			local ltmtMsg = string.Explode(":",txt)
			for k,v in pairs(string.Explode(";",ltmtMsg[1])) do
				--RunConsoleCommand("say",string.Explode("-",v)[1],string.Explode("-",v)[2])
				local signal = Metrostroi.GetSignalByName(string.Explode("-",v)[1]) 
				if signal then
					signal.ControllerLogic = true
					signal.Sig = tostring(string.Explode("-",v)[2])
					signal:SetNW2String("Signal",signal.Sig)
					signal.Red = tobool(string.Explode("-",v)[3])
					signal.AutoEnabled = not tobool(string.Explode("-",v)[4])
					signal:SetNW2Bool("Autostop",signal.AutoEnabled)
					signal.ControllerLogicCheckOccupied = true
				end
			end
		elseif string.sub(txt, 1, 2 ) == "RT" then		
			local ltmtMsg = txt --string.Explode(":",txt)
			--RunConsoleCommand("say",txt)
			for k,v in pairs(string.Explode(";",ltmtMsg)) do
				--RunConsoleCommand("say",string.Explode("-",v)[1],string.Explode("-",v)[2])
				local signal = Metrostroi.GetSignalByName(string.Explode("-",v)[1]) 
				if signal then
					signal.ControllerLogic = true
					signal.RouteNumberReplace = tostring(string.Explode("-",v)[2])
					signal:SetNW2String("Number",signal.RouteNumberReplace)
				end
			end			
		elseif string.sub(txt, 1, 2) == "MK" and Minsk and Minsk.MK then
			local ltmtMsg = txt
			for k,v in pairs(string.Explode(";",ltmtMsg)) do
				local MKName = string.Explode("-",v)[1]
				local check = string.Explode("-",v)[2]
				if (check == "0") then			
					Minsk.MK.Unlock(MKName)
				elseif (check == "1") then
					Minsk.MK.Lock(MKName)
				end
			end
		elseif string.sub(txt, 1, 2) == "FR" then
			local ltmtMsg = string.sub(txt, 3)
			for _,v in pairs(string.Explode(";",ltmtMsg)) do
				if v then
					local signBoxName = string.Explode("_",v)[1]
					local signBoxFreq = string.Explode("_",v)[2]
					--local signBoxNextFreq = string.Explode("_",v)[3]
					local signBoxFreeBS = string.Explode("_",v)[3]
					local signal = Metrostroi.GetSignalByName(signBoxName)
					
					if signal then
						signal.ControllerLogic = true
						signal.ControllerLogicOverride325Hz = true
						signal.ControllerLogicCheckOccupied = true
						signal.ARSSpeedLimit = tonumber(signBoxFreq)
						signal.FreeBS = tonumber(signBoxFreeBS)
						signal.Override325Hz = false
						if signal.ARSLastNextLimit and signal.ARSLastNextLimit >= signal.ARSSpeedLimit and signal.ARSSpeedLimit > 2 then
							--signal.ARSLastNextLimit = signal.ARSNextSpeedLimit
							--signal.ARSNextSpeedLimit = nil
							signal.Override325Hz = true
						end
					end
				end
			end
		elseif string.sub(txt, 1, 2) == "FN" then
			local ltmtMsg = string.sub(txt, 3)
			for _,v in pairs(string.Explode(";",ltmtMsg)) do
				if v then
					local signBoxName = string.Explode("_",v)[1]
					local signBoxNextFreq = string.Explode("_",v)[2]
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
		elseif string.sub(txt, 1, 2) == "BL" then
			local ltmtMsg = string.sub(txt, 3)
			for k,v in pairs(string.Explode(";",ltmtMsg)) do
				local bellName = string.sub(v, 1, -3)
				local bellStatus = string.sub(v, -1)
				hook.Run('VitroMod.Bells.Status',bellName, bellStatus == '1' and true or false)
			end
		elseif string.sub(txt, 1, 2) == "LM" then
			local ltmtMsg = string.sub(txt, 3)
			for k,v in pairs(string.Explode(";",ltmtMsg)) do
				local lampName = string.sub(v, 1, -3)
				local lampStatus = string.sub(v, -1)
				for _, ent in pairs(ents.FindByName(lampName)) do
					if lampStatus == "0" then
						ent:SetSkin(0) -- выключить лампу
					elseif lampStatus == "1" then
						ent:SetSkin(1) -- включить лампу
					end
				end
			end
		elseif string.sub(txt, 1, 2) == "IN" then
			local msg = string.sub(txt, 3)
			local name = string.Explode(";",msg)[2]
			VitroMod.Pult.ResetClock(name)
		elseif txt == "OKFIRST" then
			firstConnect = true		
		elseif txt == "ASNP_UPD" then
			SendRNs(true)
		end
		pings = 0
	end
end
--function sck:onError( errMsg )
	--print("error: "..errMsg)
--end

function wsConnect(reconnect)
	if sck:isConnected() and not reconnect then
		if pings > 0 then 
			print("notPong(")
			sck:closeNow()
			sck:open()
		else
			sck:write("ping")
			pings = 1
			SendRNs()
		end
	else
		--print("initConnect")
		sck:closeNow()
		sck:open()
	end
end
wsConnect()
function startPing(instant)
	if instant then wsConnect() end
	timer.Create("ping", 2, 0, wsConnect)
end
startPing()
function stopPing()
	sck:closeNow()
	timer.Remove("ping")
end

local OLD_MESSAGE = "" -- старое сообщение сокет-серверу
function WriteToSocket(msg)
    if msg ~= OLD_MESSAGE and msg then -- проверка дублирования сообщения
        sck:write(msg)
		OLD_MESSAGE = msg
    end
	if sck:isConnected() then return msg end
end
function WriteToSocketSimple(msg)
    sck:write(msg)
	if sck:isConnected() then return msg end
end

function pultUpd()
	sck:write('UPD')
end
hook.Add("Metrostroi.Signalling.Load","VitroModUpdOnLoad", pultUpd)
rcTriggers = {}
rcTriggersExclude = {}

rcNames = {}
rcNamesOcc = {}

include('GetTState.lua')
include('AllSeats.lua')
rcASNP = {}
rcASNPmsg = {}

for k, v in pairs(ents.FindByClass("gmod_track_signal")) do
	v.ControllerLogicCheckOccupied = true
    --if v.Name and (string.sub(v.Name,1,2) == "  " or string.sub(v.Name,1,3) == "   ") then 
		rcNames[v.Name] = v.Occupied
		rcNamesOcc[v.Name] = v.Occupied and true or nil
		if rcASNP[v.Name] then
			rcASNP[v.Name] = v.Occupied and v.OccupiedBy or true
		end
    --end	
end

VitroMod.Pult.Maps[mapName].Init()

hook.Add("VitroMod_Trigger_Update", "VitroMod_socket", function(ACTIVATOR,CALLER,INFO)
	local vname = CALLER:GetName()
	--print(vname..'_'..INFO)
	if(rcTriggersExclude[vname] == nil) then
		WriteToSocket(vname..'_'..INFO)
	end
	rcTriggers[vname] = (INFO == 1 and ''..INFO or nil)
end)

--hook.Add("Metrostroi.Signaling.ChangeRCState","VitroModRcHook", function(name, occ) RunConsoleCommand("say",name..' '..(occ and '1' or '0')) end)
hook.Add("Metrostroi.Signaling.ChangeRCState","VitroModRcHook", function(name, occ,signal) SendBU(name,occ,signal) end)
function SendBU(name, occ, signal)
	rcNamesOcc[name] = occ and true or nil
	local sendRN = rcASNP[name] and IsValid(signal.OccupiedBy) and occ
	rcASNP[name] = rcASNP[name] and true or nil
	if VitroMod.Pult.Name == 'MASTER' then WriteToSocket("BU"..name..(occ and "_1" or "_0")) end
	if sendRN and signal.OccupiedBy:GetClass() ~= "me_train" and signal.OccupiedBy:GetClass() ~= "me_train_static" then
		rcASNP[name] = occ and signal.OccupiedBy or true
		local tst = GetTrainState(signal.OccupiedBy, signal)
		tst.cab = AllSeats(signal.OccupiedBy)
		if MetExt ~= nil then tst.srv = GetHostName() end
		local msg = "BU"..name.."_1_"..util.TableToJSON(tst)
		if not rcASNPmsg[name] or rcASNPmsg[name] ~= msg then
			rcASNPmsg[name] = WriteToSocketSimple(msg)
		end
	end	
end
function SendRNs(force)
	for k,v in pairs(rcASNP) do
		if IsEntity(v) and IsValid(v) and Metrostroi.GetSignalByName(k).Occupied and v:GetClass() ~= "me_train" and v:GetClass() ~= "me_train_static" then
			local tst = GetTrainState(v, Metrostroi.GetSignalByName(k))
			tst.cab = AllSeats(v)		
			if MetExt ~= nil then tst.srv = GetHostName() end
			local msg = "BU"..k.."_1_"..util.TableToJSON(tst)
			if not rcASNPmsg[k] or rcASNPmsg[k] ~= msg or force then
				rcASNPmsg[k] = WriteToSocketSimple(msg)
			end			
		end
	end
end

function SendAutomaticRC(signal)
	if(rcNames[signal.Name] ~= nil and signal.Occupied ~= rcNames[signal.Name]) then
		rcNames[signal.Name] = signal.Occupied
		rcNamesOcc[signal.Name] = (signal.Occupied and signal.Occupied or nil)
		WriteToSocket("BU"..signal.Name..(signal.Occupied and "_1" or "_0"))
	end
end

include('IntervalClocks.lua')

-------------------------------------------

function SendMKinfo(ACTIVATOR,CALLER,INFO) -- металлоконструкции
	if INFO == 0 then
		--RunConsoleCommand("say","GERMOGATE CLOSE START",string.sub(CALLER:GetName(),1,-4),INFO)
		WriteToSocket(string.sub(CALLER:GetName(),1,-4).."_0")
	else
		--RunConsoleCommand("say","GERMOGATE OPEN END",string.sub(CALLER:GetName(),1,-4),INFO)
		WriteToSocket(string.sub(CALLER:GetName(),1,-4).."_1")
	end
end

function invCtrl(ctrl)
	if ctrl == 0 then 
		ctrl = 2
	elseif	ctrl == 2 then 
		ctrl = 0 
	end
	return ctrl
end

include('Switches.lua')

hook.Add( "PostCleanupMap", "PostCleanup_InitSwitches", initSwitches )
initSwitches()

hook.Add( "VitroModWhiteList", "VitroModWhiteListSend", function ()
	WriteToSocketSimple("WL"..util.TableToJSON(VitroMod.Pult.WhiteList))
end)

function SendSWInfo(ACTIVATOR,CALLER) --писать
	local ctrl = CALLER:GetSaveTable().m_eDoorState
	local name = string.Explode('_',CALLER:GetName())[2]
	if VitroMod.Pult.SwitchesInvert[name] ~= nil then ctrl = invCtrl(ctrl) end
	if VitroMod.Pult.SwitchesInvertAll then ctrl = invCtrl(ctrl) end
	VitroMod.Pult.SwitchesControl[name] = ctrl
	local swmsg = 'SW'..name..'_'..ctrl
	if VitroMod.Pult.Name == 'MASTER' then WriteToSocket(swmsg) end
end

hook.Add( "PlayerSpawn", "KalinaDeletePult", function(ply)
	ply:SendLua('hook.Remove( "PlayerButtonDown", "menu")')
end)
hook.Add("PlayerSay","vitromod-say", function(ply, comm) if comm:sub(1,2) == '!p' then WriteToSocket('SY'..comm) end end)
hook.Add('swSend','swSendInfo',function()
	--RunConsoleCommand('say',CALLER:GetName()..'ss') 
	SendSWInfo(ACTIVATOR,CALLER)
end)

VitroMod.Pult.Maps[mapName].OnConnect()
hook.Add( "PostCleanupMap", "PostCleanup_Pult", VitroMod.Pult.Maps[mapName].OnConnect )
hook.Add( "PostCleanupMap", "PostCleanup_Signals", Metrostroi.Load )

concommand.Add("vitropult_reconnect", function(ply)
	if ply:IsValid() and not ply:IsAdmin() then return end
	print('VitroPult: reconnecting')
	wsConnect(true)
	pultUpd()
end)
