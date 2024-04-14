---- TTTVR Glock: defines the VR variant of the TTT glock
AddCSLuaFile()

-- stop annoying errors
if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end

-- base it off of the original
SWEP.Base = "weapon_ttt_glock"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the glock
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(28, 5.8, -3.6)
end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Icon = "vgui/ttt/icon_glock"
SWEP.PrintName = "Glock"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:glock", function()
		TTTVRWeaponReplacements["weapon_ttt_glock"] = "tttvr_glock"
	end)
end