---- Scoreboard UI: shows the scoreboard when they press the button from rebindings.lua which triggers function in actions.lua
-- This one is pretty easy because we can just use the existing panel and don't have to change much (took a whole lot of trial and error to get right, though)

-- function that opens the UI by drawing the scoreboard panel using functions from cl_scoreboard and then manually painting with VRMod
function TTTVRScoreboardMenuOpen(hand)
	
	-- function from cl_scoreboard creates the sboard_panel and starts updating it
	-- usually called on tab press so it also pops up the panel on screen so not sure if there is an easy way to get rid of that
	GAMEMODE:ScoreboardShow()
	
	-- create a VRMod panel attached to the right hand
	-- the panel isnt positioned at 0,0 so we just make the panel really big, might break on a 4k screen?
	vrmod.MenuCreate("Benny:TTTVR:scoreboardmenu", 1920, 1080, nil, hand, Vector(10,32,13), Angle(0,-90,50), 0.03, false, function()
		
		-- when the menu is closed, hide the scoreboard and stop painting the panel
		GAMEMODE:ScoreboardHide()
		hook.Remove("PreRender", "Benny:TTTVR:scoreboardmenuprerender")
	end)
	
	-- hook every frame manually paints the scoreboard panel to the VRMod menu (stolen from vrmod_ui)
	hook.Add("PreRender", "Benny:TTTVR:scoreboardmenuprerender", function()
		vrmod.MenuRenderStart("Benny:TTTVR:scoreboardmenu")
		cam.Start2D()
		render.ClearDepth()
		render.Clear(0,0,0,0)
		GAMEMODE:GetScoreboardPanel():PaintManual()
		cam.End2D()
		vrmod.MenuRenderEnd()
	end)
end