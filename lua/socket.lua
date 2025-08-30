VitroMod = VitroMod or {}
VitroMod.Pult = VitroMod.Pult or {}
VitroMod.Pult.WhiteList = VitroMod.Pult.WhiteList or {}
VitroMod.Pult.WhiteList.Rc = VitroMod.Pult.WhiteList.Rc or {}
VitroMod.Pult.WhiteList.Control = VitroMod.Pult.WhiteList.Control or {}
VitroMod.Pult.SwitchesInvertAll = false
require('gwsockets')
pings = 0
timer.Remove('ping')
include('vitro_mod/pult/config.lua')
local mapName = game.GetMap()
if not file.Exists('vitro_mod/pult/maps/' .. mapName .. '.lua', 'LUA') or not VitroMod.Pult.Urls[mapName] then
	print('VitroPult: map ' .. mapName .. ' is not configured for SCB server!')
	return
end

include('vitro_mod/pult/Maps.lua')
include('Switches.lua')
include('IntervalClocks.lua')
include('GermoGates.lua')
local handshake = VitroMod.Pult.Name .. '! ' .. VitroMod.Pult.Key .. '|' .. mapName
VitroMod.Pult.IsMaster = string.Explode(':', VitroMod.Pult.Name)[1] == 'MASTER'
if sck then
	sck:closeNow()
	sck = nil
end

if not sck then sck = GWSockets.createWebSocket(VitroMod.Pult.Urls[mapName]) end
if not sck then return end
-- sck:closeNow()
function sck:onConnected()
	print('VitroPult: connected to SCB server')
	--PultDefaultCleanup()
	self:write(handshake)
	VitroMod.Pult.Map.OnConnect()
	--RunConsoleCommand('say','WebSocket connected to server')
	if VitroMod.Pult.IsMaster then
		self:write('RCs_' .. util.TableToJSON(rcTriggers))
		self:write('SWS_' .. util.TableToJSON(VitroMod.Pult.SwitchesControl))
		self:write('BUs_' .. util.TableToJSON(rcNamesOcc))
		self:write('INs_' .. util.TableToJSON(VitroMod.Pult.IntervalClocks.Get()))
		self:write('BV_' .. util.TableToJSON(VitroMod.Pult.GermoGates.GetAll()))
	end

	if SendRNs then SendRNs() end
	if Minsk and Minsk.MK then self:write('MKs_' .. util.TableToJSON(Minsk.MK.GetTableMKInfo())) end
	if not firstConnect then
		WriteToSocket('FIRST')
	else
		WriteToSocketSimple('RECON')
	end

	rcASNPmsg = {}
end

-- function sck:onDisconnected()
-- RunConsoleCommand('say','WebSocket disconnected')
-- end

include('Messages.lua')

function sck:onMessage(txt)
	if not txt then return end

	VitroMod.Pult.HandleMessage(txt)

	if txt == 'OKFIRST' then
		firstConnect = true
	elseif txt == 'ASNP_UPD' then
		if SendRNs then SendRNs(true) end
	end

	pings = 0
end

--function sck:onError( errMsg )
--print('error: '..errMsg)
--end
function wsConnect(reconnect)
	if sck:isConnected() and not reconnect then
		if pings > 0 then
			print('notPong(')
			sck:closeNow()
			sck:open()
		else
			sck:write('ping')
			pings = 1
			if SendRNs then SendRNs() end
		end
	else
		--print('initConnect')
		sck:closeNow()
		sck:open()
	end
end

wsConnect()
function startPing(instant)
	if instant then wsConnect() end
	timer.Create('ping', 2, 0, wsConnect)
end

startPing()
function stopPing()
	sck:closeNow()
	timer.Remove('ping')
end

local OLD_MESSAGE = '' -- старое сообщение сокет-серверу
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

hook.Add('Metrostroi.Signalling.AfterLoad', 'VitroModUpdOnLoad', pultUpd)
rcTriggers = {}
rcTriggersExclude = {}
rcNames = {}
rcNamesOcc = {}
include('GetTState.lua')
include('AllSeats.lua')
rcASNP = {}
rcASNPmsg = {}
for k, v in pairs(ents.FindByClass('gmod_track_signal')) do
	v.ControllerLogicCheckOccupied = true
	--if v.Name and (string.sub(v.Name,1,2) == '  ' or string.sub(v.Name,1,3) == '   ') then 
	rcNames[v.Name] = v.Occupied
	rcNamesOcc[v.Name] = v.Occupied and true or nil
	if rcASNP[v.Name] then rcASNP[v.Name] = v.Occupied and v.OccupiedBy or true end
	--end    
