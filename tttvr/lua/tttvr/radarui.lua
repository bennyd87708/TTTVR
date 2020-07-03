---- Radar UI: Draws player, bomb, dna, and detective radar blips for VR players using VRMod API

-- icon textures
local indicator 	= surface.GetTextureID("effects/select_ring")
local c4warn		= surface.GetTextureID("vgui/ttt/icon_c4warn")
local sample_scan	= surface.GetTextureID("vgui/ttt/sample_scan")
local det_beacon	= surface.GetTextureID("vgui/ttt/det_beacon")
local tbut_normal	= surface.GetTextureID("vgui/ttt/tbut_hand_line")
local tbut_focus	= surface.GetTextureID("vgui/ttt/tbut_hand_filled")

-- keep track of how many blips there are for assigning UIDs
local targets = {}
local count = 0

-- arbitrary scale values for the different menus
local defaultScale = 0.00118
local handScale = 0.0015

-- make sure we get some translation stuff for the text
local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

-- define font used for some text
surface.CreateFont("BiggerHST", {font = "HudSelectionText", size = 24})

-- function to see if player is looking near something using dot product - currently for traitor traps
function TTTVRLookingNear(pos)
	local hmdpos, hmdang = vrmod.GetHMDPose(LocalPlayer())
	local vec1 = hmdang:Forward()
	local vec2 = (pos - hmdpos):GetNormalized()
	local theta = math.deg(math.acos(vec1:Dot(vec2)))
	return theta
end

-- DrawHand stolen from cl_tbuttons and modified for VR
local function DrawHand(but, size, offset, texture, drawcolor, textcolor, dis)
	local d = dis:Dot(dis) / (but:GetUsableRange() ^ 2)
	if but:IsUsable() and d < 1 then		
		surface.SetTexture(tbut_normal)
		surface.SetDrawColor(255, 255, 255, 200 * (1 - d))
		surface.DrawTexturedRect(-16, -16, 32, 32)
		if d > 0 and (but == TBHUD.focus_ent) then
			
			-- draw extra graphics and information for button when it's in-focus
			-- redraw in-focus version of icon
			surface.SetTexture(tbut_focus)
			surface.SetDrawColor(255, 255, 255, 200)
			surface.DrawTexturedRect(-16, -16, 32, 32)

			-- description
			surface.SetTextColor(255, 50, 50, 255)
			surface.SetFont("TabLarge")

			local x = 26
			local y = -19
			surface.SetTextPos(x, y)
			surface.DrawText(but:GetDescription())

			y = y + 12
			surface.SetTextPos(x, y)
			if but:GetDelay() < 0 then
				surface.DrawText(GetTranslation("tbut_single"))
			elseif but:GetDelay() == 0 then
				surface.DrawText(GetTranslation("tbut_reuse"))
			else
				surface.DrawText(GetPTranslation("tbut_retime", {num = but:GetDelay()}))
			end

			y = y + 12
			surface.SetTextPos(x, y)
			surface.DrawText("Left grip to activate")
		end
	end
end	

-- DrawTarget stolen from cl_radar and modified for VR
local function DrawTarget(tgt, size, offset, texture, drawcolor, textcolor, dis)
	
	-- if it is drawing a player radar blip, adjust the transparency depending on how long it has been since the radar updated
	-- stolen from cl_radar and edited for more reasonable alpha values for VR screens
	-- original also changes the transparency depending on whether the player is looking at the blip but I don't think it's necessary
	if(texture == indicator) then
		local remaining = math.max(0, RADAR.endtime - CurTime())
		local alpha = 100 + 155 * (remaining / RADAR.duration)
		drawcolor.a = alpha
		textcolor.a = alpha
		
	-- reduce size of the icon for the c4 icon so that there is more room for the text
	elseif(texture == c4warn) then
		size = 32
	end
	
	surface.SetFont("BiggerHST")
	surface.SetTexture(texture)
	surface.SetDrawColor(drawcolor)
	surface.SetTextColor(textcolor)
	surface.DrawTexturedRect(-size, -size, size*2, size*2)
	
	local text = math.ceil(LocalPlayer():GetPos():Distance(tgt.pos))
	local w, h = surface.GetTextSize(text)
	
	-- Show range to target
	surface.SetTextPos(-w/2, (offset * size) - h/2)
	surface.DrawText(text)

	if tgt.t then
		-- Show time
		text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
		w, h = surface.GetTextSize(text)

		surface.SetTextPos(-w/2, size/2)
		surface.DrawText(text)
	elseif tgt.nick then
		-- Show nickname
		text = tgt.nick
		w, h = surface.GetTextSize(text)

		surface.SetTextPos(-w/2, size/2)
		surface.DrawText(text)
	end
end

