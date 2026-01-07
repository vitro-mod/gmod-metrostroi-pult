function SetupMapLua()
	timer.Simple(3,function()
		   if #ents.FindByName("outputhook") ~= 0 then return end
		   MapLua = ents.Create( "lua_run" )
		   MapLua:SetName( "outputhook" )
		   MapLua:Spawn()
	end)
end
--SetupMapLua()
hook.Add( "InitPostEntity", "SetupMapLua_InitPostEntity", SetupMapLua )
hook.Add( "PostCleanupMap", "SetupMapLua_PostCleanupMap", SetupMapLua )
function AddEntityOutputHook(entity, outputName, hookName)
	entity.outputHooks = entity.outputHooks or {}
	entity.outputHooks[outputName] = entity.outputHooks[outputName] or {}
	if entity.outputHooks[outputName][hookName] ~= nil then return end
	entity:Fire("AddOutput", outputName.." outputhook:RunPassedCode:hook.Run('"..hookName.."'):0:-1")
	entity.outputHooks[outputName][hookName] = true
end
function writeclean()
	print('CLEANUP')
end
hook.Add( "PostCleanupMap", "SetupMapLua_write", writeclean )