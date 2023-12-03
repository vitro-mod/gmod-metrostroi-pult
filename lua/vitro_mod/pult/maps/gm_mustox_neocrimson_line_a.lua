VitroMod.Pult.Map = {
    Init = function()
        local swtIdRemap = {
            {id = 74, pult = 'mt2'},
            {id = 75, pult = 'mt2'},
            {id = 76, pult = 'mt1'},
            {id = 77, pult = 'mt1'},
            {id = 82, pult = 'mt7'},
            {id = 83, pult = 'mt7'},
            {id = 84, pult = 'mt8'},
            {id = 85, pult = 'mt8'},

            {id = 391, pult = 'mt14'},
            {id = 392, pult = 'mt14'},
            {id = 393, pult = 'mt15'},
            {id = 394, pult = 'mt15'},
            {id = 395, pult = 'mt16'},
            {id = 396, pult = 'mt16'},
            {id = 397, pult = 'mt13'},
            {id = 398, pult = 'mt13'},
        }
		for _,r in pairs(swtIdRemap) do
            Entity(r.id):SetName('trackswitch_' .. r.pult)
		end

        local swtRemap = {
			{gm = 'AutoInstance4trackswitch_551_1', pult = 'br1'},
			{gm = 'AutoInstance4trackswitch_551_2', pult = 'br2'},
			{gm = 'AutoInstance4trackswitch_551_3', pult = 'br3'},
			{gm = 'AutoInstance4trackswitch_551_4', pult = 'br4'},

			{gm = 'trackswitch_12', pult = 'pn1'},
			{gm = 'trackswitch_13', pult = 'pn2'},

			{gm = 'trackswitch_21', pult = 'mt3'},
			{gm = 'trackswitch_22', pult = 'mt5'},
			{gm = 'trackswitch_401', pult = 'mt9'},
			{gm = 'trackswitch_208', pult = 'mt11'},
			{gm = 'trackswitch_203', pult = 'mt12'},

            {gm = 'trackswitch_7', pult = 'fn2'},
			{gm = 'trackswitch_8', pult = 'fn1'},
			{gm = 'trackswitch_9', pult = 'fn3'},

			{gm = 'trackswitch_877', pult = 'st7'},
			{gm = 'trackswitch_656', pult = 'st8'},
			{gm = 'trackswitch_5571', pult = 'st5'},
			{gm = 'trackswitch_5572', pult = 'st6'},
			{gm = 'trackswitch_5573', pult = 'st3'},
			{gm = 'trackswitch_5574', pult = 'st4'},
			{gm = 'trackswitch_5575', pult = 'st1'},
			{gm = 'trackswitch_5576', pult = 'st2'},
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