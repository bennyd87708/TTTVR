---- Weapon menu UI: allows VR players to select weapons and tools from slots 7, 8, and 9 by replacing the default weapon menu

-- code stolen from VRMod's vrmod_ui_weaponselect and combined with TTT's cl_wepswitch

-- keep track of when a new item in the menu is selected
local prevSelected = -2
local Selected = -1

-- define the dimensions and colors for the menu bars
local margin = 10
local width = 300
local height = 20

local col_active = {
	tip = {
		[ROLE_INNOCENT]  = Color(55, 170, 50, 255),
		[ROLE_TRAITOR]	= Color(180, 50, 40, 255),
		[ROLE_DETECTIVE] = Color(50, 60, 180, 255)
	},

	bg = Color(20, 20, 20, 250),

	text_empty = Color(200, 20, 20, 255),
	text = Color(255, 255, 255, 255),

	shadow = 255
};

local col_dark = {
	tip = {
		[ROLE_INNOCENT]  = Color(60, 160, 50, 155),
		[ROLE_TRAITOR]	= Color(160, 50, 60, 155),
		[ROLE_DETECTIVE] = Color(50, 60, 160, 155),
	},

	bg = Color(20, 20, 20, 200),

	text_empty = Color(200, 20, 20, 100),
	text = Color(255, 255, 255, 100),

	shadow = 100
};

-- function that actually draws the ui, adaptation of WSWITCH:Draw() from cl_wepswitch
local function DrawTTTVRWeaponMenu()

	local weps = WSWITCH.WeaponCache
	local x = 4
	local y = 14
	local col = col_dark
	
	for k, wep in pairs(weps) do
		if Selected == k then
			col = col_active
		else
			col = col_dark
		end
		
		WSWITCH:DrawBarBg(x, y, width, height, col)
		if not WSWITCH:DrawWeapon(x, y, col, wep) then
		
			WSWITCH:UpdateWeaponCache()
			return
		end
		
		y = y + height + margin
	end
end

-- function opens the weapon menu at a particular position and angle
local open = false
local redraw = false
function TTTVRWeaponMenuOpen(pos, ang)
	
	-- keep track of whether the menu is open or closed
	if open then return end
	open = true
	
	-- keep track of changes in the weapons the player has
	WSWITCH:UpdateWeaponCache()
	local lastCache = WSWITCH.WeaponCache
	
	-- create the menu using the VRMod API; must use a different UID for each size or the menu will stretch for no reason
	vrmod.MenuCreate("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache), width+9, (height+margin)*#WSWITCH.WeaponCache, nil, 4, pos, ang, 0.03, true, function()
		-- when the menu is to be closed, stop rendering, set open to false, and switch weapons if it isn't just redrawing
		hook.Remove("PreRender","Benny:TTTVR:renderweaponselect")
		open = false
		if(redraw) then
			redraw = false
		else
			if WSWITCH.WeaponCache[Selected] then
				input.SelectWeapon(WSWITCH.WeaponCache[Selected])
			end
			prevSelected = -2
		end
	end)
	
	-- once the menu is created, start manually rendering by running everything in this hook every frame
	hook.Add("PreRender","Benny:TTTVR:renderweaponselect",function()
	
		-- maybe don't need to update the cache every frame but it's very lightweight
		WSWITCH:UpdateWeaponCache()
		
		-- if the number of weapons changes while the menu is open, close the current one and open a new one
		if(#lastCache != #WSWITCH.WeaponCache) then
			if vrmod.MenuExists("Benny:TTTVR:weaponmenu"..tostring(#lastCache)) then
				redraw = true
				vrmod.MenuClose("Benny:TTTVR:weaponmenu"..tostring(#lastCache))
			end
			TTTVRWeaponMenuOpen(pos, ang)			
			return
		end
		
		-- use the cursor position on the menu to figure out which item is selected
		if vrmod.MenuFocused() == ("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache)) then
			local menuCursorX, menuCursorY = vrmod.MenuCursorPos()
			hoveredSlotPos = math.floor(menuCursorY/(height+margin)) + 1
			if(WSWITCH.WeaponCache[hoveredSlotPos]) then
				Selected = hoveredSlotPos
			else
				Selected = -1
			end
		else
			Selected = -1
		end
		
		-- if the UI is still the same as it was last frame, return so as to not draw anything
		if(prevSelected == Selected && WSWITCH.WeaponCache == lastCache) then
			return
		else
			prevSelected = Selected
			lastCache = WSWITCH.WeaponCache
		end
		
		-- render the UI manually using the draw method and VRMod API functions
		vrmod.MenuRenderStart("Benny:TTTVR:weaponmenu"..tostring(#WSWITCH.WeaponCache))
		DrawTTTVRWeaponMenu()
		vrmod.MenuRenderEnd()
	end)
end