---- Serverside Initialization

-- forces clients to have all scripts
AddCSLuaFile "cl_init.lua"

AddCSLuaFile "rebindings.lua"
AddCSLuaFile "buymenuui.lua"
AddCSLuaFile "weaponui.lua"
AddCSLuaFile "scoreui.lua"
AddCSLuaFile "radarui.lua"
AddCSLuaFile "muzzleoffset.lua"
AddCSLuaFile "roleui.lua"

-- runs serverside scripts
include "tttvr/weaponreplacer.lua"
include "tttvr/suicide.lua"
include "tttvr/pickup.lua"