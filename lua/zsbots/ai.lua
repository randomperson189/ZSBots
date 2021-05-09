hook.Add( "StartCommand", "controlBots", function(bot, cmd)
	if !bot.IsZSBot2 then return end
	
	--==================== START FUNCTIONS ====================
	
	cmd:ClearMovement()
	cmd:ClearButtons()
	
	if !bot:OnGround() then bot.crouchHoldOnce = true end
	
	bot:DispositionCheck( cmd, bot.Pathfinder.TargetEnemy )
	
	CheckNavMeshAttributes( bot, cmd )
	--morale colour (0, 201, 201)
	
	--==================== DEBUGGING ====================
	
	bot:DoSpectateDebugUI()
	
	if GetConVar( "zs_bot_debug_defending_spots" ):GetInt() == 1 then
		if IsValid(bot.Pathfinder.TargetArsenal) then
			if bot.Pathfinder.TargetArsenal.UnCheckableAreas != nil then
				for i, area in ipairs(bot.Pathfinder.TargetArsenal.UnCheckableAreas) do
					debugoverlay.Box(vector_origin, area:GetCorner( 0 ), area:GetCorner( 2 ), 0, Color( 255, 0, 0, 5 ) )
				end
				
				for s, spot in ipairs(bot.Pathfinder.TargetArsenal.DefendingSpots) do
					if bot.Pathfinder.TargetArsenal.DefendingSpots[1] != nil then
						debugoverlay.Box(vector_origin, navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 0 ), navmesh.GetNearestNavArea( spot, false, 99999999999, false, false, TEAM_ANY ):GetCorner( 2 ), 0, Color( 0, 0, 255, 5 ) )
					end
				end
			end
		end
	end
	
	--==================== UNUSED THINGS THAT I MIGHT USE ====================
	
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
	
	--Reload when clip is empty
	if IsValid (bot:GetActiveWeapon()) and bot:Team() != TEAM_UNDEAD then
		if bot:GetActiveWeapon():Clip1() <= 0 and !bot:GetActiveWeapon().IsMelee and bot:GetActiveWeapon():GetNextSecondaryFire() <= CurTime() - 0.05 then
			bot.reloadHold = true
		end
	end
	
	--Switch weapons if got no ammo
	if (bot.Task == GOTO_ARSENAL or bot.Task == WANDER_AROUND or bot.Task == DEFEND_CADE or bot.Task == FOLLOW) and !bot.attack2Timer then
		if bot:Team() != TEAM_UNDEAD and CurTime() > bot.targetFindDelay and bot.runAwayTimer <= 0 then
			
			local curWep = bot:GetActiveWeapon()
			local otherWep = bot:GetOtherWeapon(HAS_AMMO)
			
			if IsValid(curWep) then
				if curWep:Clip1() <= 0 and bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) <= 0 and !curWep.IsMelee or curWep.IsMelee or curWep.Primary.Heal or curWep.AmmoIfHas then	
					if otherWep != nil then
						print(bot:GetName().. "'s current weapon ammo for " .. curWep:GetClass() .. " is " .. bot:GetAmmoCount( curWep:GetPrimaryAmmoType() ) .. " switching weapon to " .. otherWep:GetClass() .. " because it has ammo")
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
			
			if bot.Task != 14 then
				bot.Pathfinder.TargetTeammate = FindNearestTeammate( "player", bot )
			else
				if game.IsObj() or GAMEMODE.ZombieEscape then
					bot.Pathfinder.TargetTeammate = FindNearestPlayerTeammate( "player", bot )
				end
				if !game.IsObj() and !GAMEMODE.ZombieEscape then
					bot.Pathfinder.TargetTeammate = FindNearestTeammate( "player", bot )
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
	
	if bot:HasWeapon("weapon_zs_medicalkit") and bot.Task != HEAL_TEAMMATE then
		local medWeapon = bot:GetWeapon("weapon_zs_medicalkit")
		local medCooldown = medWeapon:GetNextCharge() - CurTime()
		
		if medCooldown <= 0 and medWeapon:GetPrimaryAmmoCount() > 0 then
			if IsValid (bot.Pathfinder.TargetHealing) then
				if bot:Health() > bot.Pathfinder.TargetHealing:Health() and bot:Health() > (2 / 4 * bot:GetMaxHealth()) then
					bot:SetTask( HEAL_TEAMMATE )
				end
				if bot:Health() <= bot.Pathfinder.TargetHealing:Health() or bot:Health() <= (2 / 4 * bot:GetMaxHealth()) then
					bot:SelectWeapon(medWeapon)
					
					bot.attack2Timer = true
				end
			elseif bot:Health() <= (3 / 4 * bot:GetMaxHealth()) then
				bot:SelectWeapon(medWeapon)
				
				bot.attack2Timer = true
			end
		end
	end
	
	--==================== BOT TASKS ====================
	
	TaskCheck(bot, cmd, curgoal)
	
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
	
	bot:InputTimers()
	bot:InputCheck( cmd )
	
	bot.crouchHoldOnce = false
end )

--==================== HOOKS ====================

hook.Add( "PlayerDeath", "botDeath", function(ply)
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
	end )
end )

hook.Add( "PlayerDisconnected", "botDisconnect", function(ply)
	if !ply.IsZSBot2 then return end
	
	--Remove the bots navigator entity so it doesn't cause errors
	ply.Pathfinder:Remove()
end )

hook.Add("PlayerSpawn", "botSpawn", function(ply)
	if !ply.IsZSBot2 then return end
	
	--Do functions on spawn such as changing class, choosing loadouts, etc
	ply:DoSpawnStuff( true )
end )

hook.Add( "SetWaveActive", "BotWaveActive", function(active)
    for i, bot in ipairs(player.GetZSBots()) do
		if active then
			if bot:Team() != TEAM_UNDEAD then
				bot.shouldGoOutside = false
			else
				--do zombie functions
			end
		else
			if bot:Team() != TEAM_UNDEAD then
				if math.random (1, 2) <= 1 then
					bot.shouldGoOutside = true
				end
			else
				--do zombie functions
			end
		end
	end
end )