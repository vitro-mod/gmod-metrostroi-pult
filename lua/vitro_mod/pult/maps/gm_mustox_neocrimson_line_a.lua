VitroMod.Pult.Map = {
    Init = function()
        local swtRemap = {
			{gm = 'AutoInstance4trackswitch_551_1', pult = 'br1'},

		}
		for _,r in pairs(swtRemap) do
			for k,v in pairs(ents.FindByName(r.gm)) do
				v:SetName('trackswitch_' .. r.pult)
			end
		end
		VitroMod.Pult.SwitchesInvert = {}
    end,
    
	OnSwitch = function(name, to)
    end,

    OnConnect = function()
    end
}