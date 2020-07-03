---- TTTVR Base Weapon: has SWEP functions/variables that should apply to all TTTVR weapons
AddCSLuaFile()

SWEP.Spawnable = true
SWEP.AllowDrop = true
SWEP.WeaponID = nil
SWEP.Category = "TTTVR"

-- muzzle flashes come from world model position - no clue for now but maybe will fix here eventually

--[[
-- enable ironsights boolean when actually kinda looking down the ironsights for slightly increased accuracy?
-- turns out it doesnt apply when in VR so keeping just in case it is needed later for scoping in
function SWEP:Think()
	if not (g_VR.viewModelMuzzle and vrmod.IsPlayerInVR(self:GetOwner())) then return end
	local hmdpos, hmdang = vrmod.GetHMDPose(self:GetOwner())
	local x0 = g_VR.viewModelMuzzle.Pos
	local x1 = hmdpos
	local x2 = hmdpos + hmdang:Forward()*500
	local part1 = x0 - x1
	local part1abs = Vector(math.abs(part1.x), math.abs(part1.y), math.abs(part1.z))
	local part2 = x0 - x2
	local part2abs = Vector(math.abs(part2.x), math.abs(part2.y), math.abs(part2.z))
	local d = (part1abs:Cross(part2abs))/(x2:Distance(x1))
	
	local a = hmdang:Forward()
	local b = g_VR.viewModelMuzzle.Ang:Forward()
	local theta = a:Dot(b)
	
	if((d:Length() < 10) and (math.deg(math.acos(theta)) < 20)) then
		self:SetIronsightsPredicted(true)
	else
		self:SetIronsightsPredicted(true)
	end
end
--]]

-- converts the VR weapon into its normal variant when it gets dropped
local base = baseclass.Get(SWEP.Base)
function SWEP:PreDrop()
	base.PreDrop(self)
	
	-- figure out how much ammo was stored in the weapon drop and then add that to the replacement weapon before dropping it
	local ply = self:GetOwner()
	local newgun = convertTTTVRWeaponToNormal(self)
	newgun.StoredAmmo = self.StoredAmmo
	ply:DropWeapon(newgun)
end