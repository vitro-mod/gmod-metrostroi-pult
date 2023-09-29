VitroMod.Pult.Map = {
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