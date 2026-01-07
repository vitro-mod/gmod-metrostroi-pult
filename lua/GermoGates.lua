VitroMod.Pult.GermoGates = {
    Entities = {},
    Inverted = {},
    States = {},
    Locked = {},
    Init = function(entities, invert)
        local invertAll = invert or false
        if not entities then return false end
        for k, entity in pairs(entities) do
            if not IsValid(entity) then return false end

            VitroMod.Pult.GermoGates.Entities[entity:GetName()] = entity
            VitroMod.Pult.GermoGates.Inverted[entity:GetName()] = invertAll

            local state = entity:GetInternalVariable( "m_toggle_state" )

            VitroMod.Pult.GermoGates.States[entity:GetName()] = invertAll and VitroMod.Pult.GermoGates.InvertControl(state) or state
            VitroMod.Pult.GermoGates.Locked[entity:GetName()] = false

            AddEntityOutputHook(entity, 'OnFullyOpen', 'mkSend')
            AddEntityOutputHook(entity, 'OnFullyClosed', 'mkSend')
            AddEntityOutputHook(entity, 'OnOpen', 'mkSend')
            AddEntityOutputHook(entity, 'OnClose', 'mkSend')
        end
    end,
    UpdateState = function(entity)
        if not IsValid(entity) then return false end
        local state = entity:GetInternalVariable( "m_toggle_state" )
        local inverted = VitroMod.Pult.GermoGates.Inverted[entity:GetName()] or false
        VitroMod.Pult.GermoGates.States[entity:GetName()] = inverted and VitroMod.Pult.GermoGates.InvertControl(state) or state
    end,
    UpdateLocks = function(lockStates)
        for name, lockState in pairs(lockStates) do
            local ent = VitroMod.Pult.GermoGates.Entities[name]
            if not IsValid(ent) then continue end
            VitroMod.Pult.GermoGates.Locked[name] = lockState != 1
        end
    end,
    GetAll = function()
        return VitroMod.Pult.GermoGates.States
    end,
    Switch = function(name, to)
        local inverted = VitroMod.Pult.GermoGates.Inverted[name] or false
        if inverted then to = not to end
        name = name:Replace('.','_')
        local ent = VitroMod.Pult.GermoGates.Entities[name]
        if not IsValid(ent) then return end
        ent:Fire('Unlock')
        ent:Fire(not to and 'Close' or 'Open')
    end,
    InvertControl = function(ctrl)
        if ctrl == 1 then return 0 end
        if ctrl == 0 then return 1 end
        return ctrl
    end,
}

function sendMKInfoV2()
    local ctrl = CALLER:GetInternalVariable( "m_toggle_state" )
    if VitroMod.Pult.GermoGates.Inverted[CALLER:GetName()] then
        ctrl = VitroMod.Pult.GermoGates.InvertControl(ctrl)
    end
    local name = CALLER:GetName()
    local mkmsg = 'BV_' .. util.TableToJSON({
        [name] = ctrl
    })

    if not VitroMod.Pult.IsMaster then return end
    WriteToSocket(mkmsg)
end

hook.Add('mkSend', 'mkSendInfo', function()
    VitroMod.Pult.GermoGates.UpdateState(CALLER)
    sendMKInfoV2()
end)

hook.Add( 'AcceptInput', 'VitroMod.Pult.GermoGates.Locks', function( ent, name, activator, caller, data )
    if ( name == 'Close' and VitroMod.Pult.GermoGates.Locked[ent:GetName()] ) then
        return true
    end
end )
