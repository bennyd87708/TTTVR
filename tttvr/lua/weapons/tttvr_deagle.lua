---- TTTVR Deagle: defines the VR variant of the TTT deagle
AddCSLuaFile()

-- stop annoying errors
if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end

-- base it off of the original
SWEP.Base = "weapon_zm_revolver"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the deagle
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(31.5, 6.3, -3.5)
end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_ammo_revolver_ttt"
SWEP.Icon = "vgui/ttt/icon_deagle"
SWEP.PrintName = "Deagle"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:deagle", function()
		TTTVRWeaponReplacements["weapon_zm_revolver"] = "tttvr_deagle"
	end)
end