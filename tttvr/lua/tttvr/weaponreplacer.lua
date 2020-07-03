---- Weapon Replacer: Replace regular weapons with VR variants for VR users

-- global keeps track of what TTT weapons are replaced by what VR variants - maybe add some kind of config file?
TTTVRWeaponReplacements = {}
TTTVRWeaponReplacements["weapon_zm_improvised"] = 	"tttvr_crowbar"
TTTVRWeaponReplacements["weapon_zm_revolver"] = 	"tttvr_deagle"
TTTVRWeaponReplacements["weapon_ttt_glock"] = 		"tttvr_glock"
TTTVRWeaponReplacements["weapon_ttt_unarmed"] = 	"tttvr_holstered"
TTTVRWeaponReplacements["weapon_zm_sledge"] = 		"tttvr_huge"
TTTVRWeaponReplacements["weapon_ttt_m16"] = 		"tttvr_m16"
TTTVRWeaponReplacements["weapon_zm_mac10"] = 		"tttvr_mac10"
TTTVRWeaponReplacements["weapon_zm_carry"] = 		"tttvr_magnetostick"
TTTVRWeaponReplacements["weapon_zm_pistol"] = 		"tttvr_pistol"
TTTVRWeaponReplacements["weapon_zm_rifle"] = 		"tttvr_rifle"
TTTVRWeaponReplacements["weapon_zm_shotgun"] =		"tttvr_shotgun"

-- reverse table lookup so we can search in both directions (get key from value)
function getTTTVROriginalWeapon(vrgun)
	for k, wep in pairs(TTTVRWeaponReplacements) do
		if(wep == vrgun) then
			return k
		end
	end
end

-- replaces a normal weapon in a player's inventory with the VR version using the above table if they are in VR
function convertWeaponToTTTVR(normalgun, ply)
	if(IsValid(ply) and istable(vrmod)) then
		if not vrmod.IsPlayerInVR(ply) then return end
		local vr_replacement = TTTVRWeaponReplacements[normalgun:GetClass()]
		if not vr_replacement then return end
			
		-- uses Tick hook because for some reason we have to wait a frame before we can strip the weapon and we have to do that first for a different, unknown reason
		hook.Add("Tick","Benny:TTTVR:waitonetickfornoreasonhook"..tostring(vr_replacement),function()
		
			-- removes old weapon and gives player the new one with the same amount of ammo
			ply:StripWeapon(normalgun:GetClass())
			local newgun = ply:Give(vr_replacement, true)
			newgun:SetClip1(normalgun:Clip1())
			hook.Remove("Tick","Benny:TTTVR:waitonetickfornoreasonhook"..tostring(vr_replacement))
		end)
	end
end

-- replaces a VR weapon in a player's inventory with the normal version using the
function convertTTTVRWeaponToNormal(vrgun)
	local ply = vrgun:GetOwner()
	if(IsValid(ply)) then
		local k = getTTTVROriginalWeapon(vrgun:GetClass())
		if not k then return end
		hook.Remove("WeaponEquip", "Benny:TTTVR:weaponreplacerhook")
		
		-- removes old weapon and gives player the new one with the same amount of ammo
		-- need to remove and re-add the WeaponEquip hook so that the other script doesn't try to convert this weapon to a VR version
		ply:StripWeapon(vrgun:GetClass())
		local normalgun = ply:Give(k)
		normalgun:SetClip1(vrgun:Clip1())
		
		TTTVRAddReplacementHook()
		return normalgun
	end
end

-- function to add the hook that monitors for when a player receives a weapon to see if we need to convert to VR
-- in a function because we need to remove and re-add it frequently
function TTTVRAddReplacementHook()
	hook.Add("WeaponEquip", "Benny:TTTVR:weaponreplacerhook", function(wep, ply)
		if(vrmod.IsPlayerInVR(ply)) then
			convertWeaponToTTTVR(wep, ply)
		end
	end)
end

-- calls the function so it is always checking for VR users on start
TTTVRAddReplacementHook()

-- when someone enters VR, go through all of their weapons and convert any to VR variants
hook.Add("VRUtilStart", "Benny:TTTVR:initialweaponreplacerhook", function(ply)
	for k, wep in pairs(ply:GetWeapons()) do
		convertWeaponToTTTVR(wep, ply)
	end
end)

-- when someone exits VR, go through all of their weapons and convert any VR to normal variants
hook.Add("VRUtilExit", "Benny:TTTVR:endweaponreplacerhook", function(ply)
	for k, wep in pairs(ply:GetWeapons()) do
		convertTTTVRWeaponToNormal(wep)
	end
end)