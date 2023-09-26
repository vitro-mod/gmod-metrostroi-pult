local map = {
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