---- Role UI: shows VR player their role (traitor, detective, or innocent) on their right hand at the start of a round

-- defines the font and colors
surface.CreateFont("Benny:TTTVR:traitorstate", {font = "Trebuchet24",size = 130,weight = 1000})
local bg_colors = {
   traitor = Color(200, 25, 25, 200),
   innocent = Color(25, 200, 25, 200),
   detective = Color(25, 25, 200, 200)
};

-- uses built-in TTT hook to draw role ui for vr users at the start of a TTT round
hook.Add("TTTBeginRound","Benny:TTTVR:roleuihook", function()
	local ply = LocalPlayer()
	-- check that player is real and in VR
	if(IsValid(ply) && CLIENT && istable(vrmod)) then
		if(vrmod.IsPlayerInVR(ply)) then
		
			-- find player's role and define corresponding background color
			local role = LANG.GetUnsafeLanguageTable()[ply:GetRoleStringRaw()]
			local col = bg_colors.innocent
			if ply:GetTraitor() then
				col = bg_colors.traitor
			elseif ply:GetDetective() then
				col = bg_colors.detective
			end
			
			-- define the panel that will show
			local roleui = nil
			roleui = vgui.Create("DPanel")
			roleui:SetPos(0,0)
			roleui:SetSize(600,200)
			
			-- paint a rounded box and shadowed text for what role the player has in the panel
			function roleui:Paint(w,h)
				draw.RoundedBox(64,0,0,w,h,col)
				draw.SimpleText(role, "Benny:TTTVR:traitorstate", 305, 35, COLOR_BLACK, TEXT_ALIGN_CENTER)
				draw.SimpleText(role, "Benny:TTTVR:traitorstate", 300, 30, COLOR_WHITE, TEXT_ALIGN_CENTER)
			end
			
			-- draw the menu on the player's right hand using VRMod API
			if vrmod.MenuExists("Benny:TTTVR:roleuimenu") then
				vrmod.MenuClose("Benny:TTTVR:roleuimenu")
			end
			vrmod.MenuCreate("Benny:TTTVR:roleuimenu", 600, 200, roleui, 2, Vector(10,6,13), Angle(0,-90,50), 0.03, false, function()
				roleui:SetVisible(false)
				roleui:Remove()
				roleui = nil
			end)
			
			-- close the ui after 5 seconds using VRMod API
			timer.Simple(5, function()
				if(vrmod.MenuExists("Benny:TTTVR:roleuimenu")) then
					vrmod.MenuClose("Benny:TTTVR:roleuimenu")
				end
			end)
		end
	end
end)