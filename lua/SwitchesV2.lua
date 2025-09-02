VitroMod.Pult.Switches = {
    InvertAll = false,
    Entities = {},
    Inverted = {},
    States = {},
    Locked = {},
    Init = function(entities, invertAll)
        VitroMod.Pult.Switches.InvertAll = invertAll or false
        if not entities then return false end
        for k, entity in pairs(entities) do
            if not IsValid(entity) then return false end

            VitroMod.Pult.Switches.Entities[entity:GetName()] = entity
            VitroMod.Pult.Switches.Inverted[entity:GetName()] = invertAll

            if VitroMod.Pult.SwitchesInvert[entity:GetName()] ~= nil then
                VitroMod.Pult.Switches.Inverted[entity:GetName()] = VitroMod.Pult.SwitchesInvert[entity:GetName()]
            end

            local state = entity:GetInternalVariable( "m_eDoorState" )

            VitroMod.Pult.Switches.States[entity:GetName()] = invertAll and VitroMod.Pult.Switches.InvertControl(state) or state
            VitroMod.Pult.Switches.Locked[entity:GetName()] = false

            addEntityOutputHook(entity, 'OnFullyOpen', 'swSend')
            addEntityOutputHook(entity, 'OnFullyClosed', 'swSend')
            addEntityOutputHook(entity, 'OnOpen', 'swSend')
            addEntityOutputHook(entity, 'OnClose', 'swSend')
        end
    end,
    UpdateState = function(entity)
        if not IsValid(entity) then return false end
        local state = entity:GetInternalVariable( "m_eDoorState" )
        local inverted = VitroMod.Pult.Switches.Inverted[entity:GetName()] or false
        VitroMod.Pult.Switches.States[entity:GetName()] = inverted and VitroMod.Pult.Switches.InvertControl(state) or state
    end,
    UpdateLocks = function(lockStates)
        for name, lockState in pairs(lockStates) do
            local ent = VitroMod.Pult.Switches.Entities[name]
            if not IsValid(ent) then continue end
            VitroMod.Pult.Switches.Locked[name] = lockState ~= 1
        end
    end,
    GetAll = function()
        return VitroMod.Pult.Switches.States
    end,
    GetLocked = function()
        return VitroMod.Pult.Switches.Locked
    end,
    Switch = function(name, to)
        local inverted = VitroMod.Pult.Switches.Inverted[name] or false
        if inverted then to = not to end
        name = name:Replace('.', '_')
        local ent = VitroMod.Pult.Switches.Entities[name]
        if not IsValid(ent) then return end
        ent:Fire('Unlock')
        ent:Fire(not to and 'Close' or 'Open')
    end,
    InvertControl = function(ctrl)
        if ctrl == 1 then return 0 end
        if ctrl == 0 then return 1 end
        return ctrl
    end

}