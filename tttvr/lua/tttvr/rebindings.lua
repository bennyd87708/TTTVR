---- Rebindings: prevent the default action for VRMod controls and add our own

-- default controls for the vive controllers and also the fallback if we don't have a definition for a controller
local vive_controls = {
	["boolean_primaryfire"] 	= TTTVR_PrimaryFire,
	["boolean_flashlight"] 		= TTTVR_SecondaryFire,
	["boolean_use"]				= TTTVR_Use,
	["boolean_reload"]			= TTTVR_Reload,
	["boolean_jump"]			= TTTVR_Jump,
	["boolean_left_pickup"]		= TTTVR_VoiceRecord,
	["boolean_secondaryfire"]	= TTTVR_DropWeapon,
	["boolean_chat"]			= TTTVR_BuyMenuAndRoundInfo,
	["boolean_changeweapon"]	= TTTVR_WeaponSwitchMenu,
	["boolean_contextmenu"]		= TTTVR_ScoreboardMenu
}

-- default controls for the valve knuckles controllers
local index_controls = {
	["boolean_primaryfire"] 	= TTTVR_PrimaryFire,
	["boolean_flashlight"] 		= TTTVR_SecondaryFire,
	["boolean_use"]				= TTTVR_Use,
	["boolean_chat"]			= TTTVR_Reload,
	["boolean_jump"]			= TTTVR_Jump,
	["boolean_sprint"]			= TTTVR_VoiceRecord,
	["boolean_secondaryfire"]	= TTTVR_DropWeapon,
	["boolean_reload"]			= TTTVR_BuyMenuAndRoundInfo,
	["boolean_changeweapon"]	= TTTVR_WeaponSwitchMenu,
	["boolean_undo"]			= TTTVR_ScoreboardMenu
}

-- default controls for the oculus touch controllers
local oculus_controls = {
	["boolean_primaryfire"] 	= TTTVR_PrimaryFire,
	["boolean_flashlight"] 		= TTTVR_SecondaryFire,
	["boolean_use"]				= TTTVR_Use,
	["boolean_reload"]			= TTTVR_Reload,
	["boolean_jump"]			= TTTVR_Jump,
	["boolean_sprint"]			= TTTVR_VoiceRecord,
	["boolean_secondaryfire"]	= TTTVR_DropWeapon,
	["boolean_chat"]			= TTTVR_BuyMenuAndRoundInfo,
	["boolean_changeweapon"]	= TTTVR_WeaponSwitchMenu,
	["boolean_undo"]			= TTTVR_ScoreboardMenu
}

-- convert DeviceName to control scheme
local controllers = {
	['vive_controller']	= vive_controls,
	['knuckles']		= index_controls,
	['oculus_touch']	= oculus_controls
}

-- default the controls to the Vive ones
TTTVR_Controls = vive_controls

-- on enter VR, check what controllers the player is using and change the control scheme if we have one
hook.Add("VRMod_Start", "Benny:TTTVR:initializecontrollerbinds", function()
	if not vrmod.IsPlayerInVR(LocalPlayer()) then return end
	local devices = vrmod.GetTrackedDeviceNames()
	if not devices then
		print("TTTVR didn't recognize your controllers and is defaulting to the Vive controller scheme.")
		return
	end
	if controllers[devices[2]] then
		print("TTTVR has detected "..devices[2].." controllers.")
		TTTVR_Controls = controllers[devices[2]]
	else
		print("TTTVR didn't recognize your "..devices[2].." controllers and is defaulting to the Vive controller scheme.")
	end
end)

-- hook to prevent the default binds from working
hook.Add("VRUtilAllowDefaultAction","Benny:TTTVR:controlsblockhook", function(ActionName)

	-- just prevent all the other default binds
	return not(	ActionName == "boolean_primaryfire" or
				ActionName == "boolean_use" or
				ActionName == "boolean_jump" or
				ActionName == "boolean_left_pickup" or
				ActionName == "boolean_secondaryfire" or
				ActionName == "boolean_chat" or
				ActionName == "boolean_changeweapon" or
				ActionName == "boolean_reload" or
				ActionName == "boolean_undo" or
				ActionName == "boolean_sprint" or
				ActionName == "boolean_flashlight")
end)

-- hook for when an input is made to execute the corresponding control
hook.Add("VRUtilEventInput","Benny:TTTVR:controlsbindhook", function(ActionName, State)
	--print(ActionName)
	local action = TTTVR_Controls[ActionName]
	if action then action(LocalPlayer(), State) end
end)