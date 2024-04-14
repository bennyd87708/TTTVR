---- TTTVR Rifle: defines the VR variant of the TTT rifle
AddCSLuaFile()

-- stop annoying errors
if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end

-- base it off of the original
SWEP.Base = "weapon_zm_rifle"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the rifle
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(41.5, 6.7, -5)
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

-- get rid of right click to zoom function
function SWEP:SecondaryAttack() return end

-- these don't inherit properly because of LUA ordering so they have to be reiterated here
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.Icon = "vgui/ttt/icon_scout"
SWEP.PrintName = "rifle_name"

-- add table entry to the global list of weapon replacements
if SERVER then
	hook.Add("TTTVR:Initialize", "Benny:TTTVR:Initialization:rifle", function()
		TTTVRWeaponReplacements["weapon_zm_rifle"] = "tttvr_rifle"
	end)
end