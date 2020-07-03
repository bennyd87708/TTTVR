---- TTTVR Mac-10: defines the VR variant of the TTT Mac-10
AddCSLuaFile()

-- base it off of the original
SWEP.Base = "weapon_zm_mac10"

-- add the changes that apply to every VR variant weapon from tttvr_base
include("tttvr_base.lua")

-- on weapon switch, adjust the global muzzle offset to the right numbers for the mac-10
-- mac-10 viewmodel doesn't point straight forward so this one is a little bit wrong for now
function SWEP:SetMuzzleOffset()
	TTTVRCurrentMuzzleOffset = Vector(29, 6.8, -4.5)
end

-- make the weapon spawnable in sandbox just in case someone wants to use it
SWEP.Spawnable = true

-- this doesn't inherit properly so it has to be reiterated here
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- fix infinite loop of base classes for primary fire - copied from weapon_tttbase
function SWEP:PrimaryAttack(worldsnd)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if not self:CanPrimaryAttack() then return end

	if not worldsnd then
		self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end

	self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())

	self:TakePrimaryAmmo( 1 )

	local owner = self:GetOwner()
	if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end

	--owner:ViewPunch( Angle( util.SharedRandom(self:GetClass(),-0.2,-0.1,0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(),-0.1,0.1,1) * self.Primary.Recoil, 0 ) )

end