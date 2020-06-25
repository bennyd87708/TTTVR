---- Rebindings: prevent the default action for 

-- hook to prevent the default binds for chat and weapon change from working
hook.Add("VRUtilAllowDefaultAction","Benny:TTTVR:buymenuuiblockhook", function(ActionName)
	if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end
	
	if(ActionName == "boolean_chat" or ActionName == "boolean_changeweapon") then
		return false
	end
end)

-- hook for when an input is made to know when to do things
hook.Add("VRUtilEventInput","Benny:TTTVR:bindhook", function(ActionName, State)
	if(gmod.GetGamemode().Name ~= "Trouble in Terrorist Town") then return end
	local ply = LocalPlayer()
	
	-- toggle the custom VR weapon selection menu when the weapon menu button is pressed
	if(ActionName == "boolean_changeweapon") then
		if(State) then
			
			-- calculate where to place the UI based on hand position
			local tmp = Angle(0,vrmod.GetHMDAng(ply).yaw-90,45) --Forward() = right, Right() = back, Up() = up (relative to panel, panel forward is looking at top of panel from middle of panel, up is normal)
			local position, angle = WorldToLocal(vrmod.GetRightHandPos(ply) + tmp:Forward()*-9 + tmp:Right()*-11 + tmp:Up()*-7, tmp, vrmod.GetOriginPos(), vrmod.GetOriginAng())
			
			-- open the menu at the given position and angle
			TTTVRWeaponMenuOpen(position, angle)
		else
		
			-- when the button is let go, close the menu 
			if vrmod.MenuExists("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache)) then
				vrmod.MenuClose("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache))
			end
		end
		
	-- toggle the VR buy menu when the chat button is pressed
	elseif(ActionName == "boolean_chat" && State) then
	
		-- check if the person is a traitor/detective and that the round is active
		local r = GetRoundState()
		if r == ROUND_ACTIVE and not (ply:GetTraitor() or ply:GetDetective()) then
			return
		elseif r == ROUND_POST or r == ROUND_PREP then
		
			-- toggle round ending UI if button is pressed while there is no active round
			if(vrmod.MenuExists("Benny:TTTVR:scoreui") && IsValid(CLSCORE.Panel)) then
				vrmod.MenuClose("Benny:TTTVR:scoreui")
			else
				TTTVRScoreUIOpen()
			end
			return
		end
		
		-- close VR buymenu if it is open
		if vrmod.MenuExists("Benny:TTTVR:buymenuui") && IsValid(TTTVReqframe) then
			vrmod.MenuClose("Benny:TTTVR:buymenuui")
			
		-- otherwise, open the VR buymenu:
		else
		
			-- draws the UI to TTTVReqframe variable using function from cl_equip
			TTTVRBuyMenuOpen()
			
			-- draws the DFrame using VRMod API on the left hand
			vrmod.MenuCreate("Benny:TTTVR:buymenuui", 570, 412, TTTVReqframe, 1, Vector(10,6,13), Angle(0,-90,50), 0.03, true, function()
				TTTVReqframe:Remove()
			end)
		end
	end
end)