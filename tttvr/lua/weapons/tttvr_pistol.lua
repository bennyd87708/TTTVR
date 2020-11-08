---- TTTVR Pistol: defines the VR variant of the TTT Pistol
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_pistol"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the pistol
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(27.6, 5.95, -3.6)
end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Icon = "vgui/ttt/icon_pistol"
SWEP.PrintName = "pistol_name"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:pistol", function()
		TTTVRWeaponReplacements["weapon_zm_pistol"] = "tttvr_pistol"
	end)
end