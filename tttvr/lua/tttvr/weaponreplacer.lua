---- Weapon Replacer: Replace regular weapons with VR variants for VR users

-- global keeps track of what TTT weapons are replaced by what VR variants, added in each weapon script
TTTVRWeaponReplacements = {}

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
	
	-- start out holstered so that selected weapon model isn't unrendered
	timer.Simple(1, function()
		ply:SelectWeapon("tttvr_holstered")
	end)
end)

-- when someone exits VR, go through all of their weapons and convert any VR to normal variants
hook.Add("VRUtilExit", "Benny:TTTVR:endweaponreplacerhook", function(ply)
	for k, wep in pairs(ply:GetWeapons()) do
		convertTTTVRWeaponToNormal(wep)
	end
end)

-- make sure player always spawns in holstered
hook.Add("PlayerSpawn", "Benny:TTTVR:playerspawnoffsetfix", function(ply)
	if(IsValid(ply) and istable(vrmod)) then
		if(vrmod.IsPlayerInVR(ply)) then
			timer.Simple(0.1, function()
				ply:SelectWeapon("tttvr_holstered")
			end)
		end
	end
end)