---- TTTVR Crowbar: defines the VR variant of the TTT crowbar
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_improvised"

-- make sure it isn't default
SWEP.InLoadoutFor = {}

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the crowbar
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(32, 13, -17)
end

-- make sure you can't drop it
SWEP.AllowDrop = false