---- Main TTTVR Lua File

-- Wait until gamemode is loaded to initialize addon using GM hook
hook.Add("Initialize", "Benny:TTTVR:Initialization", function()
	if SERVER then
		-- runs server initialization
		include "tttvr/init.lua"
	else
		-- runs client initialization
		include "tttvr/cl_init.lua"
	end
end)

print("TTT VR LOADED")