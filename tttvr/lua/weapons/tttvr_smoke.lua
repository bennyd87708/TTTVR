---- TTTVR Smoke grenade: defines the VR variant of the TTT smoke
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_ttt_smokegrenade"

-- add the changes that apply to every VR variant grenade from tttvr_base
include("tttvr_basegrenade.lua")