-- function to close any given blip if it exists
function CloseTTTVRTarget(id)
	if not id then return end
	if vrmod.MenuExists("Benny:TTTVR:quadrant1"..id) then vrmod.MenuClose("Benny:TTTVR:quadrant1"..id) end
	if vrmod.MenuExists("Benny:TTTVR:quadrant2"..id) then vrmod.MenuClose("Benny:TTTVR:quadrant2"..id) end
	if vrmod.MenuExists("Benny:TTTVR:quadrant3"..id) then vrmod.MenuClose("Benny:TTTVR:quadrant3"..id) end
	if vrmod.MenuExists("Benny:TTTVR:quadrant4"..id) then vrmod.MenuClose("Benny:TTTVR:quadrant4"..id) end
	hook.Remove("PreRender", "Benny:TTTVR:quadmenuprerender"..id)
	for k, v in pairs(targets) do
		if(v == id) then
			targets[k] = nil
			return
		end
	end
end

-- needed a function to check if the target of the blip still exists because the updating is done within a prerender
-- might be better for performance to allow the menus to open and close every frame as needed than to use this check
local function targetExists(tgt)
	for k, tgt2 in pairs(RADAR.targets) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
	for k, tgt2 in pairs(RADAR.bombs) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
	for k, tgt2 in pairs(RADAR.called_corpses) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
	for k, tgt2 in pairs(RADAR.samples) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
	for k, tgt2 in pairs(TBHUD.buttons) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
	return false
end

-- big scary function draws a centered VR blip for a given target
function DrawTTTVRTarget(tgt, size, offset, texture, textcolor, drawcolor, scl, drawFunc)
	
	-- stop if a menu already exists for this target
	if targets[tostring(tgt)] ~= nil then return end
	
	-- keep count of how many menus exist to give each one a UID
	local id = count
	targets[tostring(tgt)] = id
	count = count + 1
	
	-- define matrix for later rotating the draw function on each quadrant
	local mat = Matrix()
	
	-- create the four separate VRMod menus relative to the world for depth perception purposes
	for i=1,4 do
		vrmod.MenuCreate("Benny:TTTVR:quadrant"..i..id, size, size, nil, 0, tgt.pos, Angle(0,0,0), 1, false, nil)
	end
	
	-- add hook to adjust and draw the menu each frame
	hook.Add("PreRender", "Benny:TTTVR:quadmenuprerender"..id, function()
	
		-- check that the target still exists so that it closes the menu as soon as the target is gone
		if(not targetExists(tgt)) then
			CloseTTTVRTarget(id)
			return
		end
	
		-- math to update the yaw and pitch for the menu to face towards the headset at all times
		local player_pos = vrmod.GetHMDPos(ply)
		local dis = player_pos - tgt.pos
		local pitch = math.deg(math.atan2(-dis.z, dis:Length2D()))
		local yaw = math.deg(math.atan2(-dis.x, dis.y))
		
		-- math to scale the menu so that it is roughly the usual size
		local scale = math.Clamp(dis:Length() * scl, 0.125, math.huge)
		
		-- use the yaw and pitch to directly edit the angle of each quadrant so they always face the headset
		-- this and the math above were just excruciating trial and error so I don't really know how it all works
		-- using g_VR global directly is bad practice but there isn't an API function for rotating a menu yet so this is the only way
		g_VR.menus["Benny:TTTVR:quadrant1"..id].ang = Angle(pitch - 90, yaw + 90, 180)
		g_VR.menus["Benny:TTTVR:quadrant2"..id].ang = Angle(0, yaw, -pitch - 90)
		g_VR.menus["Benny:TTTVR:quadrant3"..id].ang = Angle(pitch + 90, yaw + 90, 0)
		g_VR.menus["Benny:TTTVR:quadrant4"..id].ang = Angle(180, yaw, pitch - 90)
		
		-- update each quadrant's scale and perform rotation before drawing so that the four quadrants connect
		for i=1,4 do
			-- using g_VR global directly is bad practice but there isn't an API function for scaling a menu yet so this is the only way
			g_VR.menus["Benny:TTTVR:quadrant"..i..id].scale = scale
			mat:Rotate(Angle(0,90,0))
			vrmod.MenuRenderStart("Benny:TTTVR:quadrant"..i..id)
			cam.PushModelMatrix(mat)
			
			-- paint the whole quadrant transparent so that VRMod doesn't try to do any stupid scaling
			surface.SetDrawColor(0, 0, 0, 0)
			surface.DrawRect(-size, -size, size*2, size*2)
			
			-- finally draw on the quadrant
			-- draw must be centered at 0,0 so that it paints all four quadrants
			-- the quadrants are like in math: 1 is +,+ ; 2 is -,+ ; 3 is -,- ; 4 is +,-
			drawFunc(tgt, size, offset, texture, drawcolor, textcolor, dis)
			
			cam.PopModelMatrix()
			vrmod.MenuRenderEnd()
		end
	end)
end

