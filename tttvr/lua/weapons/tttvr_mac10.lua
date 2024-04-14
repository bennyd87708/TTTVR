---- TTTVR Mac-10: defines the VR variant of the TTT Mac-10
AddCSLuaFile()

-- stop annoying errors
if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end

-- base it off of the original
SWEP.Base = "weapon_zm_mac10"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the mac-10
-- mac-10 viewmodel doesn't point straight forward so this one is a little bit wrong for now
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(29, 6.8, -4.5)
end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Icon = "vgui/ttt/icon_mac"
SWEP.PrintName = "MAC10"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:mac10", function()
		TTTVRWeaponReplacements["weapon_zm_mac10"] = "tttvr_mac10"
	end)
end