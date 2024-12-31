VitroMod.Pult.IntervalClocks = {
	Entities = {},
	Classes = {
		'gmod_track_clock_interval',
		'gmod_track_clock_small',
		'gmod_track_clock_interval_nsk'
	},

	Init = function()
		for _, class in pairs(VitroMod.Pult.IntervalClocks.Classes) do
			for k,clock in pairs(ents.FindByClass(class)) do
				VitroMod.Pult.IntervalClocks.Entities[clock:GetName()] = VitroMod.Pult.IntervalClocks.Entities[clock:GetName()] or {}
				table.insert(VitroMod.Pult.IntervalClocks.Entities[clock:GetName()], clock)
			end
		end
	end,

	Reset = function(name)
		VitroMod.Pult.Intervals[name] = 0
		if not VitroMod.Pult.IntervalClocks.Entities[name] then return end

		for k,clock in pairs(VitroMod.Pult.IntervalClocks.Entities[name]) do
			if not IsValid(clock) then continue end
			clock.NoAutoSearch = true
			clock.IntervalReset = false
			clock:Fire("Reset")
		end
	end,

	GetInterval = function(name)
		if not VitroMod.Pult.IntervalClocks.Entities[name] then return false end
		local clock = VitroMod.Pult.IntervalClocks.Entities[name][1]
		if not IsValid(clock) then return false end

		local it = math.floor(Metrostroi.GetSyncTime() - clock:GetIntervalResetTime() - GetGlobalFloat("MetrostroiTY"))
		if it < 0 then it = false end

		return it
	end,

	Update = function()
		VitroMod.Pult.Intervals = VitroMod.Pult.Intervals or {}
		for name,clock in pairs(VitroMod.Pult.IntervalClocks.Entities) do
			VitroMod.Pult.Intervals[name] = VitroMod.Pult.IntervalClocks.GetInterval(name)
		end
	end,

	Get = function()
		return VitroMod.Pult.Intervals
	end,
}

VitroMod.Pult.IntervalClocks.Init()
