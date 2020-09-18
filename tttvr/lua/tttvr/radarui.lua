---- Radar UI: Draws player, bomb, dna, and detective radar blips for VR players using VRMod API

-- icon textures
local indicator 	= surface.GetTextureID("effects/select_ring")
local c4warn		= surface.GetTextureID("vgui/ttt/icon_c4warn")
local sample_scan	= surface.GetTextureID("vgui/ttt/sample_scan")
local det_beacon	= surface.GetTextureID("vgui/ttt/det_beacon")
local tbut_normal	= surface.GetTextureID("vgui/ttt/tbut_hand_line")
local tbut_focus	= surface.GetTextureID("vgui/ttt/tbut_hand_filled")
local ring_tex		= surface.GetTextureID("effects/select_ring")
local magnifier_mat = Material("icon16/magnifier.png")

-- keep track of how many blips there are for assigning UIDs
local targets = {}
local count = 0

-- arbitrary scale values for the different menus
local defaultScale = 0.00118
local handScale = 0.0015
local tidScale = 0.001

-- variables needed for tracking where the player is looking and how far away they are
local MAX_TRACE_LENGTH = math.sqrt(3) * 2 * 16384
local mindistance = 84
local minsquared = mindistance*mindistance
local minfrac = mindistance/MAX_TRACE_LENGTH

-- keep track of focused target so we can close the menu when there is none and +use the right target in actions.lua
TTTVR_focused_target = nil

-- make sure we get some translation stuff for the text
local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation
local GetLang = LANG.GetUnsafeLanguageTable
local GetRaw = LANG.GetRawTranslation

-- default classhint stuff for body search UI, edited later
local key_params = {usekey = Key("+use", "USE"), walkkey = Key("+walk", "WALK")}
local ClassHint = {
	prop_ragdoll = {
		name= "corpse",
		hint= "corpse_hint",
		fmt = function(ent, txt) return GetPTranslation(txt, key_params) end
	}
};

-- define fonts used for some text
surface.CreateFont("BiggerHST", {font = "HudSelectionText", size = 24})
surface.CreateFont("TargetIDSmall2", {font = "TargetID", size = 16, weight = 1000})

-- function to see if player is looking near something using dot product - currently for traitor traps and target ID
function TTTVRLookingNear(pos)
	local hmdpos, hmdang = vrmod.GetHMDPose(LocalPlayer())
	local vec1 = hmdang:Forward()
	local vec2 = (pos - hmdpos):GetNormalized()
	local theta = math.deg(math.acos(vec1:Dot(vec2)))
	return theta
end

-- we have to use this a few times so may as well make it a function
-- finds an entity that the player is looking nearest at from a list of entities
local function getFocusedEntFromTable(tbl, mintheta)
	local focused_ent = nil
	for k, ent in pairs(tbl) do
		local theta = TTTVRLookingNear(ent:WorldSpaceCenter() or ent:GetPos())
		if theta < mintheta then
			mintheta = theta
			focused_ent = ent
		end
	end
	return focused_ent
end