-- RADAR:Draw stolen from cl_radar and modified for VR equivalent functions
-- all blips scaled up to their full sprite resolution instead of tiny default
local function TTTVRRadarDraw(ply)
	if(GetRoundState() ~= ROUND_ACTIVE) then return end
	local focused = nil
	
	-- Check traitor trap hand indicators to figure out if the player is looking at any and to draw the closest one as focused
	if (TBHUD.buttons_count ~= 0) and ply:IsActiveTraitor() then
		local buttons = {}
		local mintheta = 20
		for k, but in pairs(TBHUD.buttons) do
			if IsValid(but) and but.IsUsable then
				local theta = TTTVRLookingNear(but:GetPos())
				if theta < mintheta then
					mintheta = theta
					focused = but
				end
			end
		end
		TBHUD.focus_ent = focused
		if focused then
			TBHUD.focus_stick = CurTime() + 0.1
		end
		
		-- yes it takes two loops per frame - fight me it's better than closing and reopening the menus every frame, trust me
		for k, but in pairs(TBHUD.buttons) do
			but.pos = but:GetPos()
			DrawTTTVRTarget(but, 256, 0, tbut_normal, nil, nil, handScale, DrawHand)
		end
	end
	
	-- C4 warnings
	if RADAR.bombs_count ~= 0 and ply:IsActiveTraitor() then
		for k, bomb in pairs(RADAR.bombs) do
			DrawTTTVRTarget(bomb, 64, 0, c4warn, Color(200, 55, 55, 255), Color(255, 255, 255, 255), defaultScale, DrawTarget)
		end
	end

	-- Corpse calls
	if ply:IsActiveDetective() and #RADAR.called_corpses then
		for k, corpse in pairs(RADAR.called_corpses) do
			DrawTTTVRTarget(corpse, 32, 0.5, det_beacon, Color(255, 255, 255, 240), Color(255, 255, 255, 230), defaultScale, DrawTarget)
		end
	end

	-- Samples
	if RADAR.samples_count ~= 0 then
		for k, sample in pairs(RADAR.samples) do
			DrawTTTVRTarget(sample, 32, 0.5, sample_scan, Color(200, 50, 50, 255), Color(255, 255, 255, 240), defaultScale, DrawTarget)
		end
	end

	-- Player radar
	if (not RADAR.enable) or (not ply:IsActiveSpecial()) then return end

	for k, tgt in pairs(RADAR.targets) do
		role = tgt.role or ROLE_INNOCENT
		if role == ROLE_TRAITOR then
			DrawTTTVRTarget(tgt, 32, 0, indicator, Color(255, 0, 0, 255), Color(255, 0, 0, 255), defaultScale, DrawTarget)
		elseif role == ROLE_DETECTIVE then
			DrawTTTVRTarget(tgt, 32, 0, indicator, Color(0, 0, 255, 255), Color(0, 0, 255, 255), defaultScale, DrawTarget)
		elseif role == 3 then -- decoys
			DrawTTTVRTarget(tgt, 32, 0, indicator, Color(150, 150, 150, 255), Color(150, 150, 150, 255), defaultScale, DrawTarget)
		else
			DrawTTTVRTarget(tgt, 32, 0, indicator, Color(0, 255, 0, 255), Color(0, 255, 0, 255), defaultScale, DrawTarget)
		end
	end
	
	--[[ usually draws the countdown timer until next scan in bottom left - might include in the future on arm ui
	surface.SetFont("TabLarge")
	surface.SetTextColor(255, 0, 0, 230)

	local text = GetPTranslation("radar_hud", {time = FormatTime(remaining, "%02i:%02i")})
	local w, h = surface.GetTextSize(text)

	surface.SetTextPos(36, ScrH() - 140 - h)
	surface.DrawText(text)
	--]]
end

-- closes all the menus - for when the player leaves VR or a round ends
function CloseAllTTTVRTargets()
	for k, v in pairs(targets) do
		CloseTTTVRTarget(v)
	end
	targets = {}
end

-- hook to start drawing the VR radar every frame when the player gets in VR
hook.Add("VRUtilStart", "Benny:TTTVR:radarstarthook", function(ply)
	-- draw the VR radar every frame
	hook.Add("PreRender", "Benny:TTTVR:radarrenderhook", function()
		TTTVRRadarDraw(ply)
	end)
	
	-- close all the VR blips when a round ends
	hook.Add("TTTEndRound", "Benny:TTTVR:radarcleanup", function()
		CloseAllTTTVRTargets()
	end)
end)

-- hook to do the opposite of the one above so it stops when the player leaves VR
hook.Add("VRUtilExit","Benny:TTTVR:radarendhook", function(ply)
	hook.Remove("PreRender", "Benny:TTTVR:radarrenderhook")
	hook.Remove("TTTEndRound", "Benny:TTTVR:radarcleanup")
	CloseAllTTTVRTargets()
end)