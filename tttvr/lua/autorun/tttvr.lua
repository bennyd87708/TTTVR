---- Main TTTVR Lua File

-- Wait until gamemode is loaded to initialize addon using initialize hook
hook.Add("Initialize", "Benny:TTTVR:Initialization", function()
	if SERVER then
		-- runs server initialization
		include "tttvr/init.lua"
	else
		-- runs client initialization
		include "tttvr/cl_init.lua"
	end
end)