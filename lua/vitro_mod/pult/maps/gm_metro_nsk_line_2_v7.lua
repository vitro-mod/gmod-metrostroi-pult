VitroMod.Pult.Map = {
    Init = function()
		VitroMod.Pult.SwitchesInvert = {}

		local renameTable = {
			{gm = 'zn_switch1', pult = 'trackswitch_zn1'},
			{gm = 'zn_switch4', pult = 'trackswitch_zn2'},
			{gm = 'trackswitch_pg1', pult = 'trackswitch_gm1'},
			{gm = 'trackswitch_pg2', pult = 'trackswitch_gm2'},
		}
		for _,r in pairs(renameTable) do
			for k,v in pairs(ents.FindByName(r.gm)) do
				v:SetName(r.pult)
			end
		end
	end,
	OnSwitch = function(name, to)
	end,
	OnConnect = function()
	end
}
