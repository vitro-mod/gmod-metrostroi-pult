VitroMod = VitroMod or {}
VitroMod.Pult = VitroMod.Pult or {}
--VitroMod.Pult.Maps = VitroMod.Pult.Maps or {}

local mapName = game.GetMap()

include('vitro_mod/pult/maps/'..mapName..'.lua')
VitroMod.Pult.Map = map
