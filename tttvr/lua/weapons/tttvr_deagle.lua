---- TTTVR Deagle: defines the VR variant of the TTT deagle
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_revolver"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the deagle
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(31.5, 6.3, -3.5)
end

-- this doesn't inherit properly so it has to be reiterated here
SWEP.AmmoEnt = "item_ammo_revolver_ttt"