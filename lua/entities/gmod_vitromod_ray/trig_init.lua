local function RegisterRayTrigger()
	local trigger = scripted_ents.Get("base_brush")

	function trigger:Initialize()
		self:SetSolid(SOLID_OBB)
		self:SetCollisionBounds(Vector(-1, -1, -1 ), Vector(1, 1, 1 ))
		self:SetTrigger(true)
	end

	scripted_ents.Register( trigger, "gmod_vitromod_ray_trig" )
end

RegisterRayTrigger()
