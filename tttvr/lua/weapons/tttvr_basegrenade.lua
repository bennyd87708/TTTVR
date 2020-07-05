---- TTTVR Base Grenade: has SWEP functions/variables that should apply to all TTTVR grenades
AddCSLuaFile()

SWEP.Spawnable = true
SWEP.AllowDrop = true
SWEP.InLoadoutFor = {}
SWEP.WeaponID = nil
SWEP.Category = "TTTVR"

-- converts the VR weapon into its normal variant when it gets dropped
local base = baseclass.Get(SWEP.Base)
function SWEP:PreDrop()
	base.PreDrop(self)
	
	-- spawn replacement grenade and then drop it
	local ply = self:GetOwner()
	local newgun = convertTTTVRWeaponToNormal(self)
	ply:DropWeapon(newgun)
	
	ply:SelectWeapon("tttvr_holstered")
end

-- after throwing a grenade, switch to the TTTVR holstered weapon
function SWEP:Throw()
	base.Throw(self)
	
	if CLIENT then return end
	local ply = self:GetOwner()
	timer.Simple(1, function()
		ply:SelectWeapon("tttvr_holstered")
	end)
end