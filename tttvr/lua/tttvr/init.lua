---- Serverside Initialization

-- forces clients to have all scripts
AddCSLuaFile "actions.lua"
AddCSLuaFile "rebindings.lua"
AddCSLuaFile "buymenuui.lua"
AddCSLuaFile "weaponui.lua"
AddCSLuaFile "scoreui.lua"
AddCSLuaFile "radarui.lua"
AddCSLuaFile "bombui.lua"
AddCSLuaFile "muzzleoffset.lua"
AddCSLuaFile "roleui.lua"
AddCSLuaFile "searchui.lua"
AddCSLuaFile "spectator.lua"
AddCSLuaFile "cl_init.lua"

-- runs serverside scripts
include "tttvr/weaponreplacer.lua"
include "tttvr/suicide.lua"
include "tttvr/pickup.lua"
include "tttvr/network.lua"
include "tttvr/spectator.lua"