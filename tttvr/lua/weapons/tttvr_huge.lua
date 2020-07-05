---- TTTVR H.U.G.E. 249: defines the VR variant of the TTT HUGE
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_sledge"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the HUGE
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(43, 6, -4.6)
end