---- Suicide: allows VR players to shoot themselves in the head

-- hook for when player shoots a weapon
hook.Add("EntityFireBullets", "Benny:TTTVR:suicidehook", function(ply, bullet)

	-- check if the person is in VR
	if(IsValid(ply) and istable(vrmod)) then
		if(vrmod.IsPlayerInVR(ply)) then
			
			-- check if the shot hits the player's own head using a box 1.5x the size of their head hitbox so it's not difficult to trigger
			local mins, maxs = ply:GetHitBoxBounds(0, 0)
			local pos, normal, frac = util.IntersectRayWithOBB(bullet.Src, bullet.Dir*100, vrmod.GetHMDPos(ply), vrmod.GetHMDAng(ply), mins*1.5, maxs*1.5)
			
			-- if it does, kill the person as if they were shot
			if pos then
				suicide = DamageInfo()
				suicide:SetAmmoType(game.GetAmmoID(bullet.AmmoType))
				suicide:SetAttacker(ply)
				suicide:SetDamage(400)
				suicide:SetDamageType(2)
				suicide:SetInflictor(ply:GetActiveWeapon())
				
				-- for some reason, no matter what I do, the camera kinda launches towards the gun
				suicide:SetDamageForce(bullet.Dir)
				suicide:SetDamagePosition(pos)
				
				-- wait one frame to actually do the damage so that the gunshot sound plays
				timer.Simple(0, function()
					ply.was_headshot = true
					ply:TakeDamageInfo(suicide)
				end)
				
				-- block the default shot so that the bullet can't also kill another person
				return false
			end
		end
	end
end)