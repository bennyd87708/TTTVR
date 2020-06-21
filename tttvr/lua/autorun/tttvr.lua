---- Main TTTVR Lua File

-- Wait until gamemode is loaded to initialize addon using GM hook
hook.Add("Initialize", "Benny:TTTVR:Initialization", function()
	local gamemode = gmod.GetGamemode().Name
	if(gamemode == "Trouble in Terrorist Town") then
		if SERVER then
			-- runs server initialization
			include "tttvr/init.lua"
		else
			-- runs client initialization
			include "tttvr/cl_init.lua"
		end
		print("TTT VR LOADED")
	end
end)
