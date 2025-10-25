VitroMod.Pult.Map = {
    Init = function()
		VitroMod.Pult.SwitchesInvert = {}
		VitroMod.Pult.SwitchesInvert['nv3'] = true
		VitroMod.Pult.SwitchesInvert['nv4'] = true
		VitroMod.Pult.SwitchesInvert['nk3'] = true
		VitroMod.Pult.SwitchesInvert['nk4'] = true
		VitroMod.Pult.SwitchesInvert['depo8'] = true
		VitroMod.Pult.SwitchesInvert['depo11'] = true
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

        hook.Add( "PlayerSpawn", "KalinaDeletePult", function(ply)
            ply:SendLua('hook.Remove( "PlayerButtonDown", "menu")')
        end)
	end,
	OnSwitch = function(name, to) end,
	OnConnect = function()
		local cleanup = {'sw','b_sw','ad','ao','b_ad','trig','relay','br','block','unblock','pribytie','nb','b_nb','on','off'}
		local stations = {'nv','nk','se','mr','tr','tretyak'}
		local wildcard = {'dep_'}
		local modelsToClear = {
			['models/metrostroi/signals/mus/lamp_lens.mdl'] = true,
			['models/metrostroi/signals/mus/fixed_outside_2.mdl'] = true,
			['models/kalininskaya/tunnel_5_l.mdl'] = true,
			['models/kalininskaya/tunnel_5_r.mdl'] = true,
			['models/kalininskaya/tunnel_c_l.mdl'] = true,
			['models/kalininskaya/tunnel_c_r.mdl'] = true,
			['models/kalininskaya/tunnel_!_l.mdl'] = true,
			['models/kalininskaya/tunnel_!_r.mdl'] = true,
			['models/kalininskaya/tunnel_35_l.mdl'] = true,
			['models/kalininskaya/tunnel_35_r.mdl'] = true,
		}
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
			if v:GetClass() == 'prop_dynamic' and modelsToClear[v:GetModel()] then
				SafeRemoveEntity(v)
			end
		end
		for k,ent in pairs(ents.FindByName("depo_door_*")) do
			ent:Fire("Open")
			ent:Fire("Lock")
		end	
		for k,ent in pairs(ents.FindByName("depo_moika_door*")) do
			ent:Fire("Open")
			ent:Fire("Lock")
		end	
		for k,ent in pairs(ents.FindByName("depo_metroserv*")) do
			ent:Fire("Open")
			ent:Fire("Lock")
		end	
		for k,ent in pairs(ents.FindByName("motodepo_door*")) do
			ent:Fire("Open")
			ent:Fire("Lock")
		end	
		sbor = nil
	end
}