end

VitroMod.Pult.Map.Init()
VitroMod.Pult.IntervalClocks.Init()
initSwitches()

function SendRCInfo(ACTIVATOR, CALLER, INFO)
	local vname = CALLER:GetName()
	--print(vname..'_'..INFO)
	if rcTriggersExclude[vname] == nil then WriteToSocket(vname .. '_' .. INFO) end
	rcTriggers[vname] = INFO == 1 and '' .. INFO or nil
end

hook.Add('VitroMod_Trigger_Update', 'VitroMod_socket', function(ACTIVATOR, CALLER, INFO) SendRCInfo(ACTIVATOR, CALLER, INFO) end)
hook.Add('Metrostroi.Signaling.ChangeRCState', 'VitroModRcHook', function(name, occ, signal) SendBU(name, occ, signal) end)
hook.Remove('VitroMod.Rays.FS', 'VitroMod.Pult.Rays.FS')
hook.Add('VitroMod.Rays.FS', 'VitroMod.Pult.Rays.FS', function(name, status) SendFS(name, status) end)

function SendBU(name, occ, signal)
	rcNamesOcc[name] = occ and true or nil
	local sendRN = rcASNP[name] and IsValid(signal.OccupiedBy) and occ
	rcASNP[name] = rcASNP[name] and true or nil
	if VitroMod.Pult.IsMaster then WriteToSocket('BU' .. name .. (occ and '_1' or '_0')) end
	if sendRN and signal.OccupiedBy:GetClass() ~= 'me_train' and signal.OccupiedBy:GetClass() ~= 'me_train_static' then
		rcASNP[name] = occ and signal.OccupiedBy or true
		local tst = GetTrainState(signal.OccupiedBy, signal)
		tst.cab = AllSeats(signal.OccupiedBy)
		if MetExt ~= nil then tst.srv = GetHostName() end
		local msg = 'BU' .. name .. '_1_' .. util.TableToJSON(tst)
		if not rcASNPmsg[name] or rcASNPmsg[name] ~= msg then rcASNPmsg[name] = WriteToSocketSimple(msg) end
	end
end

function SendRNs(force)
	for k, v in pairs(rcASNP) do
		if IsEntity(v) and IsValid(v) and Metrostroi.GetSignalByName(k).Occupied and v:GetClass() ~= 'me_train' and v:GetClass() ~= 'me_train_static' then
			local tst = GetTrainState(v, Metrostroi.GetSignalByName(k))
			tst.cab = AllSeats(v)
			if MetExt ~= nil then tst.srv = GetHostName() end
			local msg = 'BU' .. k .. '_1_' .. util.TableToJSON(tst)
			if not rcASNPmsg[k] or rcASNPmsg[k] ~= msg or force then rcASNPmsg[k] = WriteToSocketSimple(msg) end
		end
	end
end

function SendAutomaticRC(signal)
	if rcNames[signal.Name] ~= nil and signal.Occupied ~= rcNames[signal.Name] then
		rcNames[signal.Name] = signal.Occupied
		rcNamesOcc[signal.Name] = signal.Occupied and signal.Occupied or nil
		WriteToSocket('BU' .. signal.Name .. (signal.Occupied and '_1' or '_0'))
	end
end

-- Minsk MK
function SendMKinfo(ACTIVATOR, CALLER, INFO)
	WriteToSocket(string.sub(CALLER:GetName(), 1, -4) .. Either(INFO == 0, '_0', '_1'))
end

function SendFS(name, status)
	WriteToSocketSimple(name .. (status and '_1' or '_0'))
end

hook.Add('VitroModWhiteList', 'VitroModWhiteListSend', function() WriteToSocketSimple('WL' .. util.TableToJSON(VitroMod.Pult.WhiteList)) end)
hook.Add('PlayerSay', 'vitromod-say', function(ply, comm) if comm:sub(1, 2) == '!p' then WriteToSocket('SY' .. comm) end end)
VitroMod.Pult.Map.OnConnect()
hook.Add('PostCleanupMap', 'PostCleanup_Pult', VitroMod.Pult.Map.OnConnect)
hook.Add('PostCleanupMap', 'PostCleanup_Signals', Metrostroi.Load)
concommand.Add('vitropult_reconnect', function(ply)
	if ply:IsValid() and not ply:IsAdmin() then return end
	print('VitroPult: reconnecting')
	RunConsoleCommand('say', 'VitroPult: reconnecting')
	wsConnect(true)
	pultUpd()
end)