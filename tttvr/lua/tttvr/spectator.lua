---- Spectator: puts VR players into proper spectator mode when they die instead of red nothingness

-- how long to wait after death to trigger spectator mode
local countdown = 5

if SERVER then
	
	-- the reason spectator is broken is simply because the player can't click to respawn as spectator so we do it here automatically
	hook.Add("PostPlayerDeath","Benny:TTTVR:spectatorhook", function(ply)
		if(istable(vrmod) and vrmod.IsPlayerInVR(ply)) then
			timer.Simple(countdown, function()
				ply:Spawn()
			end)
		end
	end)
else
	
	-- player technically exits VR the frame that they die so we have to manually track if they were in VR when they died
	-- death is true if they are only not in VR because they have died and not respawned as a spectator yet
	-- inVR is the same as vrmod.IsPlayerInVR but stays true for one extra frame after death so we can catch if they were in VR when they died
	local inVR = false
	local death = false
	hook.Add("VRMod_Start","Benny:TTTVR:clientvrstarthook", function(ply)
		if ply == LocalPlayer() then
			inVR = true
			if death then
				if not (ply:IsSpec()) then
					death = false
				end
			else

				-- if the player tried to enter VR while in spectator mode, send warning
				-- vrmod_start isn't called the first time they try this so there is an extra one-time hook below
				if(ply:IsSpec()) then
					ply:ConCommand("vrmod_exit")
					chat.AddText(Color(255, 0, 0), "YOU MUST BE ALIVE TO ENTER VR!")
				end
			end
		end
	end)
	hook.Add("VRMod_Exit","Benny:TTTVR:clientvrexithook", function(ply)
		if ply == LocalPlayer() then
			timer.Simple(0, function()
				inVR = false
			end)
		end
	end)
	
	-- catches the first time the player tries to enter VR while in spectator mode
	hook.Add("VRMod_Tracking","Benny:TTTVR:spectatorfirstcatchhook",function()
		local ply = LocalPlayer()
		if ply:Alive() then hook.Remove("VRMod_Tracking","Benny:TTTVR:spectatorfirstcatchhook") end
		if(ply:IsSpec() and not death) then
			ply:ConCommand("vrmod_exit")
			chat.AddText(Color(255, 0, 0), "YOU MUST BE ALIVE TO ENTER VR!")
			hook.Remove("VRMod_Tracking","Benny:TTTVR:spectatorfirstcatchhook")
		end
	end)
	
	-- function runs on client when the player dies to force the camera to follow the ragdoll's POV 
	local function PlayerDeath()
		
		-- keep track of everything important to alter camera position
		local eyes
		local offset = vrmod.GetRightEyePos() - vrmod.GetEyePos()
		
		-- need to check if the player is in VR on death because we are overwriting the default net receive for this message
		-- luckily it doesn't do much, so it's really easy to handle ourselves below
		if(istable(vrmod) and inVR) then
			death = true
			
			-- VRMod uses one hook for each eye when editing the view so we have one of each here
			hook.Add("VRMod_PreRender", "Benny:TTTVR:ragdollinglefthook", function()
			
				-- first person ragdolling code stolen from cl_init
				local tgt = LocalPlayer():GetObserverTarget()
				if IsValid(tgt) and (not tgt:IsPlayer()) then
					eyes = tgt:LookupAttachment("eyes") or 0
					eyes = tgt:GetAttachment(eyes)
				end
				
				if eyes then
					g_VR.view.origin = eyes.Pos + offset
					g_VR.view.angles = eyes.Ang
				end
			end)
			
			hook.Add("VRMod_PreRenderRight", "Benny:TTTVR:ragdollingrighthook", function()
				if eyes then
					g_VR.view.origin = eyes.Pos - offset
					g_VR.view.angles = eyes.Ang
				end
			end)
			
			-- stop forcing the camera to follow the ragdoll's POV when the player gets switched to spectator mode
			timer.Simple(countdown, function()
				hook.Remove("VRMod_PreRender", "Benny:TTTVR:ragdollinglefthook")
				hook.Remove("VRMod_PreRenderRight", "Benny:TTTVR:ragdollingrighthook")
			end)
		
		-- this is the code that is normally run on TTT_PlayerDied that we overwrote, stolen from cl_init
		else
			TIPS.Show()
		end
	end
	
	-- overwrites the default TTT_PlayerDied from cl_init to use our function instead so we can handle VR and non-VR users
	net.Receive("TTT_PlayerDied", PlayerDeath)
end
