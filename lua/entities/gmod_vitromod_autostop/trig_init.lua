local function RegisterAutostopTrigger()
    local trigger = scripted_ents.Get("base_brush")
    function trigger:Initialize()
        self:SetSolid(SOLID_OBB)
        self:SetCollisionBounds(Vector(-20, -1, -10), Vector(20, 1, 50))
        self:SetTrigger(true)
    end

    scripted_ents.Register(trigger, "gmod_vitromod_astoptrig")
end

RegisterAutostopTrigger()
