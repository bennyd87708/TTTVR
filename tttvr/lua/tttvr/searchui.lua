---- Search UI: body search menu above corpse in VR

-- all stolen from cl_search and modified for VR

local T = LANG.GetTranslation
local PT = LANG.GetParamTranslation

local is_dmg = util.BitSet

local dtt = { search_dmg_crush = DMG_CRUSH, search_dmg_bullet = DMG_BULLET, search_dmg_fall = DMG_FALL, 
search_dmg_boom = DMG_BLAST, search_dmg_club = DMG_CLUB, search_dmg_drown = DMG_DROWN, search_dmg_stab = DMG_SLASH, 
search_dmg_burn = DMG_BURN, search_dmg_tele = DMG_SONIC, search_dmg_car = DMG_VEHICLE }

-- "From his body you can tell XXX"
local function DmgToText(d)
	for k, v in pairs(dtt) do
		if is_dmg(d, v) then
		  return T(k)
		end
	end
	if is_dmg(d, DMG_DIRECT) then
		return T("search_dmg_burn")
	end
	return T("search_dmg_other")
end

-- Info type to icon mapping

-- Some icons have different appearances based on the data value. These have a
-- separate table inside the TypeToMat table.

-- Those that have a lot of possible data values are defined separately, either
-- as a function or a table.

local dtm = { bullet = DMG_BULLET, rock = DMG_CRUSH, splode = DMG_BLAST, fall = DMG_FALL, fire = DMG_BURN }

local function DmgToMat(d)
	for k, v in pairs(dtm) do
		if is_dmg(d, v) then
			return k
		end
	end
	if is_dmg(d, DMG_DIRECT) then
		return "fire"
	else
		return "skull"
	end
end

local function WeaponToIcon(d)
	local wep = util.WeaponForClass(d)
	return wep and wep.Icon or "vgui/ttt/icon_nades"
end

local TypeToMat = {
	nick="id",
	words="halp",
	eq_armor="armor",
	eq_radar="radar",
	eq_disg="disguise",
	role={[ROLE_TRAITOR]="traitor", [ROLE_DETECTIVE]="det", [ROLE_INNOCENT]="inno"},
	c4="code",
	dmg=DmgToMat,
	wep=WeaponToIcon,
	head="head",
	dtime="time",
	stime="wtester",
	lastid="lastid",
	kills="list"
}

-- Accessor for better fail handling
local function IconForInfoType(t, data)
	local base = "vgui/ttt/icon_"
	local mat = TypeToMat[t]

	if istable(mat) then
		mat = mat[data]
	elseif isfunction(mat) then
		mat = mat(data)
	end

	if not mat then
		mat = TypeToMat["nick"]
	end

	-- ugly special casing for weapons, because they are more likely to be
	-- customized and hence need more freedom in their icon filename
	if t != "wep" then
		return base .. mat
	else
		return mat
	end
end

-- Returns a function meant to override OnActivePanelChanged, which modifies
-- dactive and dtext based on the search information that is associated with the
-- newly selected panel
local function SearchInfoController(search, dactive, dtext)
	return function(s, pold, pnew)
				 local t = pnew.info_type
				 local data = search[t]
				 if not data then
					 ErrorNoHalt("Search: data not found", t, data,"\n")
					 return
				 end

				 -- If wrapping is on, the Label's SizeToContentsY misbehaves for
				 -- text that does not need wrapping. I long ago stopped wondering
				 -- "why" when it comes to VGUI. Apply hack, move on.
				 dtext:GetLabel():SetWrap(#data.text > 50)

				 dtext:SetText(data.text)
				 dactive:SetImage(data.img)
			 end
end

-- TTTVR version of the showsearchscreen function which opens the menu in VR instead of onscreen
local function TTTVRShowSearchScreen(search_raw, client)
	if not IsValid(client) then return end

	local m = 8
	local bw, bh = 100, 25
	local bw_large = 125
	local w, h = 425, 260

	local rw, rh = (w - m*2), (h - 25 - m*2)
	local rx, ry = 0, 0

	local rows = 1
	local listw, listh = rw, (64 * rows + 6)
	local listx, listy = rx, ry

	ry = ry + listh + m*2
	rx = m

	local descw, desch = rw - m*2, 80
	local descx, descy = rx, ry

	ry = ry + desch + m

	local butx, buty = rx, ry

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:SetPos(0,0)
	dframe:SetTitle(T("search_title") .. " - " .. search_raw.nick or "???")
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetKeyboardInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	dframe.OnKeyCodePressed = util.BasicKeyHandler

	-- contents wrapper
	local dcont = vgui.Create("DPanel", dframe)
	dcont:SetPaintBackground(false)
	dcont:SetSize(rw, rh)
	dcont:SetPos(m, 25 + m)

	-- icon list
	local dlist = vgui.Create("DPanelSelect", dcont)
	dlist:SetPos(listx, listy)
	dlist:SetSize(listw, listh)
	dlist:EnableHorizontal(true)
	dlist:SetSpacing(1)
	dlist:SetPadding(2)

	if dlist.VBar then
		dlist.VBar:Remove()
		dlist.VBar = nil
	end

	-- description area
	local dscroll = vgui.Create("DHorizontalScroller", dlist)
	dscroll:StretchToParent(3,3,3,3)

	local ddesc = vgui.Create("ColoredBox", dcont)
	ddesc:SetColor(Color(50, 50, 50))
	ddesc:SetName(T("search_info"))
	ddesc:SetPos(descx, descy)
	ddesc:SetSize(descw, desch)

	local dactive = vgui.Create("DImage", ddesc)
	dactive:SetImage("vgui/ttt/icon_id")
	dactive:SetPos(m, m)
	dactive:SetSize(64, 64)

	local dtext = vgui.Create("ScrollLabel", ddesc)
	dtext:SetSize(descw - 120, desch - m*2)
	dtext:MoveRightOf(dactive, m*2)
	dtext:AlignTop(m)
	dtext:SetText("...")

	-- buttons
	local by = rh - bh - (m/2)

	local dident = vgui.Create("DButton", dcont)
	dident:SetPos(m, by)
	dident:SetSize(bw_large, bh)
	dident:SetText(T("search_confirm"))
	local id = search_raw.eidx + search_raw.dtime
	dident.DoClick = function() RunConsoleCommand("ttt_confirm_death", search_raw.eidx, id) end
	dident:SetDisabled(client:IsSpec() or (not client:KeyDownLast(IN_WALK)))

	local dcall = vgui.Create("DButton", dcont)
	dcall:SetPos(m*2 + bw_large, by)
	dcall:SetSize(bw_large, bh)
	dcall:SetText(T("search_call"))
	dcall.DoClick = function(s)
							 client.called_corpses = client.called_corpses or {}
							 table.insert(client.called_corpses, search_raw.eidx)
							 s:SetDisabled(true)

							 RunConsoleCommand("ttt_call_detective", search_raw.eidx)
						 end

	dcall:SetDisabled(client:IsSpec() or table.HasValue(client.called_corpses or {}, search_raw.eidx))

	local dconfirm = vgui.Create("DButton", dcont)
	dconfirm:SetPos(rw - m - bw, by)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetText(T("close"))
	dconfirm.DoClick = function() vrmod.MenuClose("Benny:TTTVR:searchui") end


	-- Finalize search data, prune stuff that won't be shown etc
	-- search is a table of tables that have an img and text key
	local search = PreprocSearch(search_raw)

	-- Install info controller that will link up the icons to the text etc
	dlist.OnActivePanelChanged = SearchInfoController(search, dactive, dtext)

	-- Create table of SimpleIcons, each standing for a piece of search
	-- information.
	local start_icon = nil
	for t, info in SortedPairsByMemberValue(search, "p") do
		local ic = nil

		-- Certain items need a special icon conveying additional information
		if t == "nick" then
			local avply = IsValid(search_raw.owner) and search_raw.owner or nil

			ic = vgui.Create("SimpleIconAvatar", dlist)
			ic:SetPlayer(avply)

			start_icon = ic
		elseif t == "lastid" then
			ic = vgui.Create("SimpleIconAvatar", dlist)
			ic:SetPlayer(info.ply)
			ic:SetAvatarSize(24)
		elseif info.text_icon then
			ic = vgui.Create("SimpleIconLabelled", dlist)
			ic:SetIconText(info.text_icon)
		else
			ic = vgui.Create("SimpleIcon", dlist)
		end

		ic:SetIconSize(64)
		ic:SetIcon(info.img)

		ic.info_type = t

		dlist:AddPanel(ic)
		dscroll:AddPanel(ic)
	end

	dlist:SelectPanel(start_icon)

	local tmp = Angle(0,vrmod.GetHMDAng(client).yaw-90, 45)
	local pos, ang = WorldToLocal(vrmod.GetRightHandPos(client) + tmp:Forward()*-9 + tmp:Right()*-11 + tmp:Up()*-7, tmp, vrmod.GetOriginPos(), vrmod.GetOriginAng())
		
	vrmod.MenuCreate("Benny:TTTVR:searchui", w, h, dframe, 4, pos, ang, 0.03, true, function()
		dframe:SetVisible(false)
		dframe:Remove()
		dframe = nil
	end)
end

-- regular showsearchscreenfunction
local function ShowSearchScreen(search_raw, client)
	if not IsValid(client) then return end

	local m = 8
	local bw, bh = 100, 25
	local bw_large = 125
	local w, h = 425, 260

	local rw, rh = (w - m*2), (h - 25 - m*2)
	local rx, ry = 0, 0

	local rows = 1
	local listw, listh = rw, (64 * rows + 6)
	local listx, listy = rx, ry

	ry = ry + listh + m*2
	rx = m

	local descw, desch = rw - m*2, 80
	local descx, descy = rx, ry

	ry = ry + desch + m

	local butx, buty = rx, ry

	local dframe = vgui.Create("DFrame")
	dframe:SetSize(w, h)
	dframe:Center()
	dframe:SetTitle(T("search_title") .. " - " .. search_raw.nick or "???")
	dframe:SetVisible(true)
	dframe:ShowCloseButton(true)
	dframe:SetMouseInputEnabled(true)
	dframe:SetKeyboardInputEnabled(true)
	dframe:SetDeleteOnClose(true)

	dframe.OnKeyCodePressed = util.BasicKeyHandler

	-- contents wrapper
	local dcont = vgui.Create("DPanel", dframe)
	dcont:SetPaintBackground(false)
	dcont:SetSize(rw, rh)
	dcont:SetPos(m, 25 + m)

	-- icon list
	local dlist = vgui.Create("DPanelSelect", dcont)
	dlist:SetPos(listx, listy)
	dlist:SetSize(listw, listh)
	dlist:EnableHorizontal(true)
	dlist:SetSpacing(1)
	dlist:SetPadding(2)

	if dlist.VBar then
		dlist.VBar:Remove()
		dlist.VBar = nil
	end

	-- description area
	local dscroll = vgui.Create("DHorizontalScroller", dlist)
	dscroll:StretchToParent(3,3,3,3)

	local ddesc = vgui.Create("ColoredBox", dcont)
	ddesc:SetColor(Color(50, 50, 50))
	ddesc:SetName(T("search_info"))
	ddesc:SetPos(descx, descy)
	ddesc:SetSize(descw, desch)

	local dactive = vgui.Create("DImage", ddesc)
	dactive:SetImage("vgui/ttt/icon_id")
	dactive:SetPos(m, m)
	dactive:SetSize(64, 64)

	local dtext = vgui.Create("ScrollLabel", ddesc)
	dtext:SetSize(descw - 120, desch - m*2)
	dtext:MoveRightOf(dactive, m*2)
	dtext:AlignTop(m)
	dtext:SetText("...")

	-- buttons
	local by = rh - bh - (m/2)

	local dident = vgui.Create("DButton", dcont)
	dident:SetPos(m, by)
	dident:SetSize(bw_large, bh)
	dident:SetText(T("search_confirm"))
	local id = search_raw.eidx + search_raw.dtime
	dident.DoClick = function() RunConsoleCommand("ttt_confirm_death", search_raw.eidx, id) end
	dident:SetDisabled(client:IsSpec() or (not client:KeyDownLast(IN_WALK)))

	local dcall = vgui.Create("DButton", dcont)
	dcall:SetPos(m*2 + bw_large, by)
	dcall:SetSize(bw_large, bh)
	dcall:SetText(T("search_call"))
	dcall.DoClick = function(s)
							 client.called_corpses = client.called_corpses or {}
							 table.insert(client.called_corpses, search_raw.eidx)
							 s:SetDisabled(true)

							 RunConsoleCommand("ttt_call_detective", search_raw.eidx)
						 end

	dcall:SetDisabled(client:IsSpec() or table.HasValue(client.called_corpses or {}, search_raw.eidx))

	local dconfirm = vgui.Create("DButton", dcont)
	dconfirm:SetPos(rw - m - bw, by)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetText(T("close"))
	dconfirm.DoClick = function() dframe:Close() end


	-- Finalize search data, prune stuff that won't be shown etc
	-- search is a table of tables that have an img and text key
	local search = PreprocSearch(search_raw)

	-- Install info controller that will link up the icons to the text etc
	dlist.OnActivePanelChanged = SearchInfoController(search, dactive, dtext)

	-- Create table of SimpleIcons, each standing for a piece of search
	-- information.
	local start_icon = nil
	for t, info in SortedPairsByMemberValue(search, "p") do
		local ic = nil

		-- Certain items need a special icon conveying additional information
		if t == "nick" then
			local avply = IsValid(search_raw.owner) and search_raw.owner or nil

			ic = vgui.Create("SimpleIconAvatar", dlist)
			ic:SetPlayer(avply)

			start_icon = ic
		elseif t == "lastid" then
			ic = vgui.Create("SimpleIconAvatar", dlist)
			ic:SetPlayer(info.ply)
			ic:SetAvatarSize(24)
		elseif info.text_icon then
			ic = vgui.Create("SimpleIconLabelled", dlist)
			ic:SetIconText(info.text_icon)
		else
			ic = vgui.Create("SimpleIcon", dlist)
		end

		ic:SetIconSize(64)
		ic:SetIcon(info.img)

		ic.info_type = t

		dlist:AddPanel(ic)
		dscroll:AddPanel(ic)
	end

	dlist:SelectPanel(start_icon)

	dframe:MakePopup()
end

local function StoreSearchResult(search)
	if search.owner then
		-- if existing result was not ours, it was detective's, and should not
		-- be overwritten
		local ply = search.owner
		if (not ply.search_result) or ply.search_result.show then

			ply.search_result = search

			-- this is useful for targetid
			local rag = Entity(search.eidx)
			if IsValid(rag) then
				rag.search_result = search
			end
		end
	end
end

local function bitsRequired(num)
	local bits, max = 0, 1
	while max <= num do
		bits = bits + 1
		max = max + max
	end
	return bits
end

local search = {}
local function ReceiveRagdollSearch()
	local ply = LocalPlayer()
	search = {}

	-- Basic info
	search.eidx = net.ReadUInt(16)

	search.owner = Entity(net.ReadUInt(8))
	if not (IsValid(search.owner) and search.owner:IsPlayer() and (not search.owner:IsTerror())) then
		search.owner = nil
	end

	search.nick = net.ReadString()

	-- Equipment
	local eq = net.ReadUInt(16)

	-- All equipment pieces get their own icon
	search.eq_armor = util.BitSet(eq, EQUIP_ARMOR)
	search.eq_radar = util.BitSet(eq, EQUIP_RADAR)
	search.eq_disg = util.BitSet(eq, EQUIP_DISGUISE)

	-- Traitor things
	search.role = net.ReadUInt(2)
	search.c4 = net.ReadInt(bitsRequired(C4_WIRE_COUNT) + 1)

	-- Kill info
	search.dmg = net.ReadUInt(30)
	search.wep = net.ReadString()
	search.head = net.ReadBit() == 1
	search.dtime = net.ReadInt(16)
	search.stime = net.ReadInt(16)

	-- Players killed
	local num_kills = net.ReadUInt(8)
	if num_kills > 0 then
		search.kills = {}
		for i=1,num_kills do
			table.insert(search.kills, net.ReadUInt(8))
		end
	else
		search.kills = nil
	end

	search.lastid = {idx=net.ReadUInt(8)}

	-- should we show a menu for this result?
	search.finder = net.ReadUInt(8)

	search.show = (ply:EntIndex() == search.finder)

	--
	-- last words
	--
	local words = net.ReadString()
	search.words = (words ~= "") and words or nil
	
	hook.Call("TTTBodySearchEquipment", nil, search, eq)

	-- since we are overriding the net TTT_RagdollSearch, we also need to handle the normal body search menu
	-- checks if the player is in VR to show the VR version and otherwise show the normal version
	if search.show then
		if(vrmod.IsPlayerInVR(ply)) then
			TTTVRShowSearchScreen(search, ply)
		else
			ShowSearchScreen(search, ply)
		end
	end

	StoreSearchResult(search)

	search = nil
end

-- overrides default ragdoll search script so we handle that above
-- probably bad practice but I don't think there's any better way
net.Receive("TTT_RagdollSearch", ReceiveRagdollSearch)