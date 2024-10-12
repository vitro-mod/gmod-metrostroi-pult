function initSwitches()
	VitroMod.Pult.Switches = {}
	VitroMod.Pult.SwitchesControl = VitroMod.Pult.SwitchesControl or {}
	for k,v in pairs(ents.FindByClass('prop_door_rotating')) do 
		if string.Explode('_',v:GetName())[1] == 'trackswitch' then
			local ctrl = v:GetSaveTable().m_eDoorState
			local name = string.Explode('_',v:GetName())[2]
			if VitroMod.Pult.SwitchesInvert[name] ~= nil then ctrl = invCtrl(ctrl) end
			if VitroMod.Pult.SwitchesInvertAll then ctrl = invCtrl(ctrl) end
			VitroMod.Pult.Switches[string.Explode('_',v:GetName())[2]] = VitroMod.Pult.Switches[string.Explode('_',v:GetName())[2]] or {}
			--if v:GetSaveTable().m_eDoorState ~= 0 then
				VitroMod.Pult.SwitchesControl[name] = ctrl or {}
			--end
			table.insert(VitroMod.Pult.Switches[string.Explode('_',v:GetName())[2]], v)
		end
	end
	for k,v in pairs(VitroMod.Pult.Switches) do
		--for k2,v2 in pairs(VitroMod.Pult.Switches[k]) do
			local v2 = VitroMod.Pult.Switches[k][1]
			addEntityOutputHook(v2,'OnFullyOpen','swSend')
			addEntityOutputHook(v2,'OnFullyClosed','swSend')
			addEntityOutputHook(v2,'OnOpen','swSend')
			addEntityOutputHook(v2,'OnClose','swSend')
			
		--end
	end
end

function sw(name, input)
	if VitroMod.Pult.SwitchesInvertAll then input = not input end
	if not VitroMod.Pult.Switches[name] then return false end
	for k,v in pairs(VitroMod.Pult.Switches[name]) do
		if not IsValid(v) then return false end
		v:Fire("Unlock")
		v:Fire(input and "Open" or "Close")
		--v:Fire("SetSpeed",0.4)
		--v:Fire("Lock")
	end
	return true
end

function swEpk(name)
	if not VitroMod.Pult.Switches[name] then return false end
	for k,v in pairs(VitroMod.Pult.Switches[name]) do
		if not IsValid(v) then continue end

		v:Ignite(4)
	end
	return true
end

-- function swLost(name)
	-- if not VitroMod.Pult.Switches[name] then return end
	-- if not VitroMod.Pult.Switches[name] then return false end
	-- for k,v in pairs(VitroMod.Pult.Switches[name]) do
		-- SendSWInfo(nil,v)
	-- end
-- end