-- function to draw targeted player info stolen from cl_targetid and modified for VR
local function DrawTargetID(ent)
	if (not IsValid(ent)) or ent.NoTarget then return end
	
	local client = LocalPlayer()
	local L = GetLang()
	
	-- some bools for caching what kind of ent we are looking at
	local target_traitor = false
	local target_detective = false
	local target_corpse = false

	local text = nil
	local color = COLOR_WHITE

	-- if a vehicle, we identify the driver instead
	if IsValid(ent:GetNWEntity("ttt_driver", nil)) then
		ent = ent:GetNWEntity("ttt_driver", nil)

		if ent == client then return end
	end

	local cls = ent:GetClass()
	local minimal = GetConVar("ttt_minimal_targetid"):GetBool()
	local hint = (not minimal) and (ent.TargetIDHint or ClassHint[cls])

	if ent:IsPlayer() then
		if ent:GetNWBool("disguised", false) then
			client.last_id = nil

			if client:IsTraitor() or client:IsSpec() then
				text = ent:Nick() .. L.target_disg
			else
				-- Do not show anything
				return
			end

			color = COLOR_RED
		else
			text = ent:Nick()
			client.last_id = ent
		end

		local _ -- Stop global clutter
		-- in minimalist targetID, colour nick with health level
		if minimal then
			_, color = util.HealthToString(ent:Health(), ent:GetMaxHealth())
		end

		if client:IsTraitor() and GetRoundState() == ROUND_ACTIVE then
			target_traitor = ent:IsTraitor()
		end

		target_detective = GetRoundState() > ROUND_PREP and ent:IsDetective() or false

	elseif cls == "prop_ragdoll" then
		-- only show this if the ragdoll has a nick, else it could be a mattress
		if CORPSE.GetPlayerNick(ent, false) == false then return end

		target_corpse = true

		if CORPSE.GetFound(ent, false) or not DetectiveMode() then
			text = CORPSE.GetPlayerNick(ent, "A Terrorist")
		else
			text  = L.target_unid
			color = COLOR_YELLOW
		end
	elseif not hint then
		-- Not something to ID and not something to hint about
		return
	end

	local x = 0
	-- edited y position to center it
	local y = -57

	local w, h = 0,0 -- text width/height, reused several times

	--[[ usually draws blue or red circle around cursor but doesn't look right here so get rid of it
	if target_traitor or target_detective then
		surface.SetTexture(ring_tex)

		if target_traitor then
			surface.SetDrawColor(255, 0, 0, 200)
		else
			surface.SetDrawColor(0, 0, 255, 220)
		end
		surface.DrawTexturedRect(x-32, y-32, 64, 64)
	end
	--]]

	y = y + 30
	local font = "TargetID"
	surface.SetFont( font )

	-- Draw main title, ie. nickname
	if text then
		w, h = surface.GetTextSize( text )

		x = x - w / 2

		draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		draw.SimpleText( text, font, x, y, color )

		-- for ragdolls searched by detectives, add icon
		if ent.search_result and client:IsDetective() then
			-- if I am detective and I know a search result for this corpse, then I
			-- have searched it or another detective has
			surface.SetMaterial(magnifier_mat)
			surface.SetDrawColor(200, 200, 255, 255)
			surface.DrawTexturedRect(x + w + 5, y, 16, 16)
		end

		y = y + h + 4
	end

	-- Minimalist target ID only draws a health-coloured nickname, no hints, no
	-- karma, no tag
	if minimal then return end

	-- Draw subtitle: health or type
	local clr = Color(200,200,200,255)
	if ent:IsPlayer() then
		text, clr = util.HealthToString(ent:Health(), ent:GetMaxHealth())

		-- HealthToString returns a string id, need to look it up
		text = L[text]
	elseif hint then
		text = GetRaw(hint.name) or hint.name
	else
		return
	end
	font = "TargetIDSmall2"

	surface.SetFont( font )
	w, h = surface.GetTextSize( text )
	x = - w / 2

	draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
	draw.SimpleText( text, font, x, y, clr )

	font = "TargetIDSmall"
	surface.SetFont( font )

	-- Draw second subtitle: karma
	if ent:IsPlayer() and KARMA.IsEnabled() then
		text, clr = util.KarmaToString(ent:GetBaseKarma())

		text = L[text]

		w, h = surface.GetTextSize( text )
		y = y + h + 5
		x = - w / 2

		draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		draw.SimpleText( text, font, x, y, clr )
	end

	-- Draw key hint
	if hint and hint.hint then
		if not hint.fmt then
			text = GetRaw(hint.hint) or hint.hint
		else
			text = "Right grip to search."
		end

		w, h = surface.GetTextSize(text)
		x = - w / 2
		y = y + h + 5
		draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		draw.SimpleText( text, font, x, y, COLOR_LGRAY )
	end

	text = nil

	if target_traitor then
		text = L.target_traitor
		clr = COLOR_RED
	elseif target_detective then
		text = L.target_detective
		clr = COLOR_BLUE
	elseif ent.sb_tag and ent.sb_tag.txt != nil then
		text = L[ ent.sb_tag.txt ]
		clr = ent.sb_tag.color
	elseif target_corpse and client:IsActiveTraitor() and CORPSE.GetCredits(ent, 0) > 0 then
		text = L.target_credits
		clr = COLOR_YELLOW
	end

	if text then
		w, h = surface.GetTextSize( text )
		x = - w / 2
		y = y + h + 5

		draw.SimpleText( text, font, x+1, y+1, COLOR_BLACK )
		draw.SimpleText( text, font, x, y, clr )
	end
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
			surface.DrawText("Right grip to activate")
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
-- definitely not better for performance to allow the menus to open and close every frame as needed than to use this check, but can probably find a better way
local function targetExists(tgt)
	if(tgt == TTTVR_focused_target) then return true end
	for k, tgt2 in pairs(TBHUD.buttons) do
		if(tostring(tgt2) == tostring(tgt)) then
			return true
		end
	end
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
		vrmod.MenuCreate("Benny:TTTVR:quadrant"..i..id, size, size, nil, 0, (tgt.pos or tgt:GetPos()), Angle(0,0,0), 1, false, nil)
	end
	
	-- add hook to adjust and draw the menu each frame
	hook.Add("PreRender", "Benny:TTTVR:quadmenuprerender"..id, function()
	
		-- check that the target still exists so that it closes the menu as soon as the target is gone
		if(not targetExists(tgt)) then
			CloseTTTVRTarget(id)
			return
		end
	
		-- math to update the yaw and pitch for the menu to face towards the headset at all times
		local pos
		if tgt.pos then
			pos = tgt.pos
		elseif(IsValid(tgt)) then
			pos = tgt:GetPos()
			if(tgt:IsPlayer()) then
				if(not tgt:Alive()) then
					CloseTTTVRTarget(id)
				end
			end
		else
			CloseTTTVRTarget(id)
			return
		end
			
		local player_pos = vrmod.GetHMDPos(ply)
		local dis = player_pos - pos
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
		
		-- update each quadrant's scale and position and perform rotation before drawing so that the four quadrants connect
		-- the quadrants are like in math: 1 is +,+ ; 2 is -,+ ; 3 is -,- ; 4 is +,-
		for i=1,4 do
			
			-- using g_VR global directly is bad practice but there aren't API functions for editing a menu yet so this is the only way
			g_VR.menus["Benny:TTTVR:quadrant"..i..id].pos = pos
			g_VR.menus["Benny:TTTVR:quadrant"..i..id].scale = scale
			mat:Rotate(Angle(0,90,0))
			vrmod.MenuRenderStart("Benny:TTTVR:quadrant"..i..id)
			cam.PushModelMatrix(mat)
			
			-- paint the whole quadrant transparent so that VRMod doesn't try to do any stupid scaling
			surface.SetDrawColor(0, 0, 0, 0)
			surface.DrawRect(-size, -size, size*2, size*2)
			
			-- finally draw on the quadrant
			-- draw must be centered at 0,0 so that it paints all four quadrants
			drawFunc(tgt, size, offset, texture, drawcolor, textcolor, dis)
			
			cam.PopModelMatrix()
			vrmod.MenuRenderEnd()
		end
	end)
end

-- handles the TargetID HUD element
local function TargetID(ply)
	
	-- variable for the currently focused target is global for other scripts (like actions.lua)
	TTTVR_focused_target = nil
	
	-- first check using a direct line trace coming from the headset because it's easiest
	local hmdpos = vrmod.GetHMDPos(ply)
	local hmdang = vrmod.GetHMDAng(ply):Forward()
	hmdang:Mul(MAX_TRACE_LENGTH)
	hmdang:Add(hmdpos)

	local trace = util.TraceLine({
		start = hmdpos,
		endpos = hmdang,
		mask = MASK_SHOT,
		filter = ply:GetObserverMode() == OBS_MODE_IN_EYE and {ply, ply:GetObserverTarget()} or ply
	})
	
	if trace.Hit and IsValid(trace.Entity) then
		if trace.Entity:IsPlayer() or trace.Entity:IsRagdoll() or (trace.Entity.CanUseKey and trace.Entity.UseOverride and trace.Fraction < minfrac) then
			TTTVR_focused_target = trace.Entity
		end
	end
	
	-- if the player isn't looking directly at any targetable entity, check their peripheral vision because it's hard to look directly at something
	if not IsValid(TTTVR_focused_target) then 
		local tid_ents ={}
		for k, ent in pairs(ents.GetAll()) do
			
			-- only check the entity if it is close enough to the player, within line of sight, and useable
			if ((ent:IsPlayer() or ent:IsRagdoll() or (ent.CanUseKey and ent.UseOverride and (ply:GetPos():DistToSqr(ent:GetPos()) < minsquared))) and ply:IsLineOfSightClear(ent)) then
				table.insert(tid_ents, ent)
			end
		end
		
		-- checks within 7 degrees of FOV
		TTTVR_focused_target = getFocusedEntFromTable(tid_ents, 7)
	end

	-- if they are looking at anything, draw the appropriate menu
	if IsValid(TTTVR_focused_target) then
		TTTVR_focused_target.pos = TTTVR_focused_target:WorldSpaceCenter()
		DrawTTTVRTarget(TTTVR_focused_target, 128, 0, nil, nil, nil, tidScale, DrawTargetID)
	end
end

-- RADAR:Draw stolen from cl_radar and modified for VR equivalent functions
-- all blips scaled up to their full sprite resolution instead of tiny default
local function TTTVRHudDraw(ply)
	
	-- check if the player is targetting anything and draw targetid info
	TargetID(ply)
	
	-- The rest of the hud elements don't need to be drawn unless the round is active
	if(GetRoundState() ~= ROUND_ACTIVE) then return end
	
	-- Check traitor trap hand indicators to figure out if the player is looking at any and to draw the closest one as focused
	local focused_hand = nil
	if (TBHUD.buttons_count ~= 0) and ply:IsActiveTraitor() then
		local buttons = {}
		for k, but in pairs(TBHUD.buttons) do
			if IsValid(but) and but.IsUsable then
				table.insert(buttons, but)
			end
		end
		local focused_hand = getFocusedEntFromTable(buttons, 15)
		TBHUD.focus_ent = focused_hand
		if IsValid(focused_hand) then
			TBHUD.focus_stick = CurTime() + 0.1
		end
		
		-- yes it takes two loops per frame - fight me it's better than closing and reopening the menus every frame, trust me
		for k, but in pairs(TBHUD.buttons) do
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
		TTTVRHudDraw(ply)
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