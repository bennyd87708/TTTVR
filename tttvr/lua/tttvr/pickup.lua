---- Pickup: allows picking up weapons with hands rather than walking over them

-- hook detects when a player picks up an item
hook.Add("VRMod_Pickup","Benny:TTTVR:serverpickuphook", function(ply, wep)

	-- check that everything is valid just in case
	if not (IsValid(ply) and IsValid(wep) and ply:Alive()) then return end 
	
	-- check that the entity they picked up is a weapon and that they are currently holstered
	if wep:IsWeapon() and (ply:GetActiveWeapon():GetClass() == "tttvr_holstered") then
		
		-- save what slot the weapon is supposed to be in for later
		local savedslot = wep.Kind
		
		-- drop the weapon they currently have in that slot if there is one
		for k, v in ipairs(ply:GetWeapons()) do
			if(v.Kind == savedslot) then
				ply:DropWeapon(v)
				break
			end
		end
		
		-- forcibly move the weapon entity they picked up into their inventory
		if not ply:PickupWeapon(wep) then return end
		
		-- convert the weapon they picked up into the TTTVR version of it if there is one
		convertWeaponToTTTVR(wep, ply)
		
		-- wait a bit because you can't switch to a weapon that the player has just acquired
		timer.Simple(0.05, function()
		
			-- loop through all of the player's weapons to find the one that has the right slot
			for k, v in ipairs(ply:GetWeapons()) do
				if(v.Kind == savedslot) then
					
					-- switches to the weapon but plays weapon switch animation, will probably change in the future
					ply:SelectWeapon(v:GetClass())
					break
				end
			end
		end)
	end
end)