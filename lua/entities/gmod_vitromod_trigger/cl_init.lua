ENT.Type            = "brush"
ENT.Base            = "base_brush"
VitroMod = VitroMod or {}
VitroMod.Triggers = VitroMod.Triggers or {}
VitroMod.draw = false
net.Receive("vitromod_trigger", function(len, ply)
    VitroMod.Triggers = net.ReadTable()
    --PrintTable(VitroMod.Triggers)
end)
net.Receive("vitromod_trigger_one", function(len, ply)
	local name = net.ReadString()
	local tb = net.ReadTable()
	VitroMod.Triggers[name] = tb
	--print(name)
	--PrintTable(tb)
end)
net.Receive("vitromod_trigger_draw", function(len, ply)
	VitroMod.draw = net.ReadBool()
	--print('draw',VitroMod.draw)
end)
local function drawBox()
    if not VitroMod.draw then return end
    if not VitroMod.Triggers then return end
	render.SetColorMaterial()
    for k,v in pairs(VitroMod.Triggers) do
		for k2,v2 in pairs(v) do
			if k2 ~= "occ" then
				--local col = v2.pos:DistToSqr(Entity(1):GetEyeTrace().HitPos) > 100 and Color(255,200,0) or Color(0,255,0)
				local col = v.occ and Color(255,0,0) or Color(255,200,0)
				if v2.pos and v2.angle and v2.min and v2.max then render.DrawWireframeBox(v2.pos,v2.angle,v2.min,v2.max, col) end
				if v2.beg then render.DrawSphere(v2.beg, 5, 5, 5, col) end
				if v2.pos then render.DrawSphere(v2.pos, 10, 5, 5, col) end
				if v2.fin then render.DrawWireframeSphere(v2.fin, 5, 5, 5, col) end
			end
		end
    end
end
hook.Add('PostDrawOpaqueRenderables','myDraw', drawBox)
