---- TTTVR Shotgun: defines the VR variant of the TTT shotgun
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_shotgun"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the shotgun
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(42, 6.4, -4)
end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.Icon = "vgui/ttt/icon_shotgun"
SWEP.PrintName = "shotgun_name"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:shotgun", function()
		TTTVRWeaponReplacements["weapon_zm_shotgun"] = "tttvr_shotgun"
	end)
end