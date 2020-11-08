---- TTTVR Crowbar: defines the VR variant of the TTT crowbar
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_improvised"

-- make sure you can't drop it
SWEP.AllowDrop = false
SWEP.InLoadoutFor = {}
SWEP.WeaponID = nil
SWEP.Category = "TTTVR"

-- on weapon switch, adjust the global muzzle offset to the right numbers for the crowbar
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(32, 13, -17)
end

-- even though this part might not work properly in singleplayer it should make it more consistent in multiplayer which is usually how ttt is played
function SWEP:Deploy()
	self:SetMuzzleOffset()
end

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:crowbar", function()
		TTTVRWeaponReplacements["weapon_zm_improvised"] = "tttvr_crowbar"
	end)
end