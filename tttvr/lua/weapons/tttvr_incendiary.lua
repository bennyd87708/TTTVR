---- TTTVR Incendiary: defines the VR variant of the TTT incendiary
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_molotov"

-- add the changes that apply to every VR variant grenade from tttvr_base
include("tttvr_basegrenade.lua")