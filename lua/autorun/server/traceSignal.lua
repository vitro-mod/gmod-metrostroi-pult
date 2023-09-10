function traceSignal(name)
 print(string.format('Tracing signals from %s...', name))
	out = ''
	outTable = {}
	sig = Metrostroi.GetSignalByName(name) 
	dist = sig:GetNW2Float("DistanceToNext") 
	nxt = sig:GetNW2String("NextSignalName")

	--print(sig.Name, dist, nxt)
	out = out .. string.format("%-8s\t%f\t\t%s\n", sig.Name, dist, nxt)
	outTable[sig.Name] = {next = nxt, dist = dist}


	while sig.Name != nxt do
		sig = Metrostroi.GetSignalByName(tostring(nxt))
		if not sig then break end
		dist = sig:GetNW2Float("DistanceToNext")
		nxt = sig:GetNW2String("NextSignalName")
		out = out .. string.format("%-8s\t%f\t\t%s\n", sig.Name, dist, nxt)
		outTable[sig.Name] = {next = nxt, dist = dist}
		--print(sig.Name, dist, nxt)
	end

	if not file.Exists("metrostroi_data","DATA") then 
		file.CreateDir("metrostroi_data")
	end
	
	map = game.GetMap()
	
	local filename = string.format("metrostroi_data/%s_%s.txt", map, name)
	local filenameJson = string.format("metrostroi_data/%s_%s.json", map, name)
	print("Dumping signals to ", filename)
	file.Write(filename, out)
	file.Write(filenameJson, util.TableToJSON(outTable))
end
