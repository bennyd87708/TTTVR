---- Rebindings: prevent the default action for VRMod controls and add our own

-- hook to prevent the default binds for chat and weapon change from working
hook.Add("VRUtilAllowDefaultAction","Benny:TTTVR:buymenuuiblockhook", function(ActionName)
	
	-- if the weapon can secondary attack then prevent the flashlight
	if(ActionName == "boolean_flashlight") then
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) then
			if((wep:GetClass() == "tttvr_magnetostick") or (wep:GetClass() == "tttvr_crowbar") or (wep:Clip2() > 0)) then
				return false
			end
		end
		return true
	end
	
	-- otherwise just prevent all the other default binds
	return not(	ActionName == "boolean_chat" or
				ActionName == "boolean_changeweapon" or
				ActionName == "boolean_use" or
				ActionName == "boolean_left_pickup" or
				ActionName == "boolean_secondaryfire" or
				ActionName == "boolean_primaryfire")
end)

-- hook for when an input is made to know when to do things
hook.Add("VRUtilEventInput","Benny:TTTVR:bindhook", function(ActionName, State)
	local ply = LocalPlayer()
	
	-- toggle the custom VR weapon selection menu when the weapon menu button is pressed
	if ActionName == "boolean_changeweapon" then
		if(State) then
			
			-- calculate where to place the UI based on hand position
			-- todo: change angle so it is based on hand angle and pointer starts at the top of the list
			local tmp = Angle(0,vrmod.GetHMDAng(ply).yaw-90, 45)
			local position, angle = WorldToLocal(vrmod.GetRightHandPos(ply) + tmp:Forward()*-9 + tmp:Right()*-11 + tmp:Up()*-7, tmp, vrmod.GetOriginPos(), vrmod.GetOriginAng())
			
			-- open the menu at the given position and angle
			TTTVRWeaponMenuOpen(position, angle)
		else
		
			-- when the button is let go, close the menu 
			if vrmod.MenuExists("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache)) then
				vrmod.MenuClose("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache))
			end
		end
		return
	end
	
	-- secondary fire when there is a secondary fire available on the weapon
	if ActionName == "boolean_flashlight" then
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end
		if((wep:GetClass() == "tttvr_magnetostick") or (wep:GetClass() == "tttvr_crowbar") or ((wep:Clip2() ~= -1) and (wep:GetClass() ~= "tttvr_rifle"))) then
			ply:ConCommand(State and "+attack2" or "-attack2")
		end
		return
	end
	
	-- toggle the VR buy menu when the chat button is pressed
	if ActionName == "boolean_chat" then
		if not State then return end
		
		-- check if the person is a traitor/detective and that the round is active
		local r = GetRoundState()
		if r == ROUND_ACTIVE and not (ply:GetTraitor() or ply:GetDetective()) then
			return
		elseif r == ROUND_POST or r == ROUND_PREP then
		
			-- toggle round ending UI if button is pressed while there is no active round
			if vrmod.MenuExists("Benny:TTTVR:scoreui") then
				vrmod.MenuClose("Benny:TTTVR:scoreui")
			else
				TTTVRScoreUIOpen()
			end
			return
		else
		
			-- toggle buy menu UI if button is pressed while there is an active round and the player is a detective or traitor
			if vrmod.MenuExists("Benny:TTTVR:buymenuui") then
				vrmod.MenuClose("Benny:TTTVR:buymenuui")
			else
				TTTVRBuyMenuOpen()
			end
			return
		end
	end
	
	-- bind drop weapon to the default secondary fire button
	if ActionName == "boolean_secondaryfire" then
		ply:ConCommand(State and "+menu" or "-menu")
		return
	end
	
	-- bind voice chat to the default left pickup button
	if ActionName == "boolean_left_pickup" then
		ply:ConCommand(State and "+voicerecord" or "-voicerecord")
		return
	end
	
	-- bind hold to pickup with magneto stick to primary fire
	if ActionName == "boolean_primaryfire" then
		if g_VR.menuFocus then return end
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			if wep:GetClass() == "tttvr_magnetostick" and State then
				ply:ConCommand("+attack")
				timer.Simple(0, function()
					ply:ConCommand("-attack")
				end)
				return
			end
		end
		
		ply:ConCommand(State and "+attack" or "-attack")
		return
	end
	
	--[[ bind traitor voice chat to when left trigger clicks all the way - not a feature yet
	if (ActionName == "boolean_left_pickup" and ) then
		ply:ConCommand(State and "+speed" or "-speed")
		return
	end
	--]]
	
	-- add some other code to the default use button
	if ActionName == "boolean_use" then
		if TBHUD:PlayerIsFocused() then
			TBHUD:UseFocused()
		else
			ply:ConCommand(State and "+use" or "-use")
		end
		return
	end
end)