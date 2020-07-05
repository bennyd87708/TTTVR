---- TTTVR Glock: defines the VR variant of the TTT glock
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_ttt_glock"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the glock
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(28, 5.8, -3.6)
end

-- this doesn't inherit properly so it has to be reiterated here
SWEP.AmmoEnt = "item_ammo_pistol_ttt"