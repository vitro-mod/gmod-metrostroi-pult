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
		rcTriggersExclude['RCIK470'] = true
		rcTriggersExclude['RCIK472'] = true
		rcTriggersExclude['RCIK474'] = true
		rcTriggersExclude['RCIK476'] = true
		rcTriggersExclude['RCIK478'] = true
		rcTriggersExclude['RCMS1071'] = true
		rcTriggersExclude['RCMS1073'] = true
		rcTriggersExclude['RCMS1075'] = true
		rcTriggersExclude['RCMS1077'] = true
		rcTriggersExclude['RCMS1079'] = true
		rcTriggersExclude['RCMS1176'] = true
		rcTriggersExclude['RCMS1178'] = true
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
			if v:GetClass() == 'trigger_multiple' then SafeRemoveEntity(v) end
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
VitroMod.Pult.Maps['gm_metro_nekrasovskaya_line_v5'] = {
	Init = function()
		local renameTable = {
			{pult = '1', gm = '1'},
			{pult = '2', gm = '2'},
			{pult = '3', gm = '12'},
			{pult = '4', gm = '4'},
			{pult = '5', gm = '9'},
			{pult = '6', gm = '3'},
			{pult = '7', gm = '6'},
			{pult = '8', gm = '5'},
			{pult = '9', gm = '8'},
			{pult = '10', gm = '10'},
			{pult = '11', gm = '7'},
			{pult = '12', gm = '11'},
		}
		for _,r in pairs(renameTable) do
			for k,v in pairs(ents.FindByName('trackswitch_depo' .. r.pult)) do
				v:SetName('trackswitch_dr' .. r.gm)
			end
		end
		VitroMod.Pult.SwitchesInvert = {}
		VitroMod.Pult.SwitchesInvert['ns3'] = true
		VitroMod.Pult.SwitchesInvert['ns4'] = true
		VitroMod.Pult.SwitchesInvert['ln3'] = true
		VitroMod.Pult.SwitchesInvert['ln4'] = true
		--include('ksProps.lua')
		
		rcASNP['TC177'] = true
		rcASNP['TC277'] = true
		rcASNP['TC377'] = true
		rcASNP['TC477'] = true
		rcASNP['TC577'] = true
		rcASNP['TC677'] = true
		rcASNP['TC777'] = true
		rcASNP['TC877'] = true
		
		rcASNP['TC278'] = true
		rcASNP['TC378'] = true
		rcASNP['TC478'] = true
		rcASNP['TC578'] = true
		rcASNP['TC678'] = true
		rcASNP['TC778'] = true
		rcASNP['TC878'] = true
		rcASNP['TC978'] = true
		
		rcASNP['TC1'] = true
		rcASNP['NST3'] = true
		rcASNP['NST4'] = true
		rcASNP['LNT3'] = true
		rcASNP['LNT4'] = true
		rcASNP['X1'] = true
		rcASNP['X2'] = true
		rcASNP['TC461'] = true
		rcASNP['TC428'] = true
		rcASNP['TC11N'] = true
		rcASNP['TC612'] = true
	end,
	OnSwitch = function(name, to)
		if name == 'ks5' then WriteToSocket('SWks5_'..(to and '2' or '0')) end
	end,	
	OnConnect = function()
		for k,v in pairs(ents.FindByModel('models/mus/subwaystation/a_red_sign_tripod.mdl')) do
			SafeRemoveEntity(v)
		end
		for k,v in pairs(ents.FindByClass('trigger_multiple')) do
			SafeRemoveEntity(v)
		end		
		for k,v in pairs(ents.FindByClass('logic_*')) do
			SafeRemoveEntity(v)
		end
		for k,v in pairs(ents.FindByClass('prop_physics_multiplayer')) do
			SafeRemoveEntity(v)
		end
		
		local cleanup = {'dep_*','*_sw_*','*pult_*','tupik*','lukh*','gok*','*_ob*'}
		local exclude = {}
		exclude['lukh1p'] = true
		exclude['lukh2p'] = true
		for _,c in pairs(cleanup) do
			for k,v in pairs(ents.FindByName(c)) do
				if exclude[v:GetName()] == nil then 
					SafeRemoveEntity(v)
				end
			end
		end
	end
}