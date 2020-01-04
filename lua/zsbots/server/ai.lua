function controlBots ( bot, cmd )
	if !bot.IsZSBot then return end
	
	cmd:ClearMovement()
	cmd:ClearButtons()
	
	SetTaskNames( bot )
	
	CheckNavMeshAttributes( bot, cmd )
	
	--debugoverlay.ScreenText( -100, 0, "SEEK_AND_DESTROY", 0, Color( 255, 255, 255 ) )
	
	--====ABOVE PLAYER====
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -12, "Name: " .. bot:Name(), 0, Color(255, 255, 255))
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -10, "Health: " .. bot:Health(), 0, Color(255, 255, 0))
	if IsValid(bot:GetActiveWeapon()) then
		debugoverlay.EntityTextAtPosition(bot:EyePos(), -9, "Ammo: " .. bot:GetActiveWeapon():Clip1() .. "/" .. bot:GetAmmoCount(bot:GetActiveWeapon():GetPrimaryAmmoType()) , 0, Color(255, 255, 0))
	end
	--====BESIDE PLAYER====
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -7, "Skill: " .. bot.Skill .. "%", 0, Color(255, 255, 255))
	if IsValid(bot.FollowerEnt) then
		debugoverlay.EntityTextAtPosition(bot:EyePos(), -6, "Task: " .. bot.taskName, 0, Color(0, 255, 0))
	end
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -5, "Disposition: " .. bot.dispositionName, 0, Color(0, 80, 255))
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -3, "Steady view: " .. "NO", 0, Color(255, 255, 0))
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -2, "Nearby friends: " .. bot.nearbyFriends, 0, Color(0, 255, 0))
	debugoverlay.EntityTextAtPosition(bot:EyePos(), -1, "Nearby enemies: " .. bot.nearbyEnemies, 0, Color(255, 50, 50))
	debugoverlay.EntityTextAtPosition(bot:EyePos(), 0, "Nav Area: " .. tostring(navmesh.GetNavArea( bot:EyePos(), math.huge )), 0, Color(255, 255, 255))
	--=====================
	
	-- Switch weapons if got no ammo
	if bot.Task == 1 or bot.Task == 4 or bot.Task == 10 then
		if bot:Team() != TEAM_UNDEAD and IsValid(bot:GetActiveWeapon()) and CurTime() > bot.targetFindDelay and bot.runAwayTimer <= 0 then
			
			curWep = bot:GetActiveWeapon()
			
			if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) and curWep.Base != "weapon_zs_basemelee" or curWep.Base == "weapon_zs_basemelee" then	
				if OtherWeaponWithAmmo(bot) != nil then
					bot:SelectWeapon(OtherWeaponWithAmmo(bot))
				end
				
				if OtherWeaponWithAmmo(bot) == nil then
					for i, meleeWep in ipairs(bot:GetWeapons()) do 
						if meleeWep.Base == "weapon_zs_basemelee" then
							bot:SelectWeapon(meleeWep)
							
							break
						end
					end
				end
			end
		end
	end
	
	if bot.Task == 1 or bot.Task == 4 or bot.Task == 10 then
		if bot:Team() != TEAM_UNDEAD then
			if IsValid(bot.FollowerEnt.Target) then
				local dtr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = AimPoint(bot),
					filter = function( ent ) if ( ent != bot.FollowerEnt.TargetLootItem and ent:GetClass() != "player" ) then return true end end
				} )

				local colour = Color( 0, 0, 0)

				if !dtr.Hit then
					colour = Color( 0, 255, 0, 0)
				else
					colour = Color( 255, 0, 0, 0)
				end

				debugoverlay.Box( bot:EyePos() + bot:EyeAngles():Forward() * bot:EyePos():Distance(AimPoint( bot )), Vector( -25, -25, -25 ), Vector( 25, 25, 25 ), 0, colour )
				debugoverlay.Line( bot:EyePos(), AimPoint( bot ), 0, colour, true )
			end
		end
	end
	
	if bot:Team() != TEAM_UNDEAD then
		if GetConVar( "zs_bot_muscular" ):GetInt() != 0 then
			bot.BuffMuscular = true
			bot:DoMuscularBones()
		end
	end
	
	for i, area in ipairs(bot.UnCheckableAreas) do
		debugoverlay.Box(Vector (0,0,0), area:GetCorner( 0 ), area:GetCorner( 2 ), 0, Color( 255, 0, 0, 5 ) )
	end
	
	for s, spot in ipairs(bot.DefendingSpots) do
		if bot.DefendingSpots[1] != nil then
			debugoverlay.Box(Vector (0,0,0), navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 0 ), navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ), 0, Color( 0, 0, 255, 5 ) )
		end
	end
	
	--bot.tangoy = Angle ( 0, bot:EyeAngles().y, bot:EyeAngles().z)
	--debugoverlay.Box( bot:GetPos() + Vector( bot.tangoy:Forward() ) * 25, Vector( -7.5, -7.5, bot:OBBMins().z + 7.5 ), Vector( 7.5, 7.5, bot:OBBMaxs().z - 7.5 ), 0, Color( 255, 255, 255 ) )
		
	--[[if IsValid( bot.FollowerEnt.TargetLootItem ) then
		if bot.FollowerEnt.TargetLootItem:GetClass() == "prop_weapon" then
			print (bot.FollowerEnt.TargetLootItem:GetWeaponType())
		else
			print (bot.FollowerEnt.TargetLootItem)
		end
	end]]
	
	bot.angle = LerpAngle( bot.rotationSpeed * FrameTime( ), bot.angle, bot.lookAngle )
	bot:SetEyeAngles(bot.angle)
	cmd:SetViewAngles(bot.angle)
	
	if !IsValid( bot.FollowerEnt ) then
		bot.FollowerEnt = ents.Create( "sent_zsbot_pathfinder" )
		bot.FollowerEnt:Spawn()
		bot.FollowerEnt.Bot = bot
	end
	
	if bot.FollowerEnt:GetPos() != bot:GetPos() and navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetClosestPointOnArea( bot:GetPos() ) != nil then
		--bot.FollowerEnt:SetPos( bot:GetPos() )
		bot.FollowerEnt:SetPos( navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetClosestPointOnArea( bot:GetPos() ) )
	end
	
	if bot.FollowerEnt.P then
		bot.LastPath = bot.FollowerEnt.P:GetAllSegments()
	end
	
	if !bot.LastPath then return end 
	
	local curgoal = bot.LastPath[bot.FollowerEnt.CurSegment]
	if !curgoal then return end
	
	if bot:GetMoveType() == MOVETYPE_LADDER then
		if bot:GetPos():Distance( curgoal.pos ) < 20 then
			if bot.LastPath[bot.FollowerEnt.CurSegment + 1] != nil then
				bot.FollowerEnt.CurSegment = bot.FollowerEnt.CurSegment + 1
			end
		end
	else
		if Vector( bot:GetPos().x, bot:GetPos().y, 0 ):Distance( Vector( curgoal.pos.x, curgoal.pos.y, 0 ) ) < 20 then
			if bot.LastPath[bot.FollowerEnt.CurSegment + 1] != nil then
				bot.FollowerEnt.CurSegment = bot.FollowerEnt.CurSegment + 1
			end
		end
	end
	
	if GAMEMODE:GetWaveActive() then
		if IsValid (bot.FollowerEnt.TargetArsenal) then
			if bot:GetPos():Distance( bot.FollowerEnt.TargetArsenal:GetPos() ) > 100 then
				bot.canShouldGoOutside = true
			end
		end
	end
	
	if CurTime() > bot.targetFindDelay then
		bot.FollowerEnt.Target = FindNearestEntity( "player", bot, 999999 )
		
		bot.nearbyFriends = CountNearbyFriends( bot, 300 )
		bot.nearbyEnemies = CountNearbyEnemies( bot, 300 )
		
		if bot:Team() == TEAM_UNDEAD then
			bot.attackProp = FindNearestProp2( bot, 999999 )
			bot.FollowerEnt.TargetPosition = FindNearestHidingSpot( bot, 999999 )
		else
			bot.FollowerEnt.TargetNailedProp = FindNearestNailedProp( bot, 999999 )
			bot.FollowerEnt.TargetCadingProp = FindNearestProp( bot, 999999 )
			bot.FollowerEnt.TargetLootItem = FindNearestLoot( bot, 999999 )
			bot.FollowerEnt.TargetArsenal = FindNearestEntity2( "prop_arsenalcrate", bot, 999999 )
			bot.FollowerEnt.TargetResupply = FindNearestEntity2( "prop_resupplybox", bot, 999999 )
			bot.FollowerEnt.TargetTeammate = FindNearestTeammate( "player", bot, 999999 )
		end
	end
	
	if IsValid (bot.FollowerEnt.TargetArsenal) then
		if CurTime() > bot.targetFindDelay then
			if bot:Team() != TEAM_UNDEAD then
				
				FindCadingSpotsInArea( bot, navmesh.GetNearestNavArea( bot.FollowerEnt.TargetArsenal:GetPos(), false, 99999999999, false, false, TEAM_ANY ) )
				
				timer.Simple( 0, function ()
					if !IsValid( bot ) or !IsValid(bot.FollowerEnt.TargetArsenal) then return end
					
					if bot.UnCheckableAreas[1] != nil then
						table.Empty(bot.UnCheckableAreas)
					end
					
					table.insert( bot.UnCheckableAreas, navmesh.GetNearestNavArea( bot.FollowerEnt.TargetArsenal:GetPos(), false, 99999999999, false, false, TEAM_ANY ) )
				end )
				
				for s, spot in ipairs(bot.DefendingSpots) do
					if bot.DefendingSpots[1] != nil then
						--debugoverlay.Box(Vector (0,0,0), navmesh.GetNavArea( spot, 3 ):GetCorner( 0 ), Vector(navmesh.GetNavArea( spot, 3 ):GetCorner( 2 ).x, navmesh.GetNavArea( spot, 3 ):GetCorner( 2 ).y, navmesh.GetNavArea( spot, 3 ):GetCorner( 2 ).z + 200), 0, Color( 255, 255, 255 ), true )
				
						local tr = util.TraceHull( {
							start = Vector( 0, 0, 0 ),
							endpos = Vector( 0, 0, 0 ),
							mins = navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 0 ),
							maxs = Vector(navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ).x, navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ).y, navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ).z + 200),
							ignoreworld = true,
							filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
						} )
						
						if tr.Entity:IsNailed()  then
							if table.HasValue(bot.CadingSpots, spot) then
								table.remove (bot.CadingSpots, table.KeyFromValue(bot.DefendingSpots, spot))
							end
						else
							if !table.HasValue(bot.CadingSpots, spot) then
								table.insert (bot.CadingSpots, spot)
							end
						end
					end
				end
				--PrintTable (bot.CadingSpots)
			end
		end
	else
		if bot.DefendingSpots[1] != nil then
			table.Empty(bot.DefendingSpots)
		end
		if bot.CadingSpots[1] != nil then
			table.Empty(bot.CadingSpots)
		end
		if bot.UnCheckableAreas[1] != nil then
			table.Empty(bot.UnCheckableAreas)
		end
	end
	
	if bot:Team() == TEAM_UNDEAD then
		if bot.DefendingSpots[1] != nil then
			table.Empty(bot.DefendingSpots)
		end
		if bot.CadingSpots[1] != nil then
			table.Empty(bot.CadingSpots)
		end
		if bot.UnCheckableAreas[1] != nil then
			table.Empty(bot.UnCheckableAreas)
		end
	end
	
	--print (#bot.DefendingSpots)
	
	if IsValid (bot:GetActiveWeapon()) and bot:Team() != TEAM_UNDEAD then
		if bot:GetActiveWeapon():Clip1() <= 0 and bot:GetActiveWeapon().Base != "weapon_zs_basemelee" then
			cmd:SetButtons (IN_RELOAD)
		end
	end
	
	if bot.prevSayMessage != bot.sayMessage then
		bot:Say (bot.sayMessage)
		bot.prevSayMessage = bot.sayMessage
	end
	
	if bot.prevSayTeamMessage != bot.sayTeamMessage then
		bot:Say (bot.sayTeamMessage, true)
		bot.prevSayTeamMessage = bot.sayTeamMessage
	end
	
	
	if bot:Team() != TEAM_UNDEAD then
		if bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
			SayPresetMessage(bot, 0, true)
		elseif bot.prevSay == 0 then
			bot.prevSay = -1
		end
		
		if IsValid (bot.FollowerEnt.Target) then
			if bot.FollowerEnt.Target:Team() == TEAM_UNDEAD then
				if bot.FollowerEnt.Target:GetZombieClassTable().Boss and bot.prevSay == -1 then
					SayPresetMessage(bot, 1, true, bot.FollowerEnt.Target:GetZombieClassTable().Name)
				end
			end
		end
		
		--if bot:HasWeapon ("weapon_zs_medicalkit") and bot:Health() <= 70 then
			--cmd:SetButtons(IN_ATTACK2)
		--end
		
		if IsValid (bot.FollowerEnt.TargetTeammate) and bot:HasWeapon("weapon_zs_medicalkit") and bot.Task != 2 then
			local medWeapon = bot:GetWeapon("weapon_zs_medicalkit")
			local medCooldown = medWeapon:GetNextCharge() - CurTime()
			
			if bot.FollowerEnt.TargetTeammate:Health() <= (3 / 4 * bot.FollowerEnt.TargetTeammate:GetMaxHealth()) and bot:Health() > (2 / 4 * bot:GetMaxHealth()) and medCooldown <= 0 and medWeapon:GetPrimaryAmmoCount() > 0 then
				bot.Task = 2
			end
		end
	end
	
	if bot.canAttackTimer then
		if bot.attackTimer then
			bot.canAttackTimer = false
			
			bot.attackHold = true
			
			timer.Simple (0.10, function()
				if !IsValid (bot) then return end
				bot.attackHold = false
				timer.Simple (0.10, function()
					if !IsValid (bot) then return end
					bot.attackTimer = false
					bot.canAttackTimer = true
				end)
			end)
		end
	end
	
	if bot.canZoomTimer then
		if bot.zoomTimer then
			bot.canZoomTimer = false
			
			bot.zoomHold = true
			
			timer.Simple (0.10, function()
				if !IsValid (bot) then return end
				bot.zoomHold = false
				timer.Simple (0.10, function()
					if !IsValid (bot) then return end
					bot.zoomTimer = false
					bot.canZoomTimer = true
				end)
			end)
		end
	end
	
	if bot.canUseTimer then
		if bot.useTimer then
			bot.canUseTimer = false
			
			bot.useHold = true
			
			
			timer.Simple (0.10, function()
				if !IsValid (bot) then return end
				bot.useHold = false
				timer.Simple (0.10, function()
					if !IsValid (bot) then return end
					bot.useTimer = false
					bot.canUseTimer = true
				end)
			end)
		end
	end
	
	if bot.canAttack2Timer then
		if bot.attack2Timer then
			bot.canAttack2Timer = false
			
			bot.attack2Hold = true
			
			
			timer.Simple (0.10, function()
				if !IsValid (bot) then return end
				bot.attack2Hold = false
				timer.Simple (0.10, function()
					if !IsValid (bot) then return end
					bot.attack2Timer = false
					bot.canAttack2Timer = true
				end)
			end)
		end
	end
	
	if bot.canDeployTimer then
		if bot.deployTimer then
			bot.canDeployTimer = false
			
			bot.lookAngle = Angle (70, bot:EyeAngles().y, bot:EyeAngles().z)
			bot.crouchHold = true
			timer.Simple (0.75, function()
				if !IsValid (bot) then return end
				bot.crouchHold = false
				timer.Simple (0, function()
					if !IsValid (bot) then return end
					bot.attackHold = true
					bot.lookAngle = Angle (0, bot:EyeAngles().y, bot:EyeAngles().z)
					timer.Simple (0.5, function()
						if !IsValid (bot) then return end
						bot.attackHold = false
						bot.Task = 1
						bot.deployTimer = false --comment this out if things no work properly
						bot.canDeployTimer = true
					end)
				end)
			end)
		end
	end
	
	if bot.canCJumpTimer and bot:GetZombieClassTable().Name != "Crow" then
		if bot.cJumpTimer then
			bot.canCJumpTimer = false
			bot.crouchHold = true
			bot.useHold = true
			
			timer.Simple (0.01, function()
				if !IsValid(bot) then return end
				bot.useHold = false
			end)
			
			timer.Simple (0.05, function()
				if !IsValid(bot) then return end
				bot.jumpHold = true
				timer.Simple (0.0125, function()
					if !IsValid(bot) then return end
					bot.jumpHold = false
					timer.Simple (1, function()
						if !IsValid(bot) then return end
						
						if bot:GetVelocity():Length() < 10 then
							bot.strafeType = 0
							--bot.useHold = true
							
							--[[timer.Simple (0.01, function()
								if !IsValid (bot) then return end
								bot.useHold = false
							end)]]
							
							timer.Simple (0.5, function()
								if !IsValid(bot) then return end
								bot.strafeType = 1
								timer.Simple (0.75, function()
									if !IsValid(bot) then return end
									bot.strafeType = -1
									
									bot.crouchHold = false
									timer.Simple (0.5, function()
										if !IsValid(bot) then return end
										bot.cJumpTimer = false
										bot.canCJumpTimer = true
									end)
								end)
							end)
						else
						
						bot.crouchHold = false
						timer.Simple (0.10, function()
							if !IsValid(bot) then return end
							bot.cJumpTimer = false
							bot.canCJumpTimer = true
							end)
						end
					end)
				end)
			end)
		end
	end
	
	if bot.attackHold then
		cmd:SetButtons( IN_ATTACK )
	end
	
	if bot.attack2Hold then
		if bot.attackHold then
			cmd:SetButtons(bit.bor ( IN_ATTACK, IN_ATTACK2 ))
		else
			cmd:SetButtons(bit.bor ( IN_SPEED, IN_ATTACK2 ))
		end
	end
	
	if bot.jumpHold then
		cmd:SetButtons( IN_JUMP )
	end
	
	if bot.crouchHold then
		if bot.attackHold then
			cmd:SetButtons( bit.bor( IN_DUCK, IN_ATTACK ) )
		elseif bot.jumpHold then
			cmd:SetButtons( bit.bor( IN_DUCK, IN_JUMP ) )
		else
			cmd:SetButtons( IN_DUCK )
		end
	end
	
	if bot.useHold then
		if bot.crouchHold then
			cmd:SetButtons( bit.bor( IN_USE, IN_DUCK ) )
		else
			cmd:SetButtons( IN_USE )
		end
	end
	
	if bot.zoomHold then
		if bot.crouchHold then
			cmd:SetButtons( bit.bor( IN_ZOOM, IN_DUCK ) )
		else
			cmd:SetButtons( IN_ZOOM )
		end
	end
	
	
	if bot.moveType == -1 then
		bot.cJumpDelay = 0
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 0 )
	elseif bot.moveType == 0 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( 0 )
	elseif bot.moveType == 1 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( -1000 )
	elseif bot.moveType == 2 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( -1000 )
	elseif bot.moveType == 3 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( -1000 )
	elseif bot.moveType == 4 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( 0 )
	elseif bot.moveType == 5 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( 1000 )
	elseif bot.moveType == 6 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 1000 )
	elseif bot.moveType == 7 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( 1000 )
	end
	
	
	if bot.strafeType == 0 then
		cmd:SetSideMove( 1000 )
	elseif bot.strafeType == 1 then
		cmd:SetSideMove( -1000 )
	else
		--cmd:SetSideMove( 0 )
	end
	
	--Task 0
	--Humans: Hit zombies with melee weapon
	--Zombies: Go to nearest target
		if bot.Task == 0 then
			if bot:Team() != TEAM_UNDEAD then
				--if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
					--cmd:SetForwardMove( 1000 )
					--
					
					--if bot:GetMoveType() == MOVETYPE_LADDER then
					
						--DoLadderMovement( bot, cmd, curgoal )
						
					--else
						--CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
					--end
				--elseif bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 250 then 
					--bot.moveType = -1
					
					--bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
					
					--bot.attackTimer = true
				--else
					--bot.moveType = 4
					
					--bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
					
					--bot.attackTimer = true
				--end
				
				local myTarget = bot.FollowerEnt.Target
				
				if bot:Health() <= (2 / 4 * bot:GetMaxHealth()) or bot:GetActiveWeapon().Base != "weapon_zs_basemelee" or bot:GetActiveWeapon():GetClass() == "weapon_zs_hammer" or !IsValid (myTarget) or myTarget:Health() <= 0 then
					--cmd:SetSideMove( 0 )
					bot.Task = 1
				end
				
				if IsValid (myTarget) then
				
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						DoLadderMovement( bot, cmd, curgoal )	
			
					else
						bot.b = true
						
						if bot:GetPos():Distance( myTarget:GetPos() ) > 150 then -- was 45
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
							
						elseif bot:GetPos():Distance( myTarget:GetPos() ) > 45 then
							bot.attackTimer = true

							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
							
							--cmd:SetSideMove( 1000 )
						else
							bot.attackTimer = true
						
							bot.moveType = -1
				
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
							
							--cmd:SetSideMove( 1000 )
						end
						
						if bot:GetPos():Distance( myTarget:GetPos() ) >= 45 and bot:GetPos():Distance( myTarget:GetPos() ) < 400 and bot:GetMoveType() != MOVETYPE_LADDER then
							bot.lookAngle = (myTarget:EyePos() - bot:EyePos()):Angle()
						end
					end
				end
			
			elseif IsValid( bot.FollowerEnt.Target ) then
				local myTarget = bot.FollowerEnt.Target
				
				if bot:GetZombieClassTable().Name != "Crow" and myTarget:Health() > 0 then
					
					--print (bot.FollowerEnt.TargetPosition)
					if !GAMEMODE:GetWaveActive() then
				
						local tr = util.TraceLine( {
							start = bot:EyePos(),
							endpos = AimPoint( bot ),
							filter = function( ent ) if ( ent != myTarget and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
						} )
				
						if tr.Hit and bot.FollowerEnt.TargetPosition != nil then
							bot.Task = 1
						end
					end
			
					if bot:GetZombieClassTable().Name != "Fast Zombie" and bot:GetZombieClassTable().Name != "Wraith" then
						if bot:GetPos():Distance( myTarget:GetPos() ) > 45 then -- was 65
							if bot.lookPos == nil then
								CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
							else
								bot.moveType = -1
							
							end
					
							if bot:GetMoveType() == MOVETYPE_LADDER then
						
								DoLadderMovement( bot, cmd, curgoal )	
						
							else
								bot.b = true
							end
						else
							bot.moveType = -1
						
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
						end
					end
				
					if bot:GetZombieClassTable().Name == "Fast Zombie" or bot:GetZombieClassTable().Name == "Wraith" then
						if bot:GetPos():Distance( myTarget:GetPos() ) > 45 then
							if bot.lookPos == nil then
								CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
							else
								bot.moveType = -1
							
							end
					
							if bot:GetMoveType() == MOVETYPE_LADDER then
						
								DoLadderMovement( bot, cmd, curgoal )	
						
							else
								bot.b = true
							end
						else
							bot.moveType = -1
						
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
						end
					end
			
					if !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER and IsValid(bot.attackProp) then
						if bot:GetPos():Distance( bot.attackProp:GetPos() ) < 150 then
							if bot.crouchHold then
								cmd:SetButtons( bit.bor( IN_ATTACK, IN_DUCK ) )
							else
								cmd:SetButtons( IN_ATTACK )
							end
							--print (bot.attackProp)
						else
							--print ("noprop")
						end
					end
				
					if bot:GetPos():Distance( myTarget:GetPos() ) < 150 and !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
						if bot:GetZombieClassTable().Name != "Fast Zombie" and bot:GetZombieClassTable().Name != "Wraith" then
							if bot.crouchHold then
								cmd:SetButtons( bit.bor( IN_ATTACK, IN_DUCK ) )
							else
								cmd:SetButtons( IN_ATTACK )
							end
						end
					end
				
					if bot:GetPos():Distance( myTarget:GetPos() ) < 45 and !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
						if bot:GetZombieClassTable().Name == "Fast Zombie" or bot:GetZombieClassTable().Name == "Wraith" then
							if bot.crouchHold then
								cmd:SetButtons( bit.bor( IN_ATTACK, IN_DUCK ) )
							else
								cmd:SetButtons( IN_ATTACK )
							end
						end
					end
					
					if bot:GetPos():Distance( myTarget:GetPos() ) >= 45 and bot:GetPos():Distance( myTarget:GetPos() ) < 400 and !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
						if bot:GetZombieClassTable().Name == "Fast Zombie" then
							bot.lookAngle = (AimPoint( bot ) - Vector(bot:EyePos().x, bot:EyePos().y, bot:EyePos().z - (bot:GetPos():Distance( myTarget:GetPos()) / 4 ) ) ):Angle()
							bot.attack2Timer = true
						else
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
						end
					end
					
					--if bot:GetPos():Distance( bot.lookProp:GetPos() ) < 150 then
					
					local mr = 0
					
					if IsValid( bot:GetActiveWeapon() ) then
						if bot:GetActiveWeapon().MeleeReach != nil then
							mr = bot:GetActiveWeapon().MeleeReach
						else
							mr = 65
						end
					else
						mr = 65
					end
				
					mr = mr - 10
				
					if mr < 0 then mr = 0 end
				
					if bot.lookPos != nil then
						bot.moveType = -1
			
						bot.lookAngle = ((bot.lookPos - bot:EyePos()):Angle())
				
						if bot.crouchHold then
							cmd:SetButtons( bit.bor( IN_ATTACK, IN_DUCK ) )
						else
							cmd:SetButtons( IN_ATTACK )
						end
					
						if bot:EyePos():Distance( bot.lookPos ) > (mr + 10) or !IsValid(bot.lookProp) or !bot.lookProp:IsNailed() then
							bot.lookPos = nil
						end
					else
					
						local tr = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:EyePos() + bot:EyeAngles():Forward() * mr,
							filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
						} )
					
						if tr.Entity:IsNailed() then
							bot.lookPos = tr.HitPos
							bot.lookProp = tr.Entity
						else
							local tr2 = util.TraceLine( {
								start = bot:EyePos(),
								endpos = bot:EyePos() + Angle(bot:EyeAngles().x - 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
								filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
							} )
		
							if tr2.Entity:IsNailed() then
								bot.lookPos = tr2.HitPos
								bot.lookProp = tr2.Entity
							else
								local tr3 = util.TraceLine( {
									start = bot:EyePos(),
									endpos = bot:EyePos() + Angle(bot:EyeAngles().x + 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
									filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
							} )
		
								if tr3.Entity:IsNailed() then
									bot.lookPos = tr3.HitPos
									bot.lookProp = tr3.Entity
								end
							end
						end
					end
				
					--print (bot.lookPos)
					if IsValid (bot:GetActiveWeapon()) then
						if bot:GetActiveWeapon().MeleeReach != nil then
							debugoverlay.Line( bot:EyePos(), bot:EyePos() + bot:EyeAngles():Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
							debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(bot:EyeAngles().x - 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
							debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(bot:EyeAngles().x + 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
						end
					end
				end
			else
				
				bot.moveType = -1
			end
			
			if bot:GetZombieClassTable().Name == "Crow" then
				bot.moveType = -1
			end
		end
		
	--Task 1
	--Humans: Go to arsenal
	--Zombies: Go to hiding spot
	
	if bot.Task == 1 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetArsenal
			--bot:EyePos() + bot:EyeAngles():Forward() * bot:EyePos():Distance(AimPoint( bot ))
			
			if IsValid (bot.FollowerEnt.Target) then
				if bot:GetActiveWeapon().Base == "weapon_zs_basemelee" and bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" and bot:Health() > (2 / 4 * bot:GetMaxHealth()) and bot.FollowerEnt.Target:Health() > 0 then
					local mtr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = AimPoint( bot ),
						filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
					} )
					
					if !mtr.Hit and bot.runAwayTimer <= 0 and !IsValid(OtherWeaponWithAmmo(bot)) then
						bot.Task = 0
					end
				end
			end
			
			if IsValid (bot.FollowerEnt.TargetLootItem) and GetConVar( "zs_bot_can_pick_up_loot" ):GetInt() != 0 then
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = bot.FollowerEnt.TargetLootItem:LocalToWorld(bot.FollowerEnt.TargetLootItem:OBBCenter()),
					filter = function( ent ) if ( ent != bot.FollowerEnt.TargetLootItem and ent:GetClass() != "player" ) then return true end end
				} )
				
				debugoverlay.Line( bot:EyePos(), bot.FollowerEnt.TargetLootItem:LocalToWorld(bot.FollowerEnt.TargetLootItem:OBBCenter()), 0, Color( 255, 255, 255 ), false )
				
				if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
					if !tr.Hit then
					
						local tr2 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = AimPoint( bot ),
							filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
						} )
						
						if tr2.Hit then
							bot.Task = 9
						end
					end
				else
					if !tr.Hit then
						bot.Task = 9
					end
				end
			end
		
			if IsValid (myTarget) then
				if bot:GetPos():Distance( myTarget:GetPos() ) > 100 then

					if bot:GetMoveType() == MOVETYPE_LADDER then
						
						DoLadderMovement( bot, cmd, curgoal )
				
					else
						bot.b = true
						
						if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
							
							local tr = util.TraceLine( {
								start = bot:EyePos(),
								endpos = AimPoint( bot ),
								filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
							} )
							
							if bot.runAwayTimer <= 0 then
								
								if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
									CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
									
								elseif bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 150 then --was 250
						
									if !tr.Hit and bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
											
										bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
										ShootAtTarget( bot )
										
										CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
									end
								
									if tr.Hit or bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
										CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
										
									end
								else
									--[[if !tr.Hit and bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
									
										bot.moveType = 4
									
										bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
										
										ShootAtTarget( bot )
									end]]
								
									--[[if tr.Hit or bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
										CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
										
									end]]
									
									bot.runAwayTimer = math.random(1, 3)
								end
							else
								bot.runAwayTimer = bot.runAwayTimer - FrameTime()
								--print ("running away" .. bot.runAwayTimer)
								CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
								
								if bot:GetActiveWeapon().Base != "weapon_zs_basemelee" then
									for i, meleeWep in ipairs(bot:GetWeapons()) do 
										if meleeWep.Base == "weapon_zs_basemelee" then
											bot:SelectWeapon(meleeWep)
											
											break
										end
									end
								end
							end
						else
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
						end
					end
				else
					bot.moveType = -1
					
					if IsValid( bot:GetActiveWeapon() ) then
						--print (bot.FollowerEnt.TargetCadingSpot)
						if bot:GetActiveWeapon().Base != "weapon_zs_basemelee" then
							bot.guardTimer = bot.guardTimer - FrameTime()
							--print (bot.guardTimer)
					
							if bot.guardTimer <= 0 then
								bot.FollowerEnt.TargetCadingSpot = table.Random(bot.DefendingSpots)
								bot.guardTimer = math.random( 5, 10 )
								
								bot.Task = 10
							end
						end
					end
					if bot:HasWeapon("weapon_zs_resupplybox") then
						bot.Task = 3
					end
					if IsValid( bot:GetActiveWeapon()) and IsValid(bot.FollowerEnt.TargetResupply) and CurTime() > bot.targetFindDelay then
						curWep = bot:GetActiveWeapon()
						
						if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) <= 0 and curWep.Base != "weapon_zs_basemelee" then
							if OtherWeaponWithAmmo(bot) == nil then
								bot.Task = 8
							end
						end
						
						if curWep.Base == "weapon_zs_basemelee" then
							if OtherWeaponWithAmmo(bot) == nil then
								for i, wep in ipairs(bot:GetWeapons()) do
									if wep:Clip1() <= 0 and bot:GetAmmoCount( wep:GetPrimaryAmmoType() ) <= 0 and wep.Base != "weapon_zs_basemelee" then
										bot:SelectWeapon(wep)
										bot.Task = 8
										break
									end
								end
							end
						end
					end
						
					if GetConVar( "zs_bot_can_cade" ):GetInt() != 0 then
						if IsValid (bot.FollowerEnt.TargetCadingProp) and bot.BuffMuscular and bot.CadingSpots[1] != nil then
							if bot:HasWeapon("weapon_zs_hammer") then
								bot.Task = 6
							end	
						end
					end
					if IsValid (bot.FollowerEnt.TargetNailedProp) and !bot.BuffMuscular then
						if bot:HasWeapon("weapon_zs_hammer") and bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
							bot.Task = 5
						end	
					end
					
					if bot.canShouldGoOutside then
						if math.random (1, 4) <= 3 then
							bot.shouldGoOutside = true
							--print ("I should go outside")
						else
							bot.shouldGoOutside = false
							--print ("I shouldn't go outside")
						end
						bot.canShouldGoOutside = false
					end
				
					if IsValid (myTarget) then
						if bot:Health() > (3 / 4 * bot:GetMaxHealth()) and !GAMEMODE:GetWaveActive() and GAMEMODE:GetWave() != 0 and bot.shouldGoOutside then
							bot.FollowerEnt.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 500, 10, 10)
							bot.Task = 4
						end
					end
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
							
						DoLadderMovement( bot, cmd, curgoal )
				
					else
						bot.b = true
						
						if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
					
							local tr = util.TraceLine( {
								start = bot:EyePos(),
								endpos = AimPoint( bot ),
								filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
							} )
							
							if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
								bot.moveType = -1
							elseif bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 250 then
							
								if !tr.Hit then
						
									bot.moveType = -1
									
									bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
					
									ShootAtTarget( bot )
								else
									bot.moveType = -1
								end
							else
								if !tr.Hit then
						
									bot.moveType = 4
									
									bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
					
									ShootAtTarget( bot )
								else
									bot.moveType = -1
								end
							end
						end
					end
				end
				
				CheckPropPhasing (bot, cmd)
				
				--debugoverlay.Box( bot:GetPos(), Vector( -18, -18, 0 ), Vector( 18, 18, 73 ),0, Color( 255, 255, 255 ), false )
				
			else--if GAMEMODE:GetWave() != 0 then
				bot.FollowerEnt.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 1000, 10, 10)
				bot.Task = 4
			end
			
		elseif bot:GetZombieClassTable().Name != "Crow" then
			
			local myTarget = bot.FollowerEnt.TargetPosition
			
			if IsValid( bot.FollowerEnt.Target ) then 
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = AimPoint( bot ),
					filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
				} )
			
				if GAMEMODE:GetWaveActive() or !tr.Hit or bot.myTarget == nil then
					bot.Task = 0
				end
				
				if bot.myTarget != nil then
					if bot:GetPos():Distance( bot.myTarget ) > 45 then		
						if bot:GetMoveType() == MOVETYPE_LADDER then
			
							DoLadderMovement( bot, cmd, curgoal )	
			
						else
							bot.b = true
			
							CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
						end
					else
						bot.moveType = -1
				
						bot.lookAngle.y = ( bot:GetPos() - bot.myTarget ):GetNormal():Angle().y
					end
				end
			end
		end
	end
	
	--Task 2
	--Humans: Go to teammate and heal them
	--Zombies: (Shade) Pickup props and throw them at humans
	if bot.Task == 2 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetTeammate
			
			if bot:HasWeapon("weapon_zs_medicalkit") then
				
				if bot:GetActiveWeapon():GetClass() != "weapon_zs_medicalkit" then
					bot.lastWeapon = bot:GetActiveWeapon()
					cmd:SelectWeapon (bot:GetWeapon("weapon_zs_medicalkit"))
				end
				
				local medWep = bot:GetWeapon("weapon_zs_medicalkit")
				local medCooldown = (medWep:GetNextCharge() - CurTime())
				
				if !IsValid (myTarget) or bot:Health() <= (2 / 4 * bot:GetMaxHealth()) or medCooldown > 0 or medWep:GetPrimaryAmmoCount() <= 0 then 
					if IsValid (bot.lastWeapon) then
						cmd:SelectWeapon (bot.lastWeapon)
					end
			
					bot.Task = 1
				end
				
				if IsValid (myTarget) then
					if myTarget:Health() > (3 / 4 * myTarget:GetMaxHealth()) then --or bot:GetActiveWeapon():GetClass() != "weapon_zs_medicalkit"
						if IsValid (bot.lastWeapon) then
							cmd:SelectWeapon (bot.lastWeapon)
						end
					
						bot.Task = 1
					end
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						DoLadderMovement( bot, cmd, curgoal )
				
					else
						bot.b = true
							
						if bot:GetPos():Distance( myTarget:GetPos() ) > 45 then
							
							bot.lookAngle = ((myTarget:EyePos() - bot:EyePos()):Angle())
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						else
							bot.moveType = -1
						
							bot.lookAngle = ((myTarget:EyePos() - bot:EyePos()):Angle())
						
							bot.attackTimer = true
						end
					end
				end
				
				CheckPropPhasing (bot, cmd)
			else
				if IsValid (bot.lastWeapon) then
					cmd:SelectWeapon (bot.lastWeapon)
				end
			
				bot.Task = 1
			end
		else
			--Put Shade AI here
		end
	end
	
	--Task 3
	--Humans: Place resupply box
	--Zombies: ...
	if bot.Task == 3 then
		if bot:Team() != TEAM_UNDEAD then
			if bot:GetActiveWeapon():GetClass() != "weapon_zs_resupplybox" and bot:HasWeapon("weapon_zs_resupplybox") then
				cmd:SelectWeapon (bot:GetWeapon("weapon_zs_resupplybox"))
			end
			
			--bot.attackTimer = true
			bot.deployTimer = true
		end
	end
	
	--Task 4
	--Humans: Wander around
	--Zombies: ...
	if bot.Task == 4 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetPosition
			
			if GAMEMODE:GetWave() == 0 and IsValid( bot.FollowerEnt.TargetArsenal ) then
				bot.Task = 1
			end
			
			if IsValid (bot.FollowerEnt.TargetLootItem) and GetConVar( "zs_bot_can_pick_up_loot" ):GetInt() != 0 then
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = bot.FollowerEnt.TargetLootItem:LocalToWorld(bot.FollowerEnt.TargetLootItem:OBBCenter()),
					filter = function( ent ) if ( ent != bot.FollowerEnt.TargetLootItem and ent:GetClass() != "player" ) then return true end end
				} )
				
				debugoverlay.Line( bot:EyePos(), bot.FollowerEnt.TargetLootItem:LocalToWorld(bot.FollowerEnt.TargetLootItem:OBBCenter()), 0, Color( 255, 255, 255 ), false )
				
				if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
					if !tr.Hit then
					
						local tr2 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = AimPoint( bot ),
							filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
						} )
						
						if tr2.Hit then
							bot.Task = 9
						end
					end
				else
					if !tr.Hit then
						bot.Task = 9
					end
				end
			end
			
			if Vector( bot:GetPos().x, bot:GetPos().y, 0 ):Distance( Vector( myTarget.x, myTarget.y, 0 ) ) < 20 then
				bot.FollowerEnt.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 1000, 10, 10)
				bot.FollowerEnt:ComputePath (bot.FollowerEnt.P, myTarget)
			end
			
			if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = AimPoint( bot ),
					filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
				} )
				
				if bot:GetActiveWeapon().Base == "weapon_zs_basemelee" and bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" and bot:Health() > (2 / 4 * bot:GetMaxHealth()) and bot.FollowerEnt.Target:Health() > 0 then					
					if !tr.Hit and bot.runAwayTimer <= 0 and !IsValid(OtherWeaponWithAmmo(bot)) then
						bot.Task = 0
					end
				end
				
				if bot:GetMoveType() == MOVETYPE_LADDER then
					
					DoLadderMovement( bot, cmd, curgoal )
				
				else
					bot.b = true
					
					if bot.runAwayTimer <= 0 then
						if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
							CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
							
						elseif bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 150 then --was 250
				
							if !tr.Hit and bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
									
								bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
								ShootAtTarget( bot )
								
								CloseToPointCheck (bot, curgoal.pos, myTarget, cmd, false)
							end
						
							if tr.Hit or bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
								CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
								
							end
						else
							--[[if !tr.Hit and bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
							
								bot.moveType = 4
							
								bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
								
								ShootAtTarget( bot )
							end]]
						
							--[[if tr.Hit or bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
								CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
								
							end]]
							
							bot.runAwayTimer = math.random(1, 3)
						end
					else
						bot.runAwayTimer = bot.runAwayTimer - FrameTime()
						--print ("running away" .. bot.runAwayTimer)
						CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
						
						if bot:GetActiveWeapon().Base != "weapon_zs_basemelee" then
							for i, meleeWep in ipairs(bot:GetWeapons()) do 
								if meleeWep.Base == "weapon_zs_basemelee" then
									bot:SelectWeapon(meleeWep)
									
									break
								end
							end
						end
					end
				end
			else
				if bot:GetMoveType() == MOVETYPE_LADDER then
					DoLadderMovement( bot, cmd, curgoal )
				else
					bot.b = true
	
					CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
				end
			end
			
			CheckPropPhasing (bot, cmd)
			
			if IsValid (bot.FollowerEnt.TargetArsenal) then
				if bot:Health() <= (3 / 4 * bot:GetMaxHealth()) or GAMEMODE:GetWaveActive() then
					bot.Task = 1
				end
			end
		end
	end
	
	--Task 5
	--Humans: Repair cades
	--Zombies: ...
	if bot.Task == 5 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetNailedProp
			
			if bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
				
				if IsValid (bot.lastWeapon) then
					cmd:SelectWeapon (bot.lastWeapon)
				end
				bot.lookPos = nil
				bot.lookProp = nil
				bot.Task = 1
			end
					
			if IsValid(myTarget) then
				if bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" then
					bot.lastWeapon = bot:GetActiveWeapon()
					cmd:SelectWeapon (bot:GetWeapon("weapon_zs_hammer"))
				end
				
				if IsValid (bot:GetActiveWeapon()) then
					debugoverlay.Line( bot:EyePos(), bot:EyePos() + bot:EyeAngles():Forward() * 65 , 0, Color( 255, 255, 255 ), false )
					debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(bot:EyeAngles().x - 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * 65 , 0, Color( 255, 255, 255 ), false )
					debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(bot:EyeAngles().x + 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * 65 , 0, Color( 255, 255, 255 ), false )
				end
				
				local mr = 0
					
				if IsValid( bot:GetActiveWeapon() ) then
					if bot:GetActiveWeapon().MeleeReach != nil then
						mr = bot:GetActiveWeapon().MeleeReach
					else
						mr = 65
					end
				else
					mr = 65
				end
				
				mr = mr - 10
				
				if mr < 0 then mr = 0 end
				
				if bot.lookPos != nil then
					bot.moveType = -1
			
					bot.lookAngle = ((bot.lookPos - bot:EyePos()):Angle())
				
					if bot.crouchHold then
						cmd:SetButtons( bit.bor( IN_ATTACK, IN_DUCK ) )
					else
						cmd:SetButtons( IN_ATTACK )
					end
					
					if bot:EyePos():Distance( bot.lookPos ) > (mr + 10) or !IsValid(bot.lookProp) or !bot.lookProp:IsNailed() or bot.lookProp != myTarget then
						bot.lookPos = nil
					end
				else
					CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
					
					bot.lookAngle = ((myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle())
					
					local tr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + bot:EyeAngles():Forward() * mr,
						filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
					} )
					
					if tr.Entity == myTarget then
						bot.lookPos = tr.HitPos
						bot.lookProp = tr.Entity
					else
						local tr2 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:EyePos() + Angle(bot:EyeAngles().x - 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
							filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
						} )
		
						if tr2.Entity == myTarget then
							bot.lookPos = tr2.HitPos
							bot.lookProp = tr2.Entity
						else
							local tr3 = util.TraceLine( {
								start = bot:EyePos(),
								endpos = bot:EyePos() + Angle(bot:EyeAngles().x + 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
								filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
							} )
		
							if tr3.Entity == myTarget then
								bot.lookPos = tr3.HitPos
								bot.lookProp = tr3.Entity
							end
						end
					end
				end
			else
				
				if IsValid (bot.lastWeapon) then
					cmd:SelectWeapon (bot.lastWeapon)
				end
				bot.lookPos = nil
				bot.lookProp = nil
				bot.Task = 1
			end
		end
	end
	
	--Task 6
	--Humans: Pick up prop for cading
	--Zombies: ...
	if bot.Task == 6 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetCadingProp
			
			if IsValid(myTarget) then
				if bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" then
					bot.lastWeapon = bot:GetActiveWeapon()
					cmd:SelectWeapon (bot:GetWeapon("weapon_zs_hammer"))
				end
				
				if bot:GetPos():Distance( myTarget:GetPos() ) > 50 then
		
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						DoLadderMovement( bot, cmd, curgoal )
					
					else
						bot.b = true
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						bot.lookAngle = ((myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle())
					end
			
				else
					bot.moveType = -1
					
					bot.lookAngle = ((myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle())
					bot.heldProp = myTarget
					bot.useTimer = true
				end
				
				CheckPropPhasing (bot, cmd)
				
				if myTarget:GetHolder() == bot then
					bot.Task = 7
				end
			else
				bot.useTimer = true
				bot.Task = 1
			end
		end
	end
	
	--Task 7
	--Humans: Cade at cading spots
	--Zombies: ...
	if bot.Task == 7 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetCadingSpot
			
			if !IsValid(bot.heldProp) then
				bot.Task = 1
			end
			
			if bot.CadingSpots[1] != nil then
				myTarget = bot.CadingSpots[1]
				
				local oof = bot:GetPos()
				
				if bot.heldProp:GetHolder() == bot then
					oof = bot.heldProp:GetPos()
				end
				
				if oof:Distance( myTarget ) > 75 then
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						DoLadderMovement( bot, cmd, curgoal )
					
					else
						bot.b = true
						
						bot:LookatPosXY( cmd, myTarget )
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						
						bot.heldProp:SetAngles(LerpAngle( 10 * FrameTime( ), bot.heldProp:GetAngles(), Angle(0,0,0) ))
						
					end
					
				else
					bot.moveType = -1
					
					local tr = util.TraceLine( {
						start = Vector(bot.heldProp:GetPos().x, bot.heldProp:GetPos().y, myTarget.z),
						endpos = bot.heldProp:GetPos(),
						filter = function( ent ) if ( ent == bot.heldProp ) then return true end end
					} )
					
					debugoverlay.Line( Vector(bot.heldProp:GetPos().x, bot.heldProp:GetPos().y, myTarget.z), bot.heldProp:GetPos(), 0, Color( 255, 255, 255 ), false )
					
					print (tr.StartPos:Distance( tr.HitPos ))
					--print (Vector(0, 0, bot.heldProp:GetPos().z + bot.heldProp:GetCollisionBounds().z))
					if !bot.attack2Hold and tr.StartPos:Distance( tr.HitPos ) <= 10 then
						cmd:SetButtons( IN_SPEED )
					end
					bot.attack2Timer = true
					--bot.lookAngle = ((myTarget - bot:EyePos()):Angle())
					bot.lookAngle = Angle(bot.lookAngle.x + 0.5, (myTarget - bot:EyePos()):Angle().y, bot.lookAngle.z)
					--bot.Task = 1
					if bot.lookAngle.x >= 89 then 
						if IsValid (bot.lastWeapon) then
							cmd:SelectWeapon (bot.lastWeapon)
						end
						--bot.heldProp = nil
						
						bot.Task = 1 
					end
					
					if bot.heldProp:IsNailed() then
						if IsValid (bot.lastWeapon) then
							cmd:SelectWeapon (bot.lastWeapon)
						end
						--bot.heldProp = nil
						
						bot.Task = 1
					end
				end
			else
				if IsValid (bot.lastWeapon) then
					cmd:SelectWeapon (bot.lastWeapon)
				end
				bot.Task = 1
			end
		end
	end
	
	--Task 8
	--Humans: Get ammo from resupply box / pack resupply box
	--Zombies: ...
	if bot.Task == 8 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetResupply
			
			if IsValid(myTarget) then
				if bot:GetMoveType() == MOVETYPE_LADDER then
					
					DoLadderMovement( bot, cmd, curgoal )
					
				else
					bot.b = true
					
					if bot:GetPos():Distance( myTarget:GetPos() ) > 75 then
							
						bot.lookAngle = (myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle()
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
					else
						bot.moveType = -1
						
						bot.lookAngle = (myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle()
						bot.useTimer = true
						bot.Task = 1
					end
				end
			else
				bot.Task = 1
			end
			
			CheckPropPhasing (bot, cmd)
		end
	end
	
	--Task 9
	--Humans: Pick up loot
	--Zombies: ...
	if bot.Task == 9 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetLootItem
			
			if GetConVar( "zs_bot_can_pick_up_loot" ):GetInt() == 0 then
				bot.moveType = -1
				bot.crouchHold = false
				bot.Task = 1
			end
			
			if IsValid(myTarget) then
				
				if bot:GetMoveType() == MOVETYPE_LADDER then
						
					DoLadderMovement( bot, cmd, curgoal )
				
				else
					bot.b = true
					
					if bot:GetPos():Distance( myTarget:LocalToWorld(myTarget:OBBCenter()) ) > 250 then
									
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						
						bot.lookAngle = ((myTarget:EyePos() - bot:EyePos()):Angle())
							
					elseif bot:GetPos():Distance( myTarget:LocalToWorld(myTarget:OBBCenter()) ) > 30 then
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						bot.lookAngle = ((myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle())
						
						bot.crouchHold = true
						bot.useTimer = true
					else
						bot.moveType = -1
						
						bot.lookAngle = ((myTarget:LocalToWorld(myTarget:OBBCenter()) - bot:EyePos()):Angle())
						
						bot.useTimer = true
						bot.crouchHold = true
					end
				end
			else
				bot.moveType = -1
				bot.crouchHold = false
				bot.Task = 1
			end
			
			CheckPropPhasing (bot, cmd)
		end
	end
	
	--Task 10
	--Humans: Defend at defending spot
	--Zombies: ...
	if bot.Task == 10 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetCadingSpot
			
			if bot.DefendingSpots[1] != nil then
				
				bot.guardTimer = bot.guardTimer - FrameTime()
				--print (bot.guardTimer)
				
				if bot.guardTimer <= 0 then
					if math.random(0, 1) == 0 then
						bot.guardTimer = math.random( 5, 10 )
					
						bot.Task = 1
					else
						myTarget = table.Random(bot.DefendingSpots)
						
						bot.guardTimer = math.random( 5, 10 )					
					end
				end
				
				
				if bot:GetMoveType() == MOVETYPE_LADDER then
					
					DoLadderMovement( bot, cmd, curgoal )
					
				else
					bot.b = true
					
					if bot:GetPos():Distance( myTarget ) > 125 then
						if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
							if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
								if bot:GetMoveType() == MOVETYPE_LADDER then
						
									DoLadderMovement( bot, cmd, curgoal )
						
								else
									bot.b = true
									
									bot:LookatPosXY( cmd, myTarget )
									CloseToPointCheck (bot, curgoal.pos, myTarget, cmd, false)
								end
							else
							
								local tr = util.TraceLine( {
									start = bot:EyePos(),
									endpos = AimPoint( bot ),
									filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
								} )
								
								if !tr.Hit then
									bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
									
									ShootAtTarget( bot, AimPoint( bot ) )
									
									CloseToPointCheck (bot, curgoal.pos, myTarget, cmd, false)
								end
							
								if tr.Hit then
									--cmd:SetForwardMove( 1000 )
									
				
									if bot:GetMoveType() == MOVETYPE_LADDER then
							
										DoLadderMovement( bot, cmd, curgoal )
							
									else
										bot.b = true
					
										CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
									end
								end
							end
						else
							if bot:GetMoveType() == MOVETYPE_LADDER then
						
								DoLadderMovement( bot, cmd, curgoal )
						
							else
								bot.b = true
								
								CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
							end
						end					
					else
						bot.moveType = -1
					
						if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
							if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) <= 500 then
								local tr = util.TraceLine( {
									start = bot:EyePos(),
									endpos = AimPoint( bot ),
									filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
								} )
								
								if !tr.Hit then
									bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
					
									ShootAtTarget( bot )
								end
							end
						end
					end
				end
			else
				bot.Task = 1
			end
		end
	end
	
	--Task 11
	--Humans: Snipe zombies
	--Zombies: ...
	if bot.Task == 11 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.TargetPosition
			
			if bot:GetPos():Distance( myTarget ) > 125 then
				if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
					if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) > 500 then
						if bot:GetMoveType() == MOVETYPE_LADDER then
				
							DoLadderMovement( bot, cmd, curgoal )
				
						else
							bot.b = true
							
							bot:LookatPosXY( cmd, myTarget )
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						end
					else
					
						local tr = util.TraceLine( {
							start = bot:EyePos(),
							endpos = AimPoint( bot ),
							filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
						} )
						
						if !tr.Hit then
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
							
							ShootAtTarget( bot, AimPoint( bot ) )
							
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						end
					
						if tr.Hit then
							--cmd:SetForwardMove( 1000 )
							
		
							if bot:GetMoveType() == MOVETYPE_LADDER then
					
								DoLadderMovement( bot, cmd, curgoal )
					
							else
								bot.b = true
			
								CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
							end
						end
					end
				else
					if bot:GetMoveType() == MOVETYPE_LADDER then
				
						DoLadderMovement( bot, cmd, curgoal )
				
					else
						bot.b = true
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
					end
				end					
			else
				bot.moveType = -1
			
				if IsValid (bot.FollowerEnt.Target) and bot.FollowerEnt.Target:Health() > 0 then
					if bot:GetPos():Distance( bot.FollowerEnt.Target:GetPos() ) <= 2000 then
						local tr = util.TraceLine( {
							start = bot:EyePos(),
							endpos = AimPoint( bot ),
							filter = function( ent ) if ( ent != bot.FollowerEnt.Target and ent != bot and ent:GetClass() != "player" and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
						} )
						
						if !tr.Hit then
							bot.lookAngle = ((AimPoint( bot ) - bot:EyePos()):Angle())
							bot.attack2Hold = true
							ShootAtTarget( bot )
						else
							bot.attack2Hold = false
						end
					end
				end
			end
		end
	end
	
	--Task 12
	--Humans: Spawnkill zombies
	--Zombies: ...
	if bot.Task == 11 then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.FollowerEnt.Target
		end
	end
	
	--Timer resets DO NOT REMOVE
	if CurTime() > bot.targetFindDelay then
		bot.targetFindDelay = CurTime() + 0.5
	end
end
hook.Add( "StartCommand", "controlBots", controlBots )

function botDeath( ply )
	if !ply.IsZSBot then return end
	
	if GAMEMODE:GetWave() == 0 then return end
	if ply:Team() != TEAM_UNDEAD and ply:GetZombieClassTable().Name == "Fresh Dead" then return end
	
	timer.Simple(3, function()
		if !IsValid(ply) then return end
		
		if GAMEMODE:GetWaveActive() and ply:Health() <= 0 then
			ply:RefreshDynamicSpawnPoint()
			ply:UnSpectateAndSpawn()
		end
		
		if !GAMEMODE:GetWaveActive() then
			ply:ChangeToCrow()
		end
	end)
end
hook.Add( "PlayerDeath","botDeath",botDeath)

function botDisconnect( ply )
	if !ply.IsZSBot then return end
	
	ply.FollowerEnt:Remove()
end
hook.Add( "PlayerDisconnected","botDisconnect",botDisconnect)

function botSpawn( ply )
	if !ply.IsZSBot then return end
	
	DoSpawnStuff( ply, true )
end
hook.Add("PlayerSpawn", "botSpawn", botSpawn)