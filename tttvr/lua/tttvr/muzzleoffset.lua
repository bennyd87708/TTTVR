---- Muzzle Offset: hacky way to allow custom muzzle offsets for the TTTVR weapons so bullets come out of where they should in the viewmodel

-- define global muzzle offset on the client which can be altered by individual weapons
TTTVRCurrentMuzzleOffset = Vector(0,0,0)

-- function to fix offset for when it might be wrong
function TTTVRMuzzleOffsetFix()
	local wep = LocalPlayer():GetActiveWeapon()
	if not (wep.Category == "TTTVR") then return end
	wep:SetMuzzleOffset()
end

-- when a player goes into VR, start keeping track of whether they are holding a weapon with a custom muzzle offset
hook.Add("VRUtilStart", "Benny:TTTVR:clientaimstarthook", function(ply)
	
	-- needed a random once per frame hook between RenderScene and DrawTranslucentRenderables for the VRMod laser pointer to work
	hook.Add("DrawMonitors", "Benny:TTTVR:updatemuzzleoffset", function()
	
		-- don't do anything if they aren't using a TTTVR weapon
		if not (LocalPlayer():GetActiveWeapon().Category == "TTTVR") then return end
		
		-- when they are holding one, fix the VRMod globals every frame with the proper muzzle position and angle before they actually get used
		local pos,ang = g_VR.viewModelPos, g_VR.viewModelAng
		if(g_VR.viewModelMuzzle) then
			
			-- adjust the muzzle position by the global offset variable
			g_VR.viewModelMuzzle.Pos = pos + (ang:Forward()*TTTVRCurrentMuzzleOffset.x + ang:Right()*TTTVRCurrentMuzzleOffset.y + ang:Up()*TTTVRCurrentMuzzleOffset.z)
			g_VR.viewModelMuzzle.Ang = ang
		end
	end)
	
	-- apply offset for current weapon on enter VR
	timer.Simple(1, function()
		TTTVRMuzzleOffsetFix()
	end)
end)

-- stop keeping track when the player isn't in VR so we aren't wasting performance
hook.Add("VRUtilExit", "Benny:TTTVR:clientaimkillhook", function(ply)
	hook.Remove("DrawMonitors", "Benny:TTTVR:updatemuzzleoffset")
end)

-- make sure it kicks in when player spawns
gameevent.Listen("player_spawn")
hook.Add("player_spawn", "Benny:TTTVR:playerspawnoffsetfix", function()
	TTTVRMuzzleOffsetFix()
end)

--[[ Debug hook to draw the muzzle location and laser pointer on weapons to help manually setting each muzzle offset
hook.Add("PostDrawViewModel", "Benny:TTTVR:muzzledebughook", function()
	print(LocalPlayer():GetActiveWeapon())
	
	if(not (g_VR.viewModelMuzzle)) then return end
	render.SetMaterial(Material("cable/redlaser"))
	render.DrawBeam(g_VR.viewModelMuzzle.Pos, g_VR.viewModelMuzzle.Pos + g_VR.viewModelMuzzle.Ang:Forward()*10000, 1, 0, 1, Color(255,255,255,255))
	render.DrawWireframeBox(g_VR.viewModelMuzzle.Pos, g_VR.viewModelMuzzle.Ang, Vector(-0.5, -0.5, -0.5), Vector(0.5, 0.5, 0.5), Color(0, 255, 0), true)
end)
--]]