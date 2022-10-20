---- Actions: function definitions for each custom TTTVR control for use in rebindings.lua
-- all functions are passed ply and State by rebindings.lua

-- primary fire
function TTTVR_PrimaryFire(ply, State)
	if vrmod.MenuFocused() then return end
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
end

-- secondary fire when there is a secondary fire available on the weapon, otherwise toggle flashlight
local flashlight
function TTTVR_SecondaryFire(ply, State)
	
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end
	if((wep:GetClass() == "tttvr_magnetostick") or (wep:GetClass() == "tttvr_crowbar") or ((wep:Clip2() ~= -1) and (wep:GetClass() ~= "tttvr_rifle"))) then
		ply:ConCommand(State and "+attack2" or "-attack2")
	else
		if State then
			surface.PlaySound("items/flashlight1.wav")
			if not IsValid(flashlight) then
				flashlight = ProjectedTexture()
				flashlight:SetTexture( "effects/flashlight001" )
				flashlight:SetFOV(60)
				flashlight:SetFarZ(750)
				hook.Add("PreRender","tttvr_hook_flashlight",function()
					if not g_VR.threePoints then return end
					local pos, ang = vrmod.GetRightHandPose(ply)
					local muzzle
					if IsValid(g_VR.viewModel) then
						muzzle = g_VR.viewModel:GetAttachment(1)
					end
					if muzzle then
						pos = muzzle.Pos
						if not (g_VR.currentvmi and g_VR.currentvmi.wrongMuzzleAng) then
							ang = muzzle.Ang
						end
					end
					flashlight:SetPos(pos + ang:Forward()*10)
					flashlight:SetAngles(ang)
					flashlight:Update()
				end)
			else
				hook.Remove("PreRender","tttvr_hook_flashlight")
				flashlight:Remove()
			end
		end
	end
end

-- search a body, open an object's UI, or +use for other (i.e. open door)
function TTTVR_Use(ply, State)
	if State then
		if TTTVR_focused_target then
			if (TTTVR_focused_target.CanUseKey and TTTVR_focused_target.UseOverride) or TTTVR_focused_target:IsRagdoll() then
				net.Start("TTTVRUseOverride")
					net.WriteEntity(TTTVR_focused_target)
				net.SendToServer()
				return
			end
		elseif TBHUD:PlayerIsFocused() then
			TBHUD:UseFocused()
			return
		else
			ply:ConCommand("+use")
			return
		end
	end
	ply:ConCommand("-use")
end

-- reload
function TTTVR_Reload(ply, State)
	ply:ConCommand(State and "+reload" or "-reload")
end

-- jump
function TTTVR_Jump(ply, State)
	ply:ConCommand(State and "+jump" or "-jump")
end

-- voice chat
function TTTVR_VoiceRecord(ply, State)
	permissions.EnableVoiceChat(State)
end

--[[ bind traitor voice chat to when left trigger clicks all the way - not a feature yet
function TTTVR_TraitorVoiceRecord(ply, State)
	ply:ConCommand(State and "+speed" or "-speed")
end
--]]

-- throw held weapon
function TTTVR_DropWeapon(ply, State)
	ply:ConCommand(State and "+menu" or "-menu")
end

-- open/close buy menu or round info UI
function TTTVR_BuyMenuAndRoundInfo(ply, State)
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

-- open or close the weapon switch UI
function TTTVR_WeaponSwitchMenu(ply, State)
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
end

-- open or close the scoreboard UI
function TTTVR_ScoreboardMenu(ply, State, hand)
	hand = hand or 1
	
	if(State) then
		
		-- open the menu if the button is pressed
		TTTVRScoreboardMenuOpen(hand)
	else
	
		-- when the button is let go, close the menu 
		if vrmod.MenuExists("Benny:TTTVR:scoreboardmenu") then
			vrmod.MenuClose("Benny:TTTVR:scoreboardmenu")
		end
	end
end

-- function that combines buy menu, round info, and scoreboard into one button where one action is to press and another is to hold, useful for controllers with few physical buttons
-- should improve functionality and versatility eventually
function TTTVR_ScoreboardAndBuyMenu(ply, State)	
	if State then
		
		-- open the scoreboard on press
		TTTVR_ScoreboardMenu(ply, true, 1)
		
		-- if the player has the ability to open the buy menu or round info, wait 3 seconds to see if they are still holding the button
		if GetRoundState() == ROUND_ACTIVE and not (ply:GetTraitor() or ply:GetDetective()) then return end
		timer.Create("scoreboardandbuymenutimer", 3, 1, function()
		
			-- if they held for 3 seconds, close the scoreboard and toggle the buy menu or round info
			TTTVR_ScoreboardMenu(ply, false)
			TTTVR_BuyMenuAndRoundInfo(ply, true)
		end)
	else
		
		-- on let go, close the scoreboard and stop the timer checking if they were holding down
		TTTVR_ScoreboardMenu(ply, false)
		if timer.Exists("scoreboardandbuymenutimer") then
			timer.Remove("scoreboardandbuymenutimer")
		end
	end
end