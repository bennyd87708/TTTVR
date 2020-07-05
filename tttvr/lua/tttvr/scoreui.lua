---- Score UI: shows the player the winning team and round highlights once the round ends or when they press the chat button while there is no active round

-- This one is pretty easy because we can just use the existing panel and don't have to change much

-- function that opens the UI by making slight changes and then drawing with VRMod
function TTTVRScoreUIOpen()
	if(not IsValid(CLSCORE.Panel)) then return end
	CLSCORE.Panel:SetPos(0,0)
	CLSCORE.Panel:SetDraggable(false)
	CLSCORE.Panel:SetVisible(true)
	vrmod.MenuCreate("Benny:TTTVR:scoreui", 700, 500, CLSCORE.Panel, 1, Vector(10,6,13), Angle(0,-90,50), 0.03, true, function()
		CLSCORE.Panel:SetVisible(false)
	end)
end

-- uses built-in TTT hook to automatically draw score ui for vr users at the end of a TTT round
hook.Add("TTTEndRound","Benny:TTTVR:scoreuiopenhook", function(result)
	local ply = LocalPlayer()
	-- check that player is real and in VR
	if(IsValid(ply) and CLIENT and istable(vrmod)) then
		if(vrmod.IsPlayerInVR(ply)) then
		
			-- close the buy menu if it's open to make room for the score panel
			if vrmod.MenuExists("Benny:TTTVR:buymenuui") and IsValid(TTTVReqframe) then
				vrmod.MenuClose("Benny:TTTVR:buymenuui")
			end
			
			-- wait one second because the panel isn't drawn right when the round ends
			timer.Simple(0, function()
				TTTVRScoreUIOpen()
			end)
		end
	end
end)

-- uses built-in TTT hook to automatically close score ui for vr users at the start of a new TTT preparing phase
hook.Add("TTTPrepareRound","Benny:TTTVR:scoreuiclosehook", function()
	local ply = LocalPlayer()
	
	-- check that player is real and in VR
	if(IsValid(ply) and CLIENT and istable(vrmod)) then
		if(vrmod.IsPlayerInVR(ply) and vrmod.MenuExists("Benny:TTTVR:scoreui")) then
			vrmod.MenuClose("Benny:TTTVR:scoreui")
		end
	end
end)