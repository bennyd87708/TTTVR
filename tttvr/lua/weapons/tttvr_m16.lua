---- TTTVR M16: defines the VR variant of the TTT M16
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_ttt_m16"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the M16
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(33, 6.8, -3.8)
end

-- replace drop function to prevent game crash from the same infinite looping of base classes
function SWEP:PreDrop()
	self:SetZoom(false)
	self:SetIronsights(false)
	local ply = self:GetOwner()
	
	if SERVER and IsValid(ply) and self.Primary.Ammo != "none" then
		local ammo = self:Ammo1()

		-- Do not drop ammo if we have another gun that uses this type
		for _, w in ipairs(ply:GetWeapons()) do
			if IsValid(w) and w != self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
				ammo = 0
			end
		end

		self.StoredAmmo = ammo

		if ammo > 0 then
			ply:RemoveAmmo(ammo, self.Primary.Ammo)
		end
	end
	
	local newgun = convertTTTVRWeaponToNormal(self)
	newgun.StoredAmmo = self.StoredAmmo
	ply:DropWeapon(newgun)
end

-- this doesn't inherit properly so it has to be reiterated here
SWEP.AmmoEnt = "item_ammo_pistol_ttt"