---- Buymenu UI: allows VR players to buy equipment as detective or traitor (bound to chat button)

-- DFrame definition stolen from cl_equip in the TTT gamemode and slightly edited (look for "EDITED")

local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation

local Equipment = nil
local function ItemIsWeapon(item) return not tonumber(item.id) end
local function CanCarryWeapon(item) return LocalPlayer():CanCarryType(item.kind) end

local color_bad = Color(220, 60, 60, 255)
local color_good = Color(0, 200, 0, 255)

-- Creates tabel of labels showing the status of ordering prerequisites
local function PreqLabels(parent, x, y)
	local tbl = {}

	tbl.credits = vgui.Create("DLabel", parent)
	tbl.credits:SetTooltip(GetTranslation("equip_help_cost"))
	tbl.credits:SetPos(x, y)
	tbl.credits.Check = function(s, sel)
								  local credits = LocalPlayer():GetCredits()
								  return credits > 0, GetPTranslation("equip_cost", {num = credits})
							  end

	tbl.owned = vgui.Create("DLabel", parent)
	tbl.owned:SetTooltip(GetTranslation("equip_help_carry"))
	tbl.owned:CopyPos(tbl.credits)
	tbl.owned:MoveBelow(tbl.credits, y)
	tbl.owned.Check = function(s, sel)
								if ItemIsWeapon(sel) and (not CanCarryWeapon(sel)) then
									return false, GetPTranslation("equip_carry_slot", {slot = sel.slot})
								elseif (not ItemIsWeapon(sel)) and LocalPlayer():HasEquipmentItem(sel.id) then
									return false, GetTranslation("equip_carry_own")
								else
									return true, GetTranslation("equip_carry")
								end
							end

	tbl.bought = vgui.Create("DLabel", parent)
	tbl.bought:SetTooltip(GetTranslation("equip_help_stock"))
	tbl.bought:CopyPos(tbl.owned)
	tbl.bought:MoveBelow(tbl.owned, y)
	tbl.bought.Check = function(s, sel)
								 if sel.limited and LocalPlayer():HasBought(tostring(sel.id)) then
									 return false, GetTranslation("equip_stock_deny")
								 else
									 return true, GetTranslation("equip_stock_ok")
								 end
							 end

	for k, pnl in pairs(tbl) do
		pnl:SetFont("TabLarge")
	end

	return function(selected)
				 local allow = true
				 for k, pnl in pairs(tbl) do
					 local result, text = pnl:Check(selected)
					 pnl:SetTextColor(result and color_good or color_bad)
					 pnl:SetText(text)
					 pnl:SizeToContents()

					 allow = allow and result
				 end
				 return allow
			 end
end

-- quick, very basic override of DPanelSelect
local PANEL = {}
local function DrawSelectedEquipment(pnl)
	surface.SetDrawColor(255, 200, 0, 255)
	surface.DrawOutlinedRect(0, 0, pnl:GetWide(), pnl:GetTall())
end

function PANEL:SelectPanel(pnl)
	self.BaseClass.SelectPanel(self, pnl)
	if pnl then
		pnl.PaintOver = DrawSelectedEquipment
	end
end
vgui.Register("EquipSelect", PANEL, "DPanelSelect")


local SafeTranslate = LANG.TryTranslation

local color_darkened = Color(255,255,255, 80)

local color_slot = {
	[ROLE_TRAITOR]	= Color(180, 50, 40, 255),
	[ROLE_DETECTIVE] = Color(50, 60, 180, 255)
}

local fieldstbl = {"name", "type", "desc"}

TTTVReqframe = nil
function TTTVRBuyMenuOpen()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:IsActiveSpecial() then
		return
	end

	-- Close any existing VRMod buymenu menu (EDITED)
	if (TTTVReqframe and IsValid(TTTVReqframe)) or vrmod.MenuExists("Benny:TTTVR:buymenuui") then
		vrmod.MenuClose("Benny:TTTVR:buymenuui")
	end

	local credits = ply:GetCredits()
	local can_order = credits > 0

	local dframe = vgui.Create("DFrame")
	local w, h = 570, 412
	
	-- Set position to 0,0 for VRMod rather than Centered (EDITED)
	dframe:SetPos(0,0)
	
	dframe:SetSize(w, h)
	dframe:SetTitle(GetTranslation("equip_title"))
	dframe:SetVisible(true)
	dframe:ShowCloseButton(false)
	dframe:SetMouseInputEnabled(true)
	dframe:SetDeleteOnClose(true)
	dframe:SetDraggable(false)

	local m = 5

	local dsheet = vgui.Create("DPropertySheet", dframe)

	-- Add a callback when switching tabs
	local oldfunc = dsheet.SetActiveTab
	dsheet.SetActiveTab = function(self, new)
		if self.m_pActiveTab ~= new and self.OnTabChanged then
			self:OnTabChanged(self.m_pActiveTab, new)
		end
		oldfunc(self, new)
	end

	dsheet:SetPos(0,0)
	dsheet:StretchToParent(m,m + 25,m,m)
	local padding = dsheet:GetPadding()

	local dequip = vgui.Create("DPanel", dsheet)
	dequip:SetPaintBackground(false)
	dequip:StretchToParent(padding,padding,padding,padding)

	-- Determine if we already have equipment
	local owned_ids = {}
	for _, wep in ipairs(ply:GetWeapons()) do
		if IsValid(wep) and wep:IsEquipment() then
			table.insert(owned_ids, wep:GetClass())
		end
	end

	-- Stick to one value for no equipment
	if #owned_ids == 0 then
		owned_ids = nil
	end

	--- Construct icon listing
	local dlist = vgui.Create("EquipSelect", dequip)
	dlist:SetPos(0,0)
	dlist:SetSize(216, h - 75)
	dlist:EnableVerticalScrollbar(true)
	dlist:EnableHorizontal(true)
	dlist:SetPadding(4)


	local items = GetEquipmentForRole(ply:GetRole())

	local to_select = nil
	for k, item in pairs(items) do
		local ic = nil

		-- Create icon panel
		if item.material then
			if item.custom then
				-- Custom marker icon
				ic = vgui.Create("LayeredIcon", dlist)

				local marker = vgui.Create("DImage")
				marker:SetImage("vgui/ttt/custom_marker")
				marker.PerformLayout = function(s)
												  s:AlignBottom(2)
												  s:AlignRight(2)
												  s:SetSize(16, 16)
											  end
				marker:SetTooltip(GetTranslation("equip_custom"))

				ic:AddLayer(marker)

				ic:EnableMousePassthrough(marker)
			elseif not ItemIsWeapon(item) then
				ic = vgui.Create("SimpleIcon", dlist)
			else
				ic = vgui.Create("LayeredIcon", dlist)
			end

			-- Slot marker icon
			if ItemIsWeapon(item) then
				local slot = vgui.Create("SimpleIconLabelled")
				slot:SetIcon("vgui/ttt/slotcap")
				slot:SetIconColor(color_slot[ply:GetRole()] or COLOR_GREY)
				slot:SetIconSize(16)

				slot:SetIconText(item.slot)

				slot:SetIconProperties(COLOR_WHITE,
											  "DefaultBold",
											  {opacity=220, offset=1},
											  {10, 8})

				ic:AddLayer(slot)
				ic:EnableMousePassthrough(slot)
			end

			ic:SetIconSize(64)
			ic:SetIcon(item.material)
		elseif item.model then
			ic = vgui.Create("SpawnIcon", dlist)
			ic:SetModel(item.model)
		else
			ErrorNoHalt("Equipment item does not have model or material specified: " .. tostring(item) .. "\n")
		end

		ic.item = item

		local tip = SafeTranslate(item.name) .. " (" .. SafeTranslate(item.type) .. ")"
		ic:SetTooltip(tip)

		-- If we cannot order this item, darken it
		if ((not can_order) or
			 -- already owned
			 table.HasValue(owned_ids, item.id) or
			 (tonumber(item.id) and ply:HasEquipmentItem(tonumber(item.id))) or
			 -- already carrying a weapon for this slot
			 (ItemIsWeapon(item) and (not CanCarryWeapon(item))) or
			 -- already bought the item before
			 (item.limited and ply:HasBought(tostring(item.id)))) then

			ic:SetIconColor(color_darkened)
		end

		dlist:AddPanel(ic)
	end

	local dlistw = 216

	local bw, bh = 100, 25

	local dih = h - bh - m*5
	local diw = w - dlistw - m*6 - 2
	local dinfobg = vgui.Create("DPanel", dequip)
	dinfobg:SetPaintBackground(false)
	dinfobg:SetSize(diw, dih)
	dinfobg:SetPos(dlistw + m, 0)

	local dinfo = vgui.Create("ColoredBox", dinfobg)
	dinfo:SetColor(Color(90, 90, 95))
	dinfo:SetPos(0,0)
	dinfo:StretchToParent(0, 0, 0, dih - 135)

	local dfields = {}
	for _, k in ipairs(fieldstbl) do
		dfields[k] = vgui.Create("DLabel", dinfo)
		dfields[k]:SetTooltip(GetTranslation("equip_spec_" .. k))
		dfields[k]:SetPos(m*3, m*2)
	end

	dfields.name:SetFont("TabLarge")

	dfields.type:SetFont("DermaDefault")
	dfields.type:MoveBelow(dfields.name)

	dfields.desc:SetFont("DermaDefaultBold")
	dfields.desc:SetContentAlignment(7)
	dfields.desc:MoveBelow(dfields.type, 1)

	local iw, ih = dinfo:GetSize()

	local dhelp = vgui.Create("ColoredBox", dinfobg)
	dhelp:SetColor(Color(90, 90, 95))
	dhelp:SetSize(diw, dih - 205)
	dhelp:MoveBelow(dinfo, m)

	local update_preqs = PreqLabels(dhelp, m*3, m*2)

	dhelp:SizeToContents()

	local dconfirm = vgui.Create("DButton", dinfobg)
	dconfirm:SetPos(0, dih - bh*2)
	dconfirm:SetSize(bw, bh)
	dconfirm:SetDisabled(true)
	dconfirm:SetText(GetTranslation("equip_confirm"))


	dsheet:AddSheet(GetTranslation("equip_tabtitle"), dequip, "icon16/bomb.png", false, false, GetTranslation("equip_tooltip_main"))

	-- Item control
	if ply:HasEquipmentItem(EQUIP_RADAR) then
		local dradar = RADAR.CreateMenu(dsheet, dframe)
		dsheet:AddSheet(GetTranslation("radar_name"), dradar, "icon16/magnifier.png", false, false, GetTranslation("equip_tooltip_radar"))
	end

	if ply:HasEquipmentItem(EQUIP_DISGUISE) then
		local ddisguise = DISGUISE.CreateMenu(dsheet)
		dsheet:AddSheet(GetTranslation("disg_name"), ddisguise, "icon16/user.png", false, false, GetTranslation("equip_tooltip_disguise"))
	end

	-- Weapon/item control
	if IsValid(ply.radio) or ply:HasWeapon("weapon_ttt_radio") then
		local dradio = TRADIO.CreateMenu(dsheet)
		dsheet:AddSheet(GetTranslation("radio_name"), dradio, "icon16/transmit.png", false, false, GetTranslation("equip_tooltip_radio"))
	end

	-- Credit transferring
	if credits > 0 then
		local dtransfer = CreateTransferMenu(dsheet)
		dsheet:AddSheet(GetTranslation("xfer_name"), dtransfer, "icon16/group_gear.png", false, false, GetTranslation("equip_tooltip_xfer"))
	end

	hook.Run("TTTEquipmentTabs", dsheet)


	-- couple panelselect with info
	dlist.OnActivePanelChanged = function(self, _, new)
											  for k,v in pairs(new.item) do
												  if dfields[k] then
													  dfields[k]:SetText(SafeTranslate(v))
													  dfields[k]:SizeToContents()
												  end
											  end

											  -- Trying to force everything to update to
											  -- the right size is a giant pain, so just
											  -- force a good size.
											  dfields.desc:SetTall(70)

											  can_order = update_preqs(new.item)

											  dconfirm:SetDisabled(not can_order)
										  end

	-- select first
	dlist:SelectPanel(to_select or dlist:GetItems()[1])

	-- prep confirm action
	dconfirm.DoClick = function()
								 local pnl = dlist.SelectedPanel
								 if not pnl or not pnl.item then return end
								 local choice = pnl.item
								 RunConsoleCommand("ttt_order_equipment", choice.id)
						 
						 -- Close with VRMod instead of normal (EDITED)
								 vrmod.MenuClose("Benny:TTTVR:buymenuui")
						 
							 end

	-- update some basic info, may have changed in another tab
	-- specifically the number of credits in the preq list
	dsheet.OnTabChanged = function(s, old, new)
									 if not IsValid(new) then return end

									 if new:GetPanel() == dequip then
										 can_order = update_preqs(dlist.SelectedPanel.item)
										 dconfirm:SetDisabled(not can_order)
									 end
								 end

	local dcancel = vgui.Create("DButton", dframe)
	dcancel:SetPos(w - 13 - bw, h - bh - 16)
	dcancel:SetSize(bw, bh)
	dcancel:SetDisabled(false)
	dcancel:SetText(GetTranslation("close"))
	
	-- Close with VRMod instead of normal (EDITED)
	dcancel.DoClick = function() vrmod.MenuClose("Benny:TTTVR:buymenuui") end
	
	--[[ Don't open DFrame on screen (EDITED)
	dframe:MakePopup()
	dframe:SetKeyboardInputEnabled(false)
	--]]
	
	TTTVReqframe = dframe
	
	-- draws the DFrame using VRMod API on the left hand
	timer.Simple(0, function()
		vrmod.MenuCreate("Benny:TTTVR:buymenuui", 570, 412, TTTVReqframe, 1, Vector(10,6,13), Angle(0,-90,50), 0.03, true, function()
			TTTVReqframe:Remove()
		end)
	end)
end
