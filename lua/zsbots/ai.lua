function controlBots ( bot, cmd )
	if !bot.IsZSBot2 then return end
	--print(bot.giveUpTimer)
	--==================== START FUNCTIONS ====================
	
	cmd:ClearMovement()
	cmd:ClearButtons()
	
	bot:DispositionCheck( cmd, bot.Pathfinder.TargetEnemy )
	bot:InputTimers()
	bot:InputCheck( cmd )
	
	CheckNavMeshAttributes( bot, cmd )
	--morale colour (0, 201, 201)
	
	bot:DoSpectateDebugUI()
	
	--==================== UNUSED STUFF THAT I MIGHT USE ====================
	
	--[[
	--====ABOVE PLAYER====
	debugoverlay.EntityTextAtPosition(self:EyePos(), -12, "Name: " .. self:Name(), 0, Color(255, 255, 255))
	debugoverlay.EntityTextAtPosition(self:EyePos(), -10, "Health: " .. self:Health(), 0, Color(255, 255, 0))
	if IsValid(self:GetActiveWeapon()) then
		debugoverlay.EntityTextAtPosition(self:EyePos(), -9, "Ammo: " .. self:GetActiveWeapon():Clip1() .. "/" .. self:GetAmmoCount(self:GetActiveWeapon():GetPrimaryAmmoType()) , 0, Color(255, 255, 0))
	end
	--====BESIDE PLAYER====
	debugoverlay.EntityTextAtPosition(self:EyePos(), -7, "Skill: " .. self.Skill .. "%", 0, Color(255, 255, 255))
	if IsValid(self.Pathfinder) then
		debugoverlay.EntityTextAtPosition(self:EyePos(), -6, "Task: " .. self.taskName, 0, Color(0, 255, 0))
	end
	debugoverlay.EntityTextAtPosition(self:EyePos(), -5, "Disposition: " .. self.dispositionName, 0, Color(0, 80, 255))
	debugoverlay.EntityTextAtPosition(self:EyePos(), -3, "Steady view: " .. "NO", 0, Color(255, 255, 0))
	debugoverlay.EntityTextAtPosition(self:EyePos(), -2, "Nearby friends: " .. self.nearbyFriends, 0, Color(0, 255, 0))
	debugoverlay.EntityTextAtPosition(self:EyePos(), -1, "Nearby enemies: " .. self.nearbyEnemies, 0, Color(255, 50, 50))
	debugoverlay.EntityTextAtPosition(self:EyePos(), 0, "Nav Area: " .. tostring(navmesh.GetNavArea( self:EyePos(), math.huge )), 0, Color(255, 255, 255))
	--=====================
	
	
	bot.tangoy = Angle ( 0, bot:EyeAngles().y, bot:EyeAngles().z)
	debugoverlay.Box( bot:GetPos() + Vector( bot.tangoy:Forward() ) * 25, Vector( -7.5, -7.5, bot:OBBMins().z + 7.5 ), Vector( 7.5, 7.5, bot:OBBMaxs().z - 7.5 ), 0, Color( 255, 255, 255 ) )
		
	if IsValid( bot.Pathfinder.TargetLootItem ) then
		if bot.Pathfinder.TargetLootItem:GetClass() == "prop_weapon" then
			print (bot.Pathfinder.TargetLootItem:GetWeaponType())
		else
			print (bot.Pathfinder.TargetLootItem)
		end
	end
	]]
	
	--==================== CONSOLE COMMAND CHECKS ====================
	
	if bot:Team() != TEAM_UNDEAD then
		if GetConVar( "zs_bot_muscular" ):GetInt() != 0 then
			bot.BuffMuscular = true
			bot:DoMuscularBones()
		end
		
		if GetConVar( "zs_bot_force_zombie" ):GetInt() != 0 and bot:Team() != TEAM_UNDEAD then
			bot:KillSilent()
			bot:SetTeam(TEAM_UNDEAD)
			bot:DoHulls(classId, TEAM_UNDEAD)
			
			if GAMEMODE:GetWave() != 0 and GAMEMODE:GetWaveActive() then
				bot:UnSpectateAndSpawn()
			end
		end
	end
	
	if GetConVar( "zs_bot_infinite_ammo" ):GetInt() != 0 and IsValid(bot:GetActiveWeapon()) then
		local wep = bot:GetActiveWeapon()
		
		if !wep.AmmoIfHas then
			if wep:GetPrimaryAmmoType() != -1 then
				bot:SetAmmo(9999, wep:GetPrimaryAmmoType())
			end
			if wep:GetSecondaryAmmoType() != -1 then
				bot:SetAmmo(9999, wep:GetSecondaryAmmoType())
			end
		end
	end
	
	--==================== SOME OTHER CHECKS ====================
	
	if IsValid (bot:GetActiveWeapon()) and bot:Team() != TEAM_UNDEAD then
		if bot:GetActiveWeapon():Clip1() <= 0 and !bot:GetActiveWeapon().IsMelee and bot:GetActiveWeapon():GetNextSecondaryFire() <= CurTime() - 0.05 then
			bot.reloadHold = true
		end
	end
	
	-- Switch weapons if got no ammo
	if bot.Task == GOTO_ARSENAL or bot.Task == WANDER_AROUND or bot.Task == DEFEND_CADE or bot.Task == FOLLOW then
		if bot:Team() != TEAM_UNDEAD and CurTime() > bot.targetFindDelay and bot.runAwayTimer <= 0 then
			
			local curWep = bot:GetActiveWeapon()
			local otherWep = bot:GetOtherWeapon(HAS_AMMO)
			
			if IsValid(curWep) then
				if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) and !curWep.IsMelee or curWep.IsMelee or curWep.Primary.Heal or curWep.AmmoIfHas then	
					if otherWep != nil then
						bot:SelectWeapon(otherWep)
					else
						for i, meleeWep in ipairs(bot:GetWeapons()) do 
							if meleeWep.IsMelee then
								bot:SelectWeapon(meleeWep)
								
								break
							end
						end
					end
				end
			else	
				if otherWep != nil then
					bot:SelectWeapon(otherWep)
				else
					for i, meleeWep in ipairs(bot:GetWeapons()) do 
						if meleeWep.IsMelee then
							bot:SelectWeapon(meleeWep)
							
							break
						end
					end
				end
			end
		end
	end
	
	if bot.runAwayTimer > 0 then
		bot.runAwayTimer = bot.runAwayTimer - FrameTime()
	end
	
	if bot.Attacking then
		local skillRotSpeed = math.Remap( bot.Skill, 0, 100, 5, 10 )
		bot.rotationSpeed = skillRotSpeed
	else
		bot.rotationSpeed = defaultRotationSpeed
	end
	
	if !bot:IsFrozen() then
		local lerpAngle = LerpAngle( bot.rotationSpeed * FrameTime( ), bot:EyeAngles(), bot.lookAngle )
		bot:SetEyeAngles( Angle( lerpAngle.x, lerpAngle.y, 0 ) )
		cmd:SetViewAngles( Angle( lerpAngle.x, lerpAngle.y, 0 ) )
	end
	
	if !IsValid( bot.Pathfinder ) then
		bot.Pathfinder = ents.Create( "sent_zsbot_pathfinder" )
		bot.Pathfinder:Spawn()
		bot.Pathfinder.Bot = bot
	end
	
	--==================== SETUP NAVIGATION ====================
	
	if bot.Pathfinder.P then
		bot.LastPath = bot.Pathfinder.P:GetAllSegments()
	end
	
	if bot.LastPath then
		local daPos = navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetClosestPointOnArea( bot:GetPos() )
		if bot.Pathfinder:GetPos() != daPos then
			bot.Pathfinder:SetPos( daPos )
		end
	else
		if bot.Pathfinder:GetPos() != bot:GetPos() then
			bot.Pathfinder:SetPos( bot:GetPos() )
		end
	end
	
	if !bot.LastPath then return end 
	
	local curgoal = bot.LastPath[bot.Pathfinder.CurSegment]
	if !curgoal then return end
	
	if bot:GetMoveType() == MOVETYPE_LADDER then
		if bot:GetPos():QuickDistanceCheck( curgoal.pos, SMALLER, 20 ) then
			if bot.LastPath[bot.Pathfinder.CurSegment + 1] != nil then
				bot.Pathfinder.CurSegment = bot.Pathfinder.CurSegment + 1
			end
		end
	else
		if Vector( bot:GetPos().x, bot:GetPos().y, 0 ):QuickDistanceCheck( Vector( curgoal.pos.x, curgoal.pos.y, 0 ), SMALLER, 20 ) then
			if bot.LastPath[bot.Pathfinder.CurSegment + 1] != nil then
				bot.Pathfinder.CurSegment = bot.Pathfinder.CurSegment + 1
			end
		end
	end
	
	--==================== TARGET FINDERS ====================
	
	if CurTime() > bot.targetFindDelay then
		--bot.nearbyFriends = CountNearbyFriends( bot, 3000 )
		--bot.nearbyEnemies = CountNearbyEnemies( bot, 3000 )
		
		if bot:Team() == TEAM_UNDEAD then
			--bot.attackProp = FindNearestProp2( bot )
			bot.Pathfinder.TargetPosition = FindNearestHidingSpot( bot )
			
			if ROUNDWINNER != bot:Team() then
				if bot.Task == HIDE_FROM_HUMANS then
					bot.Pathfinder.TargetEnemy = FindNearestEnemyInSight( "player", bot, false )
				elseif AnEnemyIsInSight("player", bot) then
					bot.Pathfinder.TargetEnemy = FindNearestEnemyInSight( "player", bot, false )
				else
					bot.Pathfinder.TargetEnemy = FindNearestEnemy( "player", bot )
				end
			else
				bot.Pathfinder.TargetEnemy = FindNearestTeammate( "player", bot )
			end
		else
			bot.Pathfinder.TargetEnemy = FindNearestEnemyInSight( "player", bot )
			bot.Pathfinder.TargetNailedProp = FindNearestNailedProp( bot )
			bot.Pathfinder.TargetCadingProp = FindNearestProp( bot )
			bot.Pathfinder.TargetLootItem = FindNearestLoot( bot )
			bot.Pathfinder.TargetArsenal = FindNearestEntity( "prop_arsenalcrate", bot )
			bot.Pathfinder.TargetResupply = FindNearestEntity( "prop_resupplybox", bot )
			
			if bot:HasWeapon ("weapon_zs_medicalkit") then
				bot.Pathfinder.TargetHealing = FindNearestHealTarget( "player", bot )
			end
			
			if bot.Task != 13 then
				bot.Pathfinder.TargetTeammate = FindNearestTeammate( "player", bot )
			else
				bot.Pathfinder.TargetTeammate = FindNearestPlayerTeammate( "player", bot )
			end
		end
	end
	
	--==================== FIND CADING SPOTS ====================
	
	if GetConVar( "zs_bot_debug_defending_spots" ):GetInt() == 1 then
		if IsValid(bot.Pathfinder.TargetArsenal) then
			if bot.Pathfinder.TargetArsenal.UnCheckableAreas != nil then
				for i, area in ipairs(bot.Pathfinder.TargetArsenal.UnCheckableAreas) do
					debugoverlay.Box(Vector (0,0,0), area:GetCorner( 0 ), area:GetCorner( 2 ), 0, Color( 255, 0, 0, 5 ) )
				end
				
				for s, spot in ipairs(bot.Pathfinder.TargetArsenal.DefendingSpots) do
					if bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
						debugoverlay.Box(Vector (0,0,0), navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 0 ), navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ), 0, Color( 0, 0, 255, 5 ) )
					end
				end
			end
		end
	end
	
	--==================== PRESET CHAT MESSAGES ====================
	
	if bot.prevSayMessage != bot.sayMessage then
		bot:Say (bot.sayMessage)
		bot.prevSayMessage = bot.sayMessage
	end
	
	if bot.prevSayTeamMessage != bot.sayTeamMessage then
		bot:Say (bot.sayTeamMessage, true)
		bot.prevSayTeamMessage = bot.sayTeamMessage
	end
	
	
	if bot:Team() != TEAM_UNDEAD and bot.Skill > 25 and GetConVar( "zs_bot_can_chat" ):GetInt() != 0 then
		if bot:Health() <= (2 / 4 * bot:GetMaxHealth()) then
			SayPresetMessage(bot, MSG_MEDIC, true)
		elseif bot.prevSay == 0 then
			bot.prevSay = -1
		end
		
		--[[if IsValid (bot.Pathfinder.TargetEnemy) then
			if bot.Pathfinder.TargetEnemy:Team() == TEAM_UNDEAD then
				if bot.Pathfinder.TargetEnemy:GetZombieClassTable().Boss and bot.prevSay == -1 then
					SayPresetMessage(bot, MSG_BOSS_OUTSIDE, true)
				end
			end
		end]]
	end
	
	--==================== BOT HEALING DETECTION ====================
	
	--if bot:HasWeapon ("weapon_zs_medicalkit") and bot:Health() <= 70 then
		--cmd:SetButtons(IN_ATTACK2)
	--end
	
	if IsValid (bot.Pathfinder.TargetHealing) and bot:HasWeapon("weapon_zs_medicalkit") and bot.Task != HEAL_TEAMMATE then
		local medWeapon = bot:GetWeapon("weapon_zs_medicalkit")
		local medCooldown = medWeapon:GetNextCharge() - CurTime()
		
		if --[[bot.Pathfinder.TargetTeammate:Health() <= (3 / 4 * bot.Pathfinder.TargetTeammate:GetMaxHealth()) and]] bot:Health() > (2 / 4 * bot:GetMaxHealth()) and medCooldown <= 0 and medWeapon:GetPrimaryAmmoCount() > 0 then
			bot:SetTask( HEAL_TEAMMATE )
		end
	end
	
	--==================== BOT TASKS ====================
	
	--Task 1
	--Humans: Go to arsenal
	--Zombies: Go to humans
	
	if bot.Task == GOTO_ARSENAL then
		if bot:Team() != TEAM_UNDEAD then
			if game.IsObj() or GAMEMODE.ZombieEscape then bot:SetTask( FOLLOW ) end
			if ROUNDWINNER == bot:Team() then bot:SetTask( WANDER_AROUND ) end
			
			if !game.IsObj() and !GAMEMODE.ZombieEscape and ROUNDWINNER != bot:Team() then
				local myTarget = bot.Pathfinder.TargetArsenal
				
				if IsValid (bot.Pathfinder.TargetEnemy) then
					if bot:GetActiveWeapon().IsMelee and bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" and bot:Health() > (2 / 4 * bot:GetMaxHealth()) then
						local meleeTrace = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:AimPoint( bot.Pathfinder.TargetEnemy ),
							mask = MASK_SHOT,
							filter = function( ent ) if ( ent != bot.Pathfinder.TargetEnemy and ent != bot and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
						} )
						
						if !meleeTrace.Hit and bot.runAwayTimer <= 0 and !IsValid(bot:GetOtherWeapon(HAS_AMMO)) then
							bot:SetTask( MELEE_ZOMBIE )
						end
					end
				end
				
				bot:LootCheck()
			
				if IsValid (myTarget) then
					local atr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = myTarget:LocalToWorld(myTarget:OBBCenter()),
						filter = function( ent ) if ( ent:IsWorld() ) then return true end end
					} )
					
					if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 100 ) or atr.Hit or bot:GetBarricadeGhosting() then
						if bot:GetMoveType() == MOVETYPE_LADDER then
							
							bot:DoLadderMovement( cmd, curgoal )
					
						else
							
							
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
							
							if bot:Health() > (3 / 4 * bot:GetMaxHealth()) and bot.runAwayTimer <= 0 then
								bot.Disposition = ENGAGE_AND_INVESTIGATE
							else
								bot.Disposition = IGNORE_ENEMIES
							end
							
							bot:RunAwayCheck( cmd )
						end
					elseif !atr.Hit and !bot:GetBarricadeGhosting() then
						bot.moveType = -1
						bot.Disposition = OPPORTUNITY_FIRE
						
						if IsValid( bot:GetActiveWeapon() ) then
							--print (bot.Pathfinder.TargetCadingSpot)
							if !bot:GetActiveWeapon().IsMelee and bot.Pathfinder.TargetArsenal.DefendingSpots != nil and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
								bot.guardTimer = bot.guardTimer - FrameTime()
								--print (bot.guardTimer)
						
								if bot.guardTimer <= 0 then
									bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
									bot.guardTimer = math.random( 5, 10 )
									bot:LookatPosXY( cmd, bot.Pathfinder.TargetCadingSpot )
									
									bot:SetTask( DEFEND_CADE )
								end
							end
						end
						
						
						if CurTime() > bot.targetFindDelay and GetConVar( "zs_bot_can_place_deployables" ):GetInt() != 0 then
							if bot:HasWeapon("weapon_zs_resupplybox") then
								bot:SelectWeapon(bot:GetWeapon("weapon_zs_resupplybox"))
								bot:SetTask( PLACE_DEPLOYABLE )
							elseif bot:HasWeapon("weapon_zs_messagebeacon") then
								bot:SelectWeapon(bot:GetWeapon("weapon_zs_messagebeacon"))
								bot:SetTask( PLACE_DEPLOYABLE )
							elseif bot:HasWeapon("weapon_zs_gunturret") then
								if IsValid(bot.Pathfinder.TargetArsenal) and bot.Pathfinder.TargetArsenal.DefendingSpots != nil and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
									bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
									bot:LookatPosXY( cmd, bot.Pathfinder.TargetCadingSpot )
									
									bot:SelectWeapon(bot:GetWeapon("weapon_zs_gunturret"))
									bot:SetTask( PLACE_DEPLOYABLE )
								end
							elseif bot:HasWeapon("weapon_zs_ffemitter") then
								if IsValid(bot.Pathfinder.TargetArsenal) and bot.Pathfinder.TargetArsenal.DefendingSpots != nil and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
									bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
									bot:LookatPosXY( cmd, bot.Pathfinder.TargetCadingSpot )
									
									bot:SelectWeapon(bot:GetWeapon("weapon_zs_ffemitter"))
									bot:SetTask( PLACE_DEPLOYABLE )
								end
							elseif bot:HasWeapon("weapon_zs_spotlamp") then
								if IsValid(bot.Pathfinder.TargetArsenal) and bot.Pathfinder.TargetArsenal.DefendingSpots != nil and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
									bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
									bot:LookatPosXY( cmd, bot.Pathfinder.TargetCadingSpot )
									
									bot:SelectWeapon(bot:GetWeapon("weapon_zs_spotlamp"))
									bot:SetTask( PLACE_DEPLOYABLE )
								end
							end
						end
						
						
						if IsValid( bot:GetActiveWeapon()) and IsValid(bot.Pathfinder.TargetResupply) and CurTime() > bot.targetFindDelay then
							local curWep = bot:GetActiveWeapon()
							local otherWep = bot:GetOtherWeapon(HAS_NO_AMMO)
							
							if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) <= 0 and curWep:GetPrimaryAmmoType() != -1 and !curWep.IsMelee then
								if otherWep == nil then
									bot:SetTask( RESUPPLY_AMMO )
								end
							end
							
							if curWep.IsMelee then
								if otherWep != nil then
									bot:SelectWeapon(otherWep)
									bot:SetTask( RESUPPLY_AMMO )
								end
							end
						end
							
						if GetConVar( "zs_bot_can_cade" ):GetInt() != 0 and IsValid(bot.Pathfinder.TargetArsenal) then
							if IsValid (bot.Pathfinder.TargetCadingProp) and bot.BuffMuscular and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
								if bot:HasWeapon("weapon_zs_hammer") then
									bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
									bot:SetTask( PICKUP_CADING_PROP )
								end	
							end
						end
						if IsValid (bot.Pathfinder.TargetNailedProp) and !bot.BuffMuscular then
							if bot:HasWeapon("weapon_zs_hammer") and bot:Health() > (1.5 / 4 * bot:GetMaxHealth()) then
								bot:SetTask( REPAIR_CADE )
							end	
						end
						
						if bot:Health() > (3 / 4 * bot:GetMaxHealth()) and !GAMEMODE:GetWaveActive() and GAMEMODE:GetWave() != 0 and GAMEMODE:GetWaveStart() - 20 > CurTime() and bot.shouldGoOutside then
							bot.Pathfinder.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 500, 10, 10)
							bot:SetTask( WANDER_AROUND )
						end
					end
					
					bot:CheckPropPhasing()
					
					--debugoverlay.Box( bot:GetPos(), Vector( -18, -18, 0 ), Vector( 18, 18, 73 ), 0, Color( 255, 255, 255 ), false )
					
				else--if GAMEMODE:GetWave() != 0 then
					bot.Pathfinder.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 1000, 10, 10)
					bot:SetTask( WANDER_AROUND )
				end
			end
			
		elseif IsValid( bot.Pathfinder.TargetEnemy ) then
			local myTarget = bot.Pathfinder.TargetEnemy
			
			if bot:GetZombieClassTable().Name != "Crow" then
				
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = bot:AimPoint( bot.Pathfinder.TargetEnemy ),
					filter = function( ent ) if ( ent != myTarget and ent != bot and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
				} )
				
				if !GAMEMODE:GetWaveActive() then
					if tr.Hit and bot.Pathfinder.TargetPosition != nil and ROUNDWINNER != bot:Team() then
						bot:SetTask( HIDE_FROM_HUMANS )
					end
				end
				
				local stoppingDistance = 0
				local attackDistance = 0
				
				if bot:GetZombieClassTable().Name != "Fast Zombie" and bot:GetZombieClassTable().Name != "Wraith" then
					stoppingDistance = 45 -- was 65
					attackDistance = 150
				end
				if bot:GetZombieClassTable().Name == "Fast Zombie" or bot:GetZombieClassTable().Name == "Wraith" then
					stoppingDistance = 45
					attackDistance = 45
				end
				
				if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, stoppingDistance ) then
					if bot.lookPos == nil then
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
					else
						bot.moveType = -1
					end
			
					if bot:GetMoveType() == MOVETYPE_LADDER then
				
						bot:DoLadderMovement( cmd, curgoal )	
				
					else
						
					end
				else
					bot.moveType = -1
				
					bot:SetLookAt(bot:AimPoint( bot.Pathfinder.TargetEnemy ))
				end
				
				if !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
				
					if GetConVar( "zs_bot_debug_attack" ):GetInt() == 1 then debugoverlay.Box( bot:EyePos() + bot:EyeAngles():Forward() * 35, Vector(-25, -25, -25), Vector(25, 25, 25), 0, Color( 255, 255, 255, 0 ) ) end
					
					local atr = util.TraceHull( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + bot:EyeAngles():Forward() * 35,
						mins = Vector(-25, -25, -25),
						maxs = Vector(25, 25, 25),
						ignoreworld = true,
						filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") or ent:GetClass() == "func_door_rotating" ) then return true end end
					} )
					
					if IsValid(atr.Entity) then
						bot.attackTimer = true
					end
				end
			
				if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), SMALLER, attackDistance ) and !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
					bot.attackTimer = true
				end
				
				if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER_OR_EQUAL, 45 ) and bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), SMALLER, 400 ) and !tr.Hit and !bot.jumpHold and !bot.useHold and bot:GetMoveType() != MOVETYPE_LADDER then
					if bot:GetZombieClassTable().Name == "Fast Zombie" then
						local aimPoint = bot:AimPoint( bot.Pathfinder.TargetEnemy )
						
						bot:SetLookAt(Vector(aimPoint.x, aimPoint.y, aimPoint.z + (bot:GetPos():Distance( myTarget:GetPos()) / 4 )))
						bot.attack2Timer = true
					else
						bot:SetLookAt(bot:AimPoint( bot.Pathfinder.TargetEnemy ))
					end
				end
				
				--if bot:GetPos():QuickDistanceCheck( bot.lookProp:GetPos(), SMALLER, 150 ) then
				
				local mr = 0
				
				if IsValid( bot:GetActiveWeapon() ) then
					if bot:GetActiveWeapon().MeleeReach != nil then
						mr = bot:GetActiveWeapon().MeleeReach
					else
						mr = 65
					end
					
					if bot:GetActiveWeapon().MeleeRange != nil then
						mr = bot:GetActiveWeapon().MeleeRange
					else
						mr = 65
					end
				else
					mr = 65
				end
			
				mr = mr - 10
			
				if mr < 0 then mr = 0 end
				
				local direction
				if bot:GetMoveType() != MOVETYPE_LADDER then
					direction = bot:EyeAngles()
				else
					direction = Angle(-90, bot:EyeAngles().y, bot:EyeAngles().z)
				end
				
				if bot.lookPos != nil then
					bot.moveType = -1
					
					bot:SetLookAt(bot.lookPos)
			
					bot.attackTimer = true
					
					if IsValid(bot.lookProp) then
						if string.find(bot.lookProp:GetClass(), "prop_physics") then
							if bot:EyePos():QuickDistanceCheck( bot.lookPos, BIGGER, (mr + 10) ) or !bot.lookProp:IsNailed() then
								bot.lookPos = nil
							end
						end
						if string.find(bot.lookProp:GetClass(), "func_breakable") then
							if bot:EyePos():QuickDistanceCheck( bot.lookPos, BIGGER, (mr + 10) ) then
								bot.lookPos = nil
							end
						end
					else
						bot.lookPos = nil
					end
				else
					local tr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + direction:Forward() * mr,
						filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") ) then return true end end
					} )
					
					if IsValid(tr.Entity) then
						if tr.Entity:IsNailed() or string.find(tr.Entity:GetClass(), "func_breakable") then
							bot.lookPos = tr.HitPos
							bot.lookProp = tr.Entity
						end
					end
					
					local tr2 = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + Angle(direction.x - 25, direction.y, direction.z):Forward() * mr,
						filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") ) then return true end end
					} )
					
					if IsValid(tr2.Entity) then
						if tr2.Entity:IsNailed() or string.find(tr2.Entity:GetClass(), "func_breakable") then
							bot.lookPos = tr2.HitPos
							bot.lookProp = tr2.Entity
						end
					end
					
					local tr3 = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + Angle(direction.x + 25, direction.y, direction.z):Forward() * mr,
						filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") ) then return true end end
					} )
					
					if IsValid(tr3.Entity) then
						if tr3.Entity:IsNailed() or string.find(tr3.Entity:GetClass(), "func_breakable") then
							bot.lookPos = tr3.HitPos
							bot.lookProp = tr3.Entity
						end
					end
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
						local ladtr1 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:EyePos() + Angle(direction.x - 25, direction.y, direction.z):Forward() * mr,
							filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") ) then return true end end
						} )
						
						if IsValid(ladtr1.Entity) then
							if ladtr1.Entity:IsNailed() or string.find(ladtr1.Entity:GetClass(), "func_breakable") then
								bot.lookPos = ladtr1.HitPos
								bot.lookProp = ladtr1.Entity
							end
						end
						
						local ladtr2 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:EyePos() + Angle(direction.x + 25, direction.y, direction.z):Forward() * mr,
							filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") ) then return true end end
						} )
						
						if IsValid(ladtr2.Entity) then
							if ladtr2.Entity:IsNailed() or string.find(ladtr2.Entity:GetClass(), "func_breakable") then
								bot.lookPos = ladtr2.HitPos
								bot.lookProp = ladtr2.Entity
							end
						end
					end
				end
				
				if IsValid (bot:GetActiveWeapon()) then
					if bot:GetActiveWeapon().MeleeReach != nil and GetConVar( "zs_bot_debug_attack" ):GetInt() == 1 then
						debugoverlay.Line( bot:EyePos(), bot:EyePos() + direction:Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
						debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(direction.x - 25, direction.y, direction.z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
						debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(direction.x + 25, direction.y, direction.z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
						
						if bot:GetMoveType() == MOVETYPE_LADDER then
							debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(direction.x - 25, direction.y - 90, direction.z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
							debugoverlay.Line( bot:EyePos(), bot:EyePos() + Angle(direction.x + 25, direction.y - 90, direction.z):Forward() * bot:GetActiveWeapon().MeleeReach , 0, Color( 255, 255, 255 ), false )
						end
					end
				end
			end
		else
			
			bot.moveType = -1
		end
		
		if bot:GetZombieClassTable().Name == "Crow" then
			bot.moveType = -1
		end
	
	--Task 2
	--Humans: Hit zombies with melee weapon
	--Zombies: Go to hiding spot
	elseif bot.Task == MELEE_ZOMBIE then
		if bot:Team() != TEAM_UNDEAD then
			--[[if bot:GetPos():QuickDistanceCheck( bot.Pathfinder.TargetEnemy:GetPos(), BIGGER, 500 ) then
				cmd:SetForwardMove( 1000 )
				
				if bot:GetMoveType() == MOVETYPE_LADDER then
				
					bot:DoLadderMovement( cmd, curgoal )
					
				else
					CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
				end
			elseif bot:GetPos():QuickDistanceCheck( bot.Pathfinder.TargetEnemy:GetPos(), BIGGER, 250 ) then 
				bot.moveType = -1
				
				bot:SetLookAt(bot:AimPoint( bot.Pathfinder.TargetEnemy ))
				
				bot.attackTimer = true
			else
				bot.moveType = 4
				
				bot:SetLookAt(bot:AimPoint( bot.Pathfinder.TargetEnemy ))
				
				bot.attackTimer = true
			end]]
			
			local myTarget = bot.Pathfinder.TargetEnemy
			bot.Disposition = IGNORE_ENEMIES
			
			if !IsValid (myTarget) or myTarget:Health() <= 0 or bot:Health() <= (2 / 4 * bot:GetMaxHealth()) or !bot:GetActiveWeapon().IsMelee or bot:GetActiveWeapon():GetClass() == "weapon_zs_hammer" then
				bot.crouchHold = false
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == MELEE_ZOMBIE then
				if bot:GetMoveType() == MOVETYPE_LADDER then
				
					bot:DoLadderMovement( cmd, curgoal )	
		
				else
					if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 150 ) then -- was 45
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
						
					elseif bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 45 ) then
						bot.attackTimer = true
						bot.crouchHold = false
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
					else
						bot.attackTimer = true
						bot.crouchHold = true
						
						bot.moveType = -1
					end
					
					if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), SMALLER, 400 ) then
						bot:SetLookAt(bot:AimPoint( bot.Pathfinder.TargetEnemy ))
					end
				end
			end
		
		elseif bot:GetZombieClassTable().Name != "Crow" then
			local myTarget = bot.Pathfinder.TargetPosition
			
			if GAMEMODE:GetWaveActive() or myTarget == nil or ROUNDWINNER == bot:Team() then
				bot:SetTask( GOTO_HUMANS )
			end
			
			if IsValid( bot.Pathfinder.TargetEnemy ) then 
				local tr = util.TraceLine( {
					start = bot:EyePos(),
					endpos = bot:AimPoint( bot.Pathfinder.TargetEnemy ),
					filter = function( ent ) if ( ent != bot.Pathfinder.TargetEnemy and ent != bot and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
				} )
				
				if !tr.Hit then
					bot:SetTask( GOTO_HUMANS )
				end
			end
			
			if myTarget != nil then
				if bot:GetPos():QuickDistanceCheck( myTarget, BIGGER, 45 ) then		
					if bot:GetMoveType() == MOVETYPE_LADDER then
						
						bot:DoLadderMovement( cmd, curgoal )	
						
					else
						
						
						CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
					end
				else
					bot.moveType = -1
					
					bot.lookAngle.y = ( bot:GetPos() - myTarget ):GetNormal():Angle().y
				end
			end
		end
	
	--Task 3
	--Humans: Go to teammate and heal them
	--Zombies: (Shade) Pickup props and throw them at humans
	elseif bot.Task == HEAL_TEAMMATE then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetHealing
			bot.Disposition = SELF_DEFENSE
			
			if bot:HasWeapon("weapon_zs_medicalkit") then
				cmd:SelectWeapon (bot:GetWeapon("weapon_zs_medicalkit"))
				
				local medWep = bot:GetWeapon("weapon_zs_medicalkit")
				local medCooldown = (medWep:GetNextCharge() - CurTime())
				
				if !IsValid( myTarget ) or !IsValid( bot.Pathfinder.TargetTeammate ) or bot:Health() <= (2 / 4 * bot:GetMaxHealth()) or medCooldown > 0 or medWep:GetPrimaryAmmoCount() <= 0 then 
					bot:SetTask( GOTO_ARSENAL )
				end
				
				if bot.Task == HEAL_TEAMMATE then
					--[[if myTarget:Health() > (3 / 4 * myTarget:GetMaxHealth()) then --or bot:GetActiveWeapon():GetClass() != "weapon_zs_medicalkit"
						bot:SetTask( GOTO_ARSENAL )
					end]]
					
					local atr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = myTarget:LocalToWorld(myTarget:OBBCenter()),
						filter = function( ent ) if ( ent:IsWorld() ) then return true end end
					} )
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						bot:DoLadderMovement( cmd, curgoal )
				
					else
						bot:SetLookAt(myTarget:EyePos())
							
						if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 45 ) or atr.Hit or bot:GetBarricadeGhosting() then
							CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						elseif !atr.Hit and !bot:GetBarricadeGhosting() then
							bot.moveType = -1
						
							bot.attackTimer = true
						end
					end
				end
				
				bot:CheckPropPhasing()
			else

				bot:SetTask( GOTO_ARSENAL )
			end
		else
			--Put Shade AI here
		end
	
	
	--Task 4
	--Humans: Place deployable
	--Zombies: ...
	elseif bot.Task == PLACE_DEPLOYABLE then
		if bot:Team() != TEAM_UNDEAD then
			bot.Disposition = SELF_DEFENSE
			
			if !IsValid(bot.Pathfinder.TargetArsenal) or !IsValid( bot:GetActiveWeapon() ) then
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == PLACE_DEPLOYABLE then
				local curWep = bot:GetActiveWeapon()
				
				if curWep:GetClass() == "weapon_zs_resupplybox" or curWep:GetClass() == "weapon_zs_messagebeacon" then
					bot.moveType = -1
					bot.attackTimer = true
					bot.deployTimer = true
				end
				
				if curWep:GetClass() == "weapon_zs_gunturret" or curWep:GetClass() == "weapon_zs_ffemitter" or curWep:GetClass() == "weapon_zs_spotlamp" then
					
					if bot.Pathfinder.TargetArsenal.DefendingSpots == nil or bot.Pathfinder.TargetArsenal.DefendingSpots[1] == nil then
						bot:SetTask( GOTO_ARSENAL )
					end
					
					if bot.Task == PLACE_DEPLOYABLE then
						if bot:GetPos():QuickDistanceCheck( bot.Pathfinder.TargetCadingSpot, BIGGER, 125 ) then
							bot:LookatPosXY( cmd, bot.Pathfinder.TargetCadingSpot )
							CloseToPointCheck (bot, curgoal.pos, bot.Pathfinder.TargetCadingSpot, cmd, false)					
						else
							local theAng = (bot.Pathfinder.TargetCadingSpot - bot:GetPos()):Angle()
							bot.lookAngle = Angle(bot.lookAngle.x, theAng.y, 0)
							
							bot.moveType = -1
							bot.attackTimer = true
							bot.deployTimer = true
						end
					end
				end
			end
		end
	
	
	--Task 5
	--Humans: Wander around
	--Zombies: ...
	elseif bot.Task == WANDER_AROUND then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetPosition
			
			if IsValid (bot.Pathfinder.TargetArsenal) and ROUNDWINNER != bot:Team() then
				if bot:Health() <= (3 / 4 * bot:GetMaxHealth()) or GAMEMODE:GetWaveActive() or GAMEMODE:GetWaveStart() - 15 <= CurTime() or GAMEMODE:GetWave() == 0 then
					bot.newPointTimer = 15
					bot:SetTask( GOTO_ARSENAL )
				end
			end
			
			bot.newPointTimer = bot.newPointTimer - FrameTime()
			
			if bot:GetMoveType() == MOVETYPE_LADDER then
			
				bot:DoLadderMovement( cmd, curgoal )
				
			else
				
				
				CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
				
				if bot.runAwayTimer <= 0 then
					if bot:Health() > (3 / 4 * bot:GetMaxHealth()) then
						bot.Disposition = ENGAGE_AND_INVESTIGATE
					else
						bot.Disposition = IGNORE_ENEMIES
					end
				end
				
				bot:LootCheck()
				
				if Vector( bot:GetPos().x, bot:GetPos().y, 0 ):QuickDistanceCheck( Vector( myTarget.x, myTarget.y, 0 ), SMALLER, 20 ) or bot.newPointTimer <= 0 then
					bot.Pathfinder.TargetPosition = GetRandomPositionOnNavmesh(bot:GetPos(), 1000, 10, 10)
					bot.Pathfinder:NavCheck()
					
					if bot.newPointTimer <= 0 and GetConVar( "zs_bot_debug_path" ):GetInt() != 0 then 
						print(bot:Name() .. " took too long to get to wander point, going to new one.") 
						bot:EmitSound( "buttons/button11.wav", 75, 100, 1, CHAN_AUTO )
					end
					
					bot.newPointTimer = 15
				end
				
				if IsValid (bot.Pathfinder.TargetEnemy) then
					local tr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:AimPoint( bot.Pathfinder.TargetEnemy ),
						mask = MASK_SHOT,
						filter = function( ent ) if ( ent != bot.Pathfinder.TargetEnemy and ent != bot and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
					} )
					
					if bot:GetActiveWeapon().IsMelee and bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" and bot:Health() > (2 / 4 * bot:GetMaxHealth()) then					
						if !tr.Hit and bot.runAwayTimer <= 0 and !IsValid(bot:GetOtherWeapon(HAS_AMMO)) then
							bot:SetTask( MELEE_ZOMBIE )
						end
					end
				end
			end
			
			
			bot:RunAwayCheck( cmd )
			bot:CheckPropPhasing()
		end
	
	--Task 6
	--Humans: Repair cades
	--Zombies: ...
	elseif bot.Task == REPAIR_CADE then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetNailedProp
			bot.Disposition = IGNORE_ENEMIES
			
			if !IsValid( myTarget ) or bot:Health() <= (1.5 / 4 * bot:GetMaxHealth()) or !bot:HasWeapon("weapon_zs_hammer") then
				bot.lookPos = nil
				bot.lookProp = nil
				bot:SetTask( GOTO_ARSENAL )
			end
					
			if bot.Task == REPAIR_CADE then
				
				cmd:SelectWeapon (bot:GetWeapon("weapon_zs_hammer"))
				
				if IsValid (bot:GetActiveWeapon()) and GetConVar( "zs_bot_debug_attack" ):GetInt() == 1 then
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
					
					if bot:GetActiveWeapon().MeleeRange != nil then
						mr = bot:GetActiveWeapon().MeleeRange
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
			
					bot:SetLookAt(bot.lookPos)
				
					bot.attackTimer = true
					
					if bot:EyePos():QuickDistanceCheck( bot.lookPos, BIGGER, (mr + 10) ) or !IsValid(bot.lookProp) or !bot.lookProp:IsNailed() or bot.lookProp != myTarget then
						bot.lookPos = nil
					end
				else
					CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
					
					bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
					
					local tr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = bot:EyePos() + bot:EyeAngles():Forward() * mr,
						filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") ) then return true end end
					} )
					
					if tr.Entity == myTarget then
						bot.lookPos = tr.HitPos
						bot.lookProp = tr.Entity
					else
						local tr2 = util.TraceLine( {
							start = bot:EyePos(),
							endpos = bot:EyePos() + Angle(bot:EyeAngles().x - 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
							filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") ) then return true end end
						} )
		
						if tr2.Entity == myTarget then
							bot.lookPos = tr2.HitPos
							bot.lookProp = tr2.Entity
						else
							local tr3 = util.TraceLine( {
								start = bot:EyePos(),
								endpos = bot:EyePos() + Angle(bot:EyeAngles().x + 25, bot:EyeAngles().y, bot:EyeAngles().z):Forward() * mr,
								filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") ) then return true end end
							} )
		
							if tr3.Entity == myTarget then
								bot.lookPos = tr3.HitPos
								bot.lookProp = tr3.Entity
							end
						end
					end
				end
			end
		end
	
	--Task 7
	--Humans: Pick up prop for cading
	--Zombies: ...
	elseif bot.Task == PICKUP_CADING_PROP then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetCadingProp
			bot.Disposition = IGNORE_ENEMIES
			
			if !IsValid(myTarget) then
				bot.useTimer = false
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == PICKUP_CADING_PROP then
				
				if bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" then
					cmd:SelectWeapon (bot:GetWeapon("weapon_zs_hammer"))
				end
				
				bot.crouchHold = true
				
				if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 50 ) then
		
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						bot:DoLadderMovement( cmd, curgoal )
					
					else
						
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
					end
			
				else
					bot.moveType = -1
					
					bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
					bot.useTimer = true
				end
				
				bot:CheckPropPhasing()
				
				if myTarget:GetHolder() == bot then
					bot.heldProp = myTarget
					bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
					bot:SetTask( MAKE_CADE )
				end
			end
		end
	
	
	--Task 8
	--Humans: Cade at cading spots
	--Zombies: ...
	elseif bot.Task == MAKE_CADE then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetCadingSpot
			bot.Disposition = IGNORE_ENEMIES
			
			if !IsValid(bot.heldProp) or myTarget == nil then
				bot.sprintHold = false
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == MAKE_CADE then
				myTarget = bot.Pathfinder.TargetCadingSpot
				
				local oof = bot:GetPos()
				
				if bot.heldProp:GetHolder() == bot then
					oof = bot.heldProp:GetPos()
				end
				
				bot.crouchHold = false
				
				if oof:QuickDistanceCheck( myTarget, BIGGER, 75 ) then
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
					
						bot:DoLadderMovement( cmd, curgoal )
					
					else
						bot:LookatPosXY( cmd, myTarget )
						CloseToPointCheck (bot, curgoal.pos, myTarget, cmd, false)
						
						--bot.heldProp:SetAngles(Angle(0,0,0))
						
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
					if tr.StartPos:QuickDistanceCheck( tr.HitPos, SMALLER_OR_EQUAL, 7.5 ) then
						bot.sprintHold = true
					end
					bot.attack2Timer = true
					--bot:SetLookAt(myTarget)
					bot.lookAngle = Angle(bot.lookAngle.x + 0.5, (myTarget - bot:EyePos()):Angle().y, bot.lookAngle.z)
					--bot:SetTask( GOTO_ARSENAL )
					if bot.lookAngle.x >= 89 then 
						--bot.heldProp = nil
						
						bot.sprintHold = false
						bot:SetTask( GOTO_ARSENAL ) 
					end
					
					if bot.heldProp:IsNailed() then
						--bot.heldProp = nil
						
						bot.sprintHold = false
						bot:SetTask( GOTO_ARSENAL )
					end
				end
			end
		end
	
	
	--Task 9
	--Humans: Get ammo from resupply box / pack resupply box
	--Zombies: ...
	elseif bot.Task == RESUPPLY_AMMO then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetResupply
			bot.Disposition = IGNORE_ENEMIES
			
			if !IsValid(myTarget) then
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == RESUPPLY_AMMO then
				if bot:GetMoveType() == MOVETYPE_LADDER then
					
					bot:DoLadderMovement( cmd, curgoal )
					
				else
					
					if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 75 ) then
							
						bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
					else
						bot.moveType = -1
						
						bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
						bot.useTimer = true
						bot:SetTask( GOTO_ARSENAL )
					end
				end
				
				bot:CheckPropPhasing()
			end
		end
	
	
	--Task 10
	--Humans: Pick up loot
	--Zombies: ...
	elseif bot.Task == PICKUP_LOOT then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetLootItem
			bot.Disposition = SELF_DEFENSE
			
			if bot.giveUpTimer > 0 then bot.giveUpTimer = bot.giveUpTimer - FrameTime() end
			
			if bot.giveUpTimer <= 0 then
				bot.moveType = -1
				bot.crouchHold = false
				bot.giveUpTimer = math.Rand(10, 15)
				
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if GetConVar( "zs_bot_can_pick_up_loot" ):GetInt() == 0 or !IsValid(myTarget) or IsValid(bot.Pathfinder.TargetEnemy) then
				bot.moveType = -1
				bot.crouchHold = false
				bot.giveUpTimer = 0
				
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == PICKUP_LOOT then
			
				if bot:GetMoveType() == MOVETYPE_LADDER then
						
					bot:DoLadderMovement( cmd, curgoal )
				
				else
					
					if IsValid(bot.Pathfinder.TargetEnemy) then
						bot.moveType = -1
						bot.crouchHold = false
						bot:SetTask( GOTO_ARSENAL )
					end
					
					if bot:GetPos():QuickDistanceCheck( myTarget:LocalToWorld(myTarget:OBBCenter()), BIGGER, 250 ) then
									
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						
						bot:SetLookAt(myTarget:EyePos())
							
					elseif bot:GetPos():QuickDistanceCheck( myTarget:LocalToWorld(myTarget:OBBCenter()), BIGGER, 30 ) then
						
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd, false)
						bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
						
						bot.crouchHold = true
						bot.useTimer = true
					else
						bot.moveType = -1
						
						bot:SetLookAt(myTarget:LocalToWorld(myTarget:OBBCenter()))
						
						bot.useTimer = true
						bot.crouchHold = true
					end
				end
			end
			
			bot:CheckPropPhasing()
		end
	
	
	--Task 11
	--Humans: Defend at defending spot
	--Zombies: ...
	elseif bot.Task == DEFEND_CADE then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetCadingSpot
			bot.Disposition = OPPORTUNITY_FIRE
			
			if !IsValid(bot.Pathfinder.TargetArsenal) then
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if IsValid (bot.Pathfinder.TargetArsenal) then
				if bot.Pathfinder.TargetArsenal.DefendingSpots == nil or bot.Pathfinder.TargetArsenal.DefendingSpots[1] == nil then
					bot:SetTask( GOTO_ARSENAL )
				end
			else
				bot:SetTask( GOTO_ARSENAL )
			end
			
			if bot.Task == DEFEND_CADE then
				if bot.Pathfinder.TargetArsenal.DefendingSpots != nil and bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
					
					bot.guardTimer = bot.guardTimer - FrameTime()
					--print (bot.guardTimer)
					
					if bot.guardTimer <= 0 then
						if math.random(0, 1) == 0 then
							bot:SetTask( GOTO_ARSENAL )
							
							bot.guardTimer = math.random( 5, 10 )
						else
							bot.Pathfinder.TargetCadingSpot = table.Random(bot.Pathfinder.TargetArsenal.DefendingSpots)
							bot.Pathfinder:NavCheck()
							
							bot.guardTimer = math.random( 5, 10 )					
						end
					end
					
					
					if bot:GetMoveType() == MOVETYPE_LADDER then
						
						bot:DoLadderMovement( cmd, curgoal )
						
					else
						if bot:GetPos():QuickDistanceCheck( myTarget, BIGGER, 125 ) then
							bot:LookatPosXY( cmd, myTarget )
							CloseToPointCheck (bot, curgoal.pos, myTarget, cmd, false)					
						else
							bot.moveType = -1
						end
						
						if IsValid( bot:GetActiveWeapon()) and IsValid(bot.Pathfinder.TargetResupply) and CurTime() > bot.targetFindDelay then
							local curWep = bot:GetActiveWeapon()
							local otherWep = bot:GetOtherWeapon(HAS_NO_AMMO)
							
							if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) <= 0 and curWep:GetPrimaryAmmoType() != -1 and !curWep.IsMelee then
								if otherWep == nil then
									bot:SetTask( RESUPPLY_AMMO )
								end
							end
							
							if curWep.IsMelee then
								if otherWep != nil then
									bot:SelectWeapon(otherWep)
									bot:SetTask( RESUPPLY_AMMO )
								end
							end
						end
					end
				end
			end
		end
	
	
	--Task 12
	--Humans: Snipe zombies
	--Zombies: ...
	elseif bot.Task == SNIPING then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetPosition
			
			bot.lookDistance = 10000
			if bot:GetPos():QuickDistanceCheck( myTarget, BIGGER, 50 ) then
				if bot:GetMoveType() == MOVETYPE_LADDER then
					
					bot:DoLadderMovement( cmd, curgoal )
			
				else
					
					
					bot.Disposition = IGNORE_ENEMIES
					CloseToPointCheck (bot, curgoal.pos, myTarget, cmd)
				end				
			else
				bot.moveType = -1
				bot.Disposition = OPPORTUNITY_FIRE
			end
		end
	
	
	--Task 13
	--Humans: Follow
	--Zombies: ...
	elseif bot.Task == FOLLOW then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetTeammate
		
			if !game.IsObj() and !GAMEMODE.ZombieEscape then
				bot:SetTask( GOTO_ARSENAL )
			end
			if game.IsObj() or GAMEMODE.ZombieEscape then
				bot.moveType = -1
				bot.Disposition = ENGAGE_AND_INVESTIGATE
			end
			
			if bot.Task == FOLLOW then
				if bot:GetMoveType() == MOVETYPE_LADDER then
				
					bot:DoLadderMovement( cmd, curgoal )
			
				else
					
					local atr = util.TraceLine( {
						start = bot:EyePos(),
						endpos = myTarget:LocalToWorld(myTarget:OBBCenter()),
						filter = function( ent ) if ( ent:IsWorld() ) then return true end end
					} )
					
					if IsValid (bot.Pathfinder.TargetEnemy) and !GAMEMODE.ZombieEscape then
						if bot:GetActiveWeapon().IsMelee and bot:GetActiveWeapon():GetClass() != "weapon_zs_hammer" and bot:Health() > (2 / 4 * bot:GetMaxHealth()) then
							local mtr = util.TraceLine( {
								start = bot:EyePos(),
								endpos = bot:AimPoint( bot.Pathfinder.TargetEnemy ),
								mask = MASK_SHOT,
								filter = function( ent ) if ( ent != bot.Pathfinder.TargetEnemy and ent != bot and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
							} )
							
							if !mtr.Hit and bot.runAwayTimer <= 0 and !IsValid(bot:GetOtherWeapon(HAS_AMMO)) then
								bot:SetTask( MELEE_ZOMBIE )
							end
						end
					end
					
					bot:LootCheck()
					
					if bot:GetPos():QuickDistanceCheck( myTarget:GetPos(), BIGGER, 80 ) or atr.Hit or bot:GetBarricadeGhosting() then
						CloseToPointCheck (bot, curgoal.pos, myTarget:GetPos(), cmd)
						bot:CheckPropPhasing()
						
						if !GAMEMODE.ZombieEscape then
							
							if bot:Health() > (3 / 4 * bot:GetMaxHealth()) and bot.runAwayTimer <= 0 then
								bot.Disposition = ENGAGE_AND_INVESTIGATE
							else
								bot.Disposition = IGNORE_ENEMIES
							end
							
							bot:RunAwayCheck( cmd )
						end
					elseif !atr.Hit and !bot:GetBarricadeGhosting() then
						bot.Disposition = OPPORTUNITY_FIRE
						bot.moveType = -1
					end
				end
			end
		end
	end
	
	--Task 14
	--Humans: Spawnkill zombies
	--Zombies: ...
	--[[if bot.Task == SPAWNKILL_ZOMBIES then
		if bot:Team() != TEAM_UNDEAD then
			local myTarget = bot.Pathfinder.TargetEnemy
			
		end
	end]]
	
	--==================== TIMER RESETS **DO NOT REMOVE** ====================
	
	if CurTime() > bot.targetFindDelay then
		bot.targetFindDelay = CurTime() + 0.5
	end
	
	--==================== END CHECKS ====================
	
	if IsValid(bot.Pathfinder.TargetEnemy) then
		if bot.lookAngle == (bot:AimPoint( bot.Pathfinder.TargetEnemy ) - bot:EyePos()):Angle() then 
			bot.Attacking = true 
		else 
			bot.Attacking = false 
		end
	else
		bot.Attacking = false
	end
end
hook.Add( "StartCommand", "controlBots", controlBots )

function botDeath( ply )
	if !ply.IsZSBot2 then return end
	
	--Manually respawn bots because the StartCommand function is disabled when they're dead for some reason
	if GAMEMODE:GetWave() == 0 then return end
	if ply:Team() != TEAM_UNDEAD and ply:GetZombieClassTable().Name == "Fresh Dead" then return end
	
	timer.Simple(2, function()
		if !IsValid(ply) or ply:Alive() or GAMEMODE.RoundEnded then return end
		
		if GAMEMODE:GetWaveActive() then
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
	if !ply.IsZSBot2 then return end
	
	--Remove the bots navigator entity so it doesn't cause errors
	ply.Pathfinder:Remove()
end
hook.Add( "PlayerDisconnected","botDisconnect",botDisconnect)

function botSpawn( ply )
	if !ply.IsZSBot2 then return end
	
	--Do functions on spawn such as changing class, choosing loadouts, etc
	ply:DoSpawnStuff( true )
end
hook.Add("PlayerSpawn", "botSpawn", botSpawn)