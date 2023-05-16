hook.Add("Initialize", "Socket", function()
	timer.Simple(3.0,function() include("socket.lua") end)
end)

function swt(name, pos)
    for k,v in pairs(ents.FindByName('trackswitch_'..name)) do
        v:Fire(pos and 'Close' or 'Open')
    end
end