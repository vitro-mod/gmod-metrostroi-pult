VitroMod.Pult.IntervalClocks = VitroMod.Pult.IntervalClocks or {}
VitroMod.Pult.IntervalSmall = VitroMod.Pult.IntervalSmall or {}
for k,v in pairs(ents.FindByClass('gmod_track_clock_interval')) do
	VitroMod.Pult.IntervalClocks[v:GetName()] = v
end
for k,v in pairs(ents.FindByClass('gmod_track_clock_small')) do
	VitroMod.Pult.IntervalSmall[v:GetName()] = v
end

VitroMod.Pult.ResetClock = function(name)
	if IsValid(VitroMod.Pult.IntervalClocks[name]) then
		VitroMod.Pult.IntervalClocks[name].NoAutoSearch = true
		VitroMod.Pult.IntervalClocks[name].IntervalReset = false
		VitroMod.Pult.IntervalClocks[name]:Fire("Reset")	
	end

	if IsValid(VitroMod.Pult.IntervalSmall[name]) then
		VitroMod.Pult.IntervalSmall[name].NoAutoSearch = true
		VitroMod.Pult.IntervalSmall[name].IntervalReset = false
		VitroMod.Pult.IntervalSmall[name]:Fire("Reset")	
		VitroMod.Pult.Intervals[name] = 0	
	end
end

VitroMod.Pult.GetInterval = function(name)
	if not IsValid(VitroMod.Pult.IntervalClocks[name]) then return false end
	local it = math.floor(Metrostroi.GetSyncTime() - VitroMod.Pult.IntervalClocks[name]:GetIntervalResetTime() - GetGlobalFloat("MetrostroiTY"))
	if it < 0 then it = false end
	return it
end

VitroMod.Pult.Intervals = VitroMod.Pult.Intervals or {}
VitroMod.Pult.UpdateIntervals = function()
	for k,v in pairs(VitroMod.Pult.IntervalClocks) do
		VitroMod.Pult.Intervals[k] = VitroMod.Pult.GetInterval(k)
	end
end