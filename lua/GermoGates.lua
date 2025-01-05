VitroMod.Pult.GermoGates = {
    Entities = {},
    States = {},
    Locked = {},
    Init = function(entities)
        if not entities then return false end
        for k, entity in pairs(entities) do
            if not IsValid(entity) then return false end

            VitroMod.Pult.GermoGates.Entities[entity:GetName()] = entity
            VitroMod.Pult.GermoGates.States[entity:GetName()] = entity:GetSaveTable().m_toggle_state
            VitroMod.Pult.GermoGates.Locked[entity:GetName()] = false

            addEntityOutputHook(entity, 'OnFullyOpen', 'mkSend')
            addEntityOutputHook(entity, 'OnFullyClosed', 'mkSend')
            addEntityOutputHook(entity, 'OnOpen', 'mkSend')
            addEntityOutputHook(entity, 'OnClose', 'mkSend')
        end
    end,
    UpdateState = function(entity)
        if not IsValid(entity) then return false end
        VitroMod.Pult.GermoGates.States[entity:GetName()] = entity:GetSaveTable().m_toggle_state
    end,
    UpdateLocks = function(lockStates)
        for name, lockState in pairs(lockStates) do
            local ent = VitroMod.Pult.GermoGates.Entities[name]
            if not IsValid(ent) then continue end
            VitroMod.Pult.GermoGates.Locked[name] = lockState != 1
        end

        PrintTable(VitroMod.Pult.GermoGates.Locked)
    end,
    GetAll = function()
        return VitroMod.Pult.GermoGates.States
    end,
}

function sendMKInfoV2()
    local ctrl = CALLER:GetSaveTable().m_toggle_state
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
