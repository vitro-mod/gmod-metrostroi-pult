VitroMod = VitroMod or {}
VitroMod.Pult = VitroMod.Pult or {}
VitroMod.Pult.Maps = VitroMod.Pult.Maps or {}
VitroMod.Pult.Maps['gm_metro_minsk_1984'] = {
	Init = function()
		VitroMod.Pult.SwitchesInvert = {}
		VitroMod.Pult.SwitchesInvert['dm1'] = true
		VitroMod.Pult.SwitchesInvert['dm2'] = true
		VitroMod.Pult.SwitchesInvert['dm13'] = true
		VitroMod.Pult.SwitchesInvert['dm18'] = true
		VitroMod.Pult.SwitchesInvert['dm23'] = true
		VitroMod.Pult.SwitchesInvert['dm27'] = true
		VitroMod.Pult.SwitchesInvert['dm51'] = true
		VitroMod.Pult.SwitchesInvert['dm56'] = true
		VitroMod.Pult.SwitchesInvert['dm32'] = true
		VitroMod.Pult.SwitchesInvert['dm34'] = true
		rcTriggersExclude = {}
		rcTriggersExclude['RCIK377'] = true
		rcTriggersExclude['RCIK379'] = true
		rcTriggersExclude['RCIK472'] = true
		rcNames['   IK30M'] = nil
	end,
	OnSwitch = function(name, to)
	end,
	OnConnect = function()
		sw('dm15',false)
	end
}
VitroMod.Pult.Maps['gm_metro_kalinin_v2'] = {
	Init = function()
		VitroMod.Pult.SwitchesInvert = {}
		VitroMod.Pult.SwitchesInvert['nv3'] = true
		VitroMod.Pult.SwitchesInvert['nv4'] = true
		VitroMod.Pult.SwitchesInvert['nk3'] = true
		VitroMod.Pult.SwitchesInvert['nk4'] = true
		rcASNP['TC777'] = true
		rcASNP['TC385'] = true
		rcASNP['TC369A'] = true
		rcASNP['TC347'] = true
		rcASNP['TC335A'] = true
		rcASNP['TC321B'] = true
		rcASNP['TC307'] = true
		rcASNP['TC295B'] = true
		
		rcASNP['TC284'] = true
		rcASNP['TC296'] = true
		rcASNP['TC310'] = true
		rcASNP['TC322B'] = true
		rcASNP['TC334'] = true
		rcASNP['TC354'] = true
		rcASNP['TC370'] = true
		rcASNP['TC878'] = true
		
		rcASNP['TC3ACH'] = true
		rcASNP['TC4ACH'] = true
		rcASNP['TC771'] = true
		rcASNP['TC718N'] = true
		
		rcASNP['TCNV3AN'] = true
		rcASNP['TCNV4AN'] = true
		
		rcASNP['ASNPWE3'] = true
		
		rcASNP['ASNPTR3'] = true	
	end,
	OnSwitch = function(name, to)
		if name == 'depo1' then sw('depo3',to) end
		if name == 'depo2' then sw('depo4',to) end
		if name == 'depo5' then sw('depo6',to) end
		if name == 'depo7' then sw('depo8',not to) end
		if name == 'depo9' then sw('depo11',not to) end
		if name == 'depo13' then sw('depo15',not to) end
		if name == 'tr6' then WriteToSocket('SWtr6_'..(to and '2' or '0')) end
	end,
	OnConnect = function()
		local cleanup = {'sw','b_sw','ad','ao','b_ad','trig','relay','br','block','unblock','pribytie','nb','b_nb','on','off'}
		local stations = {'nv','nk','se','mr','tr','tretyak'}
		local wildcard = {'dep_'}
		for _,v in pairs(ents.GetAll()) do
			for _,s in pairs(stations) do
				for _,c in pairs(cleanup) do
					if  v:GetName():StartWith(s..'_'..c) or v:GetName():StartWith(c..'_'..s) then 
						SafeRemoveEntity(v)
					end
				end
			end
			for _,w in pairs(wildcard) do
				if v:GetName():StartWith(w) then
					SafeRemoveEntity(v)
				end
			end
		end
		for i = 11,20 do
			local ent = ents.FindByName("depo_door_"..i)[1]
			ent:Fire("Open")
			ent:Fire("Lock")
		end		
		sbor = nil
	end	
}