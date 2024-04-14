---- TTTVR Discombobulator: defines the VR variant of the TTT discombobulator
AddCSLuaFile()

-- stop annoying errors
if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end

-- base it off of the original
SWEP.Base = "weapon_ttt_confgrenade"

-- add the changes that apply to every VR variant grenade from tttvr_base
include("tttvr_basegrenade.lua")

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:discombobulator", function()
		TTTVRWeaponReplacements["weapon_ttt_confgrenade"] =	"tttvr_discombobulator"
	end)
end