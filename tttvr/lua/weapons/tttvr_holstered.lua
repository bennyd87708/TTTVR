---- TTTVR Holstered: defines the VR variant of the TTT unarmed weapon
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_ttt_unarmed"

-- change the model and make sure it isn't default
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:holstered", function()
		TTTVRWeaponReplacements["weapon_ttt_unarmed"] = "tttvr_holstered"
	end)
end