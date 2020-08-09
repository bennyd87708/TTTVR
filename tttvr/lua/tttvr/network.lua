---- Network: location for where communication between server and client is done

-- custom "+use" server-side request that allows the player to not need to literally let go of the button on the keyboard
-- used for search bodies and entity "+use" info requests based on headset look direction rather than the right controller (must be within 84 units)
local mindistance = 84
local minsquared = mindistance*mindistance
util.AddNetworkString("TTTVRUseOverride")
net.Receive("TTTVRUseOverride", function(len, ply)
	
	-- reads what entity the client is interacting with
	local ent = net.ReadEntity()
	local dis = vrmod.GetHMDPos(ply):DistToSqr(ent:GetPos())
	
	-- if it isn't close enough and interactable, don't do anything unless they are a spectator searching a body, in which case send the client the corpse info
	if ply:IsSpec() then
		if ent:IsRagdoll() then
			CORPSE.ShowSearch(ply, ent, false)
		end
		return
	end
	
	if not ((ent:IsRagdoll() or (ent.CanUseKey and ent.UseOverride)) and (dis < minsquared) and ply:IsLineOfSightClear(ent)) then return end
	
	-- otherwise, send the client the corpse search or +use override info
	if ent:IsRagdoll() then
		
		-- could allow custom control to search corpses discretely here but haven't done so yet
		CORPSE.ShowSearch(ply, ent, false)
	else
		ent:UseOverride(ply)
	end
end)