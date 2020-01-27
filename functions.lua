-- HUMAN TASKS
GOTO_ARSENAL = 1
MELEE_ZOMBIES = 2
HEAL_TEAMMATE = 3
PLACE_RESUPPLY = 4
WANDER_AROUND = 5
REPAIR_CADES = 6
PICKUP_CADING_PROP = 7
MAKE_CADE = 8
RESUPPLY_AMMO = 9
PICKUP_LOOT = 10
DEFEND_CADE = 11
SNIPING = 12
FOLLOW = 13
SPAWNKILL_ZOMBIES = 14

-- ZOMBIE TASKS
GOTO_HUMANS = 1
HIDE_FROM_HUMANS = 2

-- DISPOSITIONS
ENGAGE_AND_INVESTIGATE = 1
OPPORTUNITY_FIRE = 2
SELF_DEFENSE = 3
IGNORE_ENEMIES = 4

-- MESSAGES
MSG_MEDIC = 0
MSG_BOSS_OUTSIDE = 1

defaultLookDistance = 1000
defaultEscapeLookDistance = math.huge
defaultRotationSpeed = 5 -- was 10

local plymeta = FindMetaTable("Player")
if not plymeta then return end

local entmeta = FindMetaTable("Entity")
if not entmeta then return end

function plymeta:DispositionCheck( cmd, enemy )
	if self.Disposition == 0 --[[IGNORE ENEMIES]] or self:Team() == TEAM_UNDEAD or !IsValid(enemy) or !enemy:Alive() or self:GetMoveType() == MOVETYPE_LADDER then return end
	
	local tr = util.TraceLine( {
		start = self:EyePos(),
		endpos = self:AimPoint( self.FollowerEnt.TargetEnemy ),
		filter = function( ent ) if ( ent != self.FollowerEnt.TargetEnemy and ent != self and !ent:IsPlayer() and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
	} )
	
	if self.Disposition == 1 then --ENGAGE_AND_INVESTIGATE
		if self:GetPos():Distance( self.FollowerEnt.TargetEnemy:GetPos() ) <= self.lookDistance then
			if !tr.Hit then
				self.lookAngle = ((self:AimPoint( self.FollowerEnt.TargetEnemy ) - self:EyePos()):Angle())
				
				self:ShootAtTarget()
			end
		else
			--print ("oofy oof oof")
		end
	elseif self.Disposition == 2 then --OPPORTUNITY_FIRE
		if self:GetPos():Distance( self.FollowerEnt.TargetEnemy:GetPos() ) <= self.lookDistance then
			if !tr.Hit then
				self.lookAngle = ((self:AimPoint( self.FollowerEnt.TargetEnemy ) - self:EyePos()):Angle())
				
				if self.Skill > 25 and IsValid(self:GetActiveWeapon()) then
					if self:GetActiveWeapon():GetNextSecondaryFire() <= CurTime() then
						self.attack2Hold = true
					end
				end
				
				self:ShootAtTarget()
			end
		else
			--print ("oofy oof oof")
		end
	elseif self.Disposition == 3 then --SELF_DEFENSE
		
	end
end

function plymeta:InputTimers()
	if IsValid(self:GetActiveWeapon()) then
		if self.canAttackTimer then
			if self.attackTimer then
				local wep = self:GetActiveWeapon()
				self.canAttackTimer = false
				
				self.attackHold = true
				
				if wep.Primary.Automatic then
					timer.Simple (0.01, function()
					if !IsValid (self) then return end
						self.attackTimer = false
						self.canAttackTimer = true
					end)
				else
					timer.Simple (0.1, function()
						if !IsValid (self) then return end
						self.attackTimer = false
						self.canAttackTimer = true
					end)
				end
			end
		end
	else
		self.attackTimer = false
	end
	
	if self.canZoomTimer then
		if self.zoomTimer then
			self.canZoomTimer = false
			
			self.zoomHold = true
			
			timer.Simple (0, function()
				if !IsValid (self) then return end
				self.zoomHold = false
				timer.Simple (0.2, function()
					if !IsValid (self) then return end
					self.zoomTimer = false
					self.canZoomTimer = true
				end)
			end)
		end
	end
	
	if self.canUseTimer then
		if self.useTimer then
			self.canUseTimer = false
			
			self.useHold = true
			
			
			timer.Simple (0, function()
				if !IsValid (self) then return end
				self.useHold = false
				timer.Simple (0.2, function()
					if !IsValid (self) then return end
					self.useTimer = false
					self.canUseTimer = true
				end)
			end)
		end
	end
	
	if self.canAttack2Timer then
		if self.attack2Timer then
			self.canAttack2Timer = false
			
			self.attack2Hold = true
			
			
			timer.Simple (0, function()
				if !IsValid (self) then return end
				self.attack2Hold = false
				timer.Simple (0.1, function()
					if !IsValid (self) then return end
					self.attack2Timer = false
					self.canAttack2Timer = true
				end)
			end)
		end
	end
	
	if self.canDeployTimer then
		if self.deployTimer then
			self.canDeployTimer = false
			
			self.lookAngle = Angle (70, self:EyeAngles().y, self:EyeAngles().z)
			self.crouchHold = true
			timer.Simple (0.75, function()
				if !IsValid (self) then return end
				self.crouchHold = false
				timer.Simple (0, function()
					if !IsValid (self) then return end
					self.attackHold = true
					self.lookAngle = Angle (0, self:EyeAngles().y, self:EyeAngles().z)
					timer.Simple (0.5, function()
						if !IsValid (self) then return end
						self.attackHold = false
						self.Task = GOTO_ARSENAL
						self.deployTimer = false --comment this out if things no work properly
						self.canDeployTimer = true
					end)
				end)
			end)
		end
	end
	
	if self.canCJumpTimer and self:GetZombieClassTable().Name != "Crow" then
		if self.cJumpTimer then
			self.canCJumpTimer = false
			self.crouchHold = true
			
			local atr = util.TraceHull( {
				start = self:EyePos(),
				endpos = self:EyePos() + self:EyeAngles():Forward() * 35,
				mins = Vector(-25, -25, -25),
				maxs = Vector(25, 25, 25),
				ignoreworld = true,
				filter = function( ent ) if ( ent:GetClass() == "prop_door_rotating" or ent:GetClass() == "func_door_rotating" or ent:GetClass() == "func_door" ) then return true end end
			} )
			
			if IsValid(atr.Entity) then
				self.useHold = true
			end
			
			timer.Simple (0.05, function()
				if !IsValid(self) then return end
				self.jumpHold = true
				
				timer.Simple (1, function()
					if !IsValid(self) then return end
					
					if self:GetVelocity():Length() < 10 then
						self.strafeType = 0
						--self.useHold = true
						
						--[[timer.Simple (0.01, function()
							if !IsValid (self) then return end
							self.useHold = false
						end)]]
						
						timer.Simple (0.5, function()
							if !IsValid(self) then return end
							self.strafeType = 1
							timer.Simple (0.75, function()
								if !IsValid(self) then return end
								self.strafeType = -1
								
								self.crouchHold = false
								timer.Simple (0.5, function()
									if !IsValid(self) then return end
									self.cJumpTimer = false
									self.canCJumpTimer = true
								end)
							end)
						end)
					else
					
					self.crouchHold = false
					timer.Simple (0.10, function()
						if !IsValid(self) then return end
						self.cJumpTimer = false
						self.canCJumpTimer = true
						end)
					end
				end)
			end)
		end
	end
end

function plymeta:InputCheck(cmd)
	if self.moveType == -1 then
		self.cJumpDelay = 0
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 0 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 1 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( -1000 )
	elseif self.moveType == 2 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( -1000 )
	elseif self.moveType == 3 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( -1000 )
	elseif self.moveType == 4 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 5 then
		cmd:SetForwardMove( -1000 )
		cmd:SetSideMove( 1000 )
	elseif self.moveType == 6 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 1000 )
	elseif self.moveType == 7 then
		cmd:SetForwardMove( 1000 )
		cmd:SetSideMove( 1000 )
	end

	if self.strafeType == 0 then
		cmd:SetSideMove( 1000 )
	elseif self.strafeType == 1 then
		cmd:SetSideMove( -1000 )
	else
		--cmd:SetSideMove( 0 )
	end
	
--------------------------------------------------

	local attack = 0
	local attack2 = 0
	local reload = 0
	local jump = 0
	local crouch = 0
	local use = 0
	local zoom = 0
	local sprint = 0
	
	if self.attackHold then
		attack = IN_ATTACK
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.attackHold = false
		end)
	end
	if self.attack2Hold then
		attack2 = IN_ATTACK2
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.attack2Hold = false
		end)
	end	
	if self.reloadHold then
		reload = IN_RELOAD
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.reloadHold = false
		end)
	end
	if self.jumpHold then
		jump = IN_JUMP
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.jumpHold = false
		end)
	end
	if self.crouchHold then
		crouch = IN_DUCK
		
		--[[timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.crouchHold = false
		end)]]
	end
	if self.useHold then
		use = IN_USE
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.useHold = false
		end)
	end
	if self.zoomHold then
		zoom = IN_ZOOM
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.zoomHold = false
		end)
	end
	if self.sprintHold then
		sprint = IN_SPEED
		
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.sprintHold = false
		end)
	end
	
	cmd:SetButtons(bit.bor( attack, attack2, reload, jump, crouch, use, zoom, sprint ))
end

function game.IsObj()
	if string.find( game.GetMap(), "_obj_" ) then
		return true
	else
		return false
	end
end

function SayPresetMessage(bot, category, teamOnly)
	if teamChat == nil then teamChat = false end
	
	if bot.prevSay == category then return end
	if GetConVar( "zs_bot_can_chat" ):GetInt() == 0 then return end
	
	bot.prevSay = category
	
	local function botSay(msg)
		if teamOnly then
			bot:Say(msg, true)
		else
			bot:Say(msg)
		end
	end 
	
	if category == 0 then
		--Medic messages
		local msgs = {"MEDIC!", "I need a medic!", "I need heals!"}
		local hpMsgs = {" I'm at " .. bot:Health() .. "HP.", " My HP is at " .. bot:Health()}
		local message = msgs[math.random(1, #hpMsgs)]
		
		if bot.Skill > 50 then
			message = message .. hpMsgs[math.random(1, #hpMsgs)]
		end
		
		botSay(message)
	elseif category == 1 then
		--Boss outside messages
		local msgs = {bot.FollowerEnt.TargetEnemy:GetZombieClassTable().Name .. " outside.", bot.FollowerEnt.TargetEnemy:GetZombieClassTable().Name .. " is outside the cade."}
		local message = msgs[math.random(1, #msgs)]
		
		botSay(message)
	elseif category == 2 then
	
	elseif category == 3 then
	
	elseif category == 4 then
	
	elseif category == 5 then
	
	elseif category == 6 then
	
	elseif category == 7 then
	
	end
end

--[[NavAreas = navmesh:GetAllNavAreas()
AttributedAreas = {  }

timer.Create( "mah timer", 1, 0, function() 
	PrintTable (AttributedAreas)
	for i, area in ipairs(NavAreas) do
		if area:HasAttributes(NAV_MESH_JUMP) or area:HasAttributes(NAV_MESH_CROUCH) then
			if !table.HasValue(AttributedAreas, area) then
				table.insert(AttributedAreas, area)
			end
		end
		
		if !area:HasAttributes(NAV_MESH_JUMP) and !area:HasAttributes(NAV_MESH_CROUCH) then
			table.RemoveByValue(AttributedAreas, area)
		end
	end
end )]]

function plymeta:LookatPosXY( cmd, pos )
	local theAngle = nil
	
	if self:WaterLevel() <= 0 then
		theAngle = (Vector (pos.x, pos.y, 0) - Vector (self:GetPos().x, self:GetPos().y, 0)):Angle()
	else
		theAngle = (Vector (pos.x, pos.y, pos.z) - Vector (self:GetPos().x, self:GetPos().y, self:GetPos().z)):Angle()
	end
	self.lookAngle = Angle( theAngle.x, theAngle.y, 0 )
end

function GetRandomPositionOnNavmesh( pos, radius, stepdown, stepup )
	local randomPos = pos + Angle(0, math.random(-180, 180), 0):Forward() * math.random(0, radius)
	local posOnNavmesh = navmesh.GetNearestNavArea( randomPos, false, 99999999999, false, false, TEAM_ANY ):GetClosestPointOnArea( randomPos )
	
	return posOnNavmesh
end

--[[timer.Create( "ZSBotQuotaCheck", 0.5, 0, function ()
	if #GetZSBots() < GetConVar( "zs_bot_quota" ):GetInt() and #player.GetAll() < game.MaxPlayers() then
		player.CreateZSBot()
	end
	if #GetZSBots() > GetConVar( "zs_bot_quota" ):GetInt() then
		GetZSBots()[#GetZSBots()]:Kick()
	end	
end)]]

function player.GetZSBots()
	local zsbots = {  }

	for i, bot in ipairs(player.GetBots()) do
		if bot.IsZSBot2 then
			table.insert( zsbots, bot )
		end
	end
	
	return zsbots
end

function CountNearbyFriends( bot, radius )
	--debugoverlay.Sphere( bot:EyePos(), radius, 0.5, Color( 255, 255, 255, 0 ), true )
	local tbl = {  }
	
	for i, friend in ipairs( ents.FindInSphere(bot:EyePos(), radius) ) do
		if friend:IsPlayer() and friend:Team() == bot:Team() and friend != bot then
			table.insert(tbl, friend)
		end
	end
	
	return #tbl
end

function CountNearbyEnemies( bot, radius )
	local tbl = {  }
	
	for i, enemy in ipairs( ents.FindInSphere(bot:EyePos(), radius) ) do
		if enemy:IsPlayer() and enemy:Team() != bot:Team() and enemy != bot then
			table.insert(tbl, enemy)
		end
	end
	
	return #tbl
end

--------------FIND NEAREST--------------------------------------
function FindNearestEnemy( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range and entity != thisEnt and entity:Team() != thisEnt:Team() and entity:GetZombieClassTable().Name != "Crow" ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function AnEnemyIsInSight(className, thisEnt)
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
		if ( entity != thisEnt and entity:Team() != thisEnt:Team() and entity:GetZombieClassTable().Name != "Crow" ) then
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = entity:EyePos(),
				filter = function( ent ) if ( !ent:IsPlayer() and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
			} )
			
			if !tr.Hit then
				return true
			end
		end
    end 
	
    return false
end

function FindNearestEnemyInSight( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
		
		local tr = util.TraceLine( {
			start = thisEnt:EyePos(),
			endpos = entity:EyePos(),
			filter = function( ent ) if ( !ent:IsPlayer() and ent:GetClass() != "prop_physics" and ent:GetClass() != "prop_physics_multiplayer" and ent:GetClass() != "func_breakable" ) then return true end end
		} )
		
        if ( distance <= range and entity != thisEnt and entity:Team() != thisEnt:Team() and entity:GetZombieClassTable().Name != "Crow" and !tr.Hit ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestEntity( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestTeammate( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range and entity != thisEnt and entity:Team() == thisEnt:Team() ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestPlayerTeammate( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range and entity != thisEnt and !entity:IsBot() and entity:Team() == thisEnt:Team() ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestProp( thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range ) then
        	if entity:GetClass() == "prop_physics" or entity:GetClass() == "prop_physics_multiplayer" then
        		if !entity:IsNailed() then
					nearestEnt = entity
					range = distance
            	end
            end
        end 
    end 
    return nearestEnt
end

function FindNearestPropOrBreakable( thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range ) then
        	if entity:GetClass() == "prop_physics" or entity:GetClass() == "prop_physics_multiplayer" or entity:GetClass() == "func_breakable" or entity:GetClass() == "func_door_rotating" then
            	nearestEnt = entity
            	range = distance
            end
        end 
    end 
    return nearestEnt
end

function FindNearestNailedPropOrBreakable( thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range ) then
        	if entity:GetClass() == "prop_physics" or entity:GetClass() == "prop_physics_multiplayer" then
        		if entity:IsNailed() then
            		nearestEnt = entity
            		range = distance
            	end
            end
            if entity:GetClass() == "func_breakable" then
            	nearestEnt = entity
            	range = distance
            end
        end 
    end 
    return nearestEnt
end

function FindNearestNailedProp( thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range ) then
        	if entity:GetClass() == "prop_physics" or entity:GetClass() == "prop_physics_multiplayer" then
        		if entity:IsNailed() then
					if entity:GetBarricadeHealth() < entity:GetMaxBarricadeHealth() and entity:GetBarricadeRepairs() > 0 then
						nearestEnt = entity
						range = distance
					end
            	end
            end
        end 
    end 
    return nearestEnt
end

function FindNearestLoot( thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
		if ( distance <= range ) then
			if IsValid( thisEnt:GetActiveWeapon() ) then
				if entity:GetClass() == "prop_weapon" then
					if !IsValid (thisEnt:GetWeapon(entity:GetWeaponType())) then
						nearestEnt = entity
						range = distance
					end
					
				elseif entity:GetClass() == "prop_ammo" then
					nearestEnt = entity
					range = distance
				end
				
			elseif entity:GetClass() == "prop_weapon" or entity:GetClass() == "prop_ammo" then
				nearestEnt = entity
				range = distance
			end
		end
    end 
    return nearestEnt
end

function FindNearestHidingSpot( thisEnt, range )
	local nearestSpot
    
    for i, area in ipairs( navmesh:GetAllNavAreas( thisEnt:GetPos(), 0 ) ) do 
		for i2, spot in ipairs( area:GetHidingSpots() ) do
			local distance = thisEnt:GetPos():Distance( spot )
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = Vector(spot.x, spot.y, spot.z + (thisEnt:EyePos().z - thisEnt:GetPos().z)),
				filter = function( ent ) if ( ent != thisEnt ) then return true end end
			} )

			if ( distance <= range and !tr.HitWorld ) then
				nearestSpot = spot
				range = distance
        	end 
		end
	end
    return nearestSpot
end

function FindNearestSniperSpot( thisEnt, range )
	local nearestSpot
    
    for i, area in ipairs( navmesh:GetAllNavAreas( thisEnt:GetPos(), 0 ) ) do 
		for i2, spot in ipairs( area:GetExposedSpots() ) do
			local distance = thisEnt:GetPos():Distance( spot )
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = Vector(spot.x, spot.y, spot.z + (thisEnt:EyePos().z - thisEnt:GetPos().z)),
				filter = function( ent ) if ( ent != thisEnt ) then return true end end
			} )

			if ( distance <= range and !tr.HitWorld ) then
				nearestSpot = spot
				range = distance
        	end 
		end
	end
    return nearestSpot
end
----------------------------------------------------------------

function MoveToPosition (bot, position, cmd)
	local vec = ( position - bot:GetPos() ):GetNormal():Angle().y
	local oof = bot:EyeAngles().y
	
	if oof > 360 then
		oof = oof - 360
	end
	if oof < 0 then
		oof = oof + 360
	end
	
	local thingy = vec - oof
	
	if thingy > 360 then
		thingy = thingy - 360
	end
	if thingy < 0 then
		thingy = thingy + 360
	end
	
	--print ("my eye angles", oof, "the angle", vec, "the sum thing", thingy)
	
	if thingy <= 22.5 or thingy > 337.5 then
		bot.moveType = 0
		--print ("Forward")
	end
	
	if thingy > 22.5 and thingy <= 67.5 then
		bot.moveType = 1
		--print ("Forward Left")
	end
	
	if thingy > 67.5 and thingy <= 112.5 then
		bot.moveType = 2
		--print ("Left")
	end
	
	if thingy > 112.5 and thingy <= 157.5 then
		bot.moveType = 3
		--print ("Left Back")
	end
	
	if thingy > 157.5 and thingy <= 202.5 then
		bot.moveType = 4
		--print ("Back")
	end
	
	if thingy > 202.5 and thingy <= 247.5 then
		bot.moveType = 5
		--print ("Back Right")
	end
	
	if thingy > 247.5 and thingy <= 292.5 then
		bot.moveType = 6
		--print ("Right")
	end
	
	if thingy > 292.5 and thingy <= 337.5 then
		bot.moveType = 7
		--print ("Forward Right")
	end
end

function OtherWeaponWithAmmo(bot)
	local daWep = nil
	
	for i, wep in ipairs(bot:GetWeapons()) do 
		if wep:Clip1() > 0 or bot:GetAmmoCount( wep:GetPrimaryAmmoType() ) > 0 then
			if wep.Base != "weapon_zs_basemelee" then
				daWep = wep
				
				break
			end
		end
	end
	
	return daWep
end

function CheckNavMeshAttributes( bot, cmd )
	--[[if navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetAttributes() == NAV_MESH_CROUCH then
		bot.crouchHold = true
	end]]
	
	if navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetAttributes() == NAV_MESH_JUMP then
		bot.cJumpTimer = true
	end
	
	--[[local obbPosSE = LocalToWorld(bot:OBBMins(), Angle(0,0,0), bot:GetPos(), Angle(0,0,0))
	local obbPosNE = LocalToWorld(Vector(-bot:OBBMins().x, bot:OBBMins().y, 0), Angle(0,0,0), bot:GetPos(), Angle(0,0,0))
	local obbPosSW = LocalToWorld(Vector(bot:OBBMins().x, -bot:OBBMins().y, 0), Angle(0,0,0), bot:GetPos(), Angle(0,0,0))
	local obbPosNW = LocalToWorld(Vector(-bot:OBBMins().x, -bot:OBBMins().y, 0), Angle(0,0,0), bot:GetPos(), Angle(0,0,0))]]
	
	--[[local attributedAreas = {}
	local area = navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY )
	
	if area:HasAttributes( NAV_MESH_JUMP ) or area:HasAttributes( NAV_MESH_CROUCH ) then table.insert(attributedAreas, area) end
	
	if !area:HasAttributes( NAV_MESH_JUMP ) and !area:HasAttributes( NAV_MESH_CROUCH ) then 
		for i, daArea in ipairs(area:GetAdjacentAreasAtSide(0)) do
			if area:HasAttributes( NAV_MESH_JUMP ) or area:HasAttributes( NAV_MESH_CROUCH ) then table.insert(attributedAreas, area) end
		end
		for i, daArea in ipairs(area:GetAdjacentAreasAtSide(1)) do
			if area:HasAttributes( NAV_MESH_JUMP ) or area:HasAttributes( NAV_MESH_CROUCH ) then table.insert(attributedAreas, area) end
		end
		for i, daArea in ipairs(area:GetAdjacentAreasAtSide(2)) do
			if area:HasAttributes( NAV_MESH_JUMP ) or area:HasAttributes( NAV_MESH_CROUCH ) then table.insert(attributedAreas, area) end
		end
		for i, daArea in ipairs(area:GetAdjacentAreasAtSide(3)) do
			if area:HasAttributes( NAV_MESH_JUMP ) or area:HasAttributes( NAV_MESH_CROUCH ) then table.insert(attributedAreas, area) end
		end
	end]]
	
	--[[for i, area in ipairs( AttributedAreas ) do
		if obbPosSE.x < area:GetCorner(2).x and obbPosSE.y < area:GetCorner(2).y 
		-------------------------------------------------------------------------
		and obbPosSW.x < area:GetCorner(1).x and obbPosSW.y > area:GetCorner(1).y
		-------------------------------------------------------------------------
		and obbPosNE.x > area:GetCorner(3).x and obbPosNE.y < area:GetCorner(3).y 
		-------------------------------------------------------------------------
		and obbPosNW.x > area:GetCorner(0).x and obbPosNW.y > area:GetCorner(0).y then
			if area:HasAttributes( NAV_MESH_JUMP ) then
				bot.cJumpTimer = true
				break
			end
			
			if area:HasAttributes( NAV_MESH_CROUCH ) then
				if bot.attackHold then
					cmd:SetButtons( bit.bor( IN_DUCK, IN_ATTACK ) )
				elseif bot.jumpHold then
					cmd:SetButtons( bit.bor( IN_DUCK, IN_JUMP ) )
				else
					cmd:SetButtons( IN_DUCK )
				end
				break
			end
		end
	end]]
	
	--debugoverlay.Sphere( obbPosSE, 2, 0, Color( 255, 0, 0, 0 ), true )
	--debugoverlay.Sphere( obbPosNE, 2, 0, Color( 255, 0, 0, 0 ), true )
	--debugoverlay.Sphere( obbPosSW, 2, 0, Color( 255, 0, 0, 0 ), true )
	--debugoverlay.Sphere( obbPosNW, 2, 0, Color( 255, 0, 0, 0 ), true )
end

--[[local tr = util.TraceHull( {
	start = Vector( 0, 0, 0 ),
	endpos = Vector( 0, 0, 0 ),
	mins = area:GetCorner( 0 ),
	maxs = Vector(area:GetCorner( 2 ).x, area:GetCorner( 2 ).y, area:GetCorner( 2 ).z + 200),
	ignoreworld = true,
	filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
} )

--debugoverlay.Box(Vector (0,0,0), area:GetCorner( 0 ), Vector(area:GetCorner( 2 ).x, area:GetCorner( 2 ).y, area:GetCorner( 2 ).z + 200), 0, Color( 255, 255, 255 ), true )

--print (tr.Entity)
if !table.HasValue(bot.DefendingSpots, area:GetCenter()) and !tr.Entity:IsNailed() then
	table.insert (bot.DefendingSpots, area:GetCenter())
end
if !table.HasValue(bot.DefendingSpots, area:GetCenter()) and !IsValid( tr.Entity ) then
	table.insert (bot.DefendingSpots, area:GetCenter())
end]]

function entmeta:FindCadingSpots( centerArea )
	if self.UnCheckableAreas == nil then self.UnCheckableAreas = {} end
	if self.DefendingSpots == nil then self.DefendingSpots = {} end
	if self.CadingSpots == nil then self.CadingSpots = {} end
	
	if table.HasValue( self.UnCheckableAreas, centerArea ) or !IsValid( centerArea) then return end
	
	local northConnectedAreas = centerArea:GetAdjacentAreasAtSide(0)
	local southConnectedAreas = centerArea:GetAdjacentAreasAtSide(2)
	local eastConnectedAreas = centerArea:GetAdjacentAreasAtSide(1)
	local westConnectedAreas = centerArea:GetAdjacentAreasAtSide(3)
	
	--PrintTable (self.UnCheckableAreas)
	print ("Checking around " .. tostring(centerArea) .. " for cading spots")
	
	if !table.HasValue( self.UnCheckableAreas, centerArea ) then
		table.insert( self.UnCheckableAreas, centerArea )
	end
	
	for i, area in ipairs(northConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			
			if area:GetAdjacentAreasAtSide(1)[1] == nil and area:GetAdjacentAreasAtSide(3)[1] == nil then
				if !table.HasValue(self.DefendingSpots, area:GetCenter()) then
					table.insert (self.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(self.UnCheckableAreas, area) and !table.HasValue(self.DefendingSpots, area:GetCenter()) then
				self:FindCadingSpots(area)
			end
		end
	end
	
	for i, area in ipairs(southConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(1)[1] == nil and area:GetAdjacentAreasAtSide(3)[1] == nil then
				if !table.HasValue(self.DefendingSpots, area:GetCenter()) then
					table.insert (self.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(self.UnCheckableAreas, area) and !table.HasValue(self.DefendingSpots, area:GetCenter()) then
				self:FindCadingSpots(area)
			end
		end
	end
	
	for i, area in ipairs(eastConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(0)[1] == nil and area:GetAdjacentAreasAtSide(2)[1] == nil then
				if !table.HasValue(self.DefendingSpots, area:GetCenter()) then
					table.insert (self.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(self.UnCheckableAreas, area) and !table.HasValue(self.DefendingSpots, area:GetCenter()) then
				self:FindCadingSpots(area)
			end
		end
	end
	
	for i, area in ipairs(westConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(0)[1] == nil and area:GetAdjacentAreasAtSide(2)[1] == nil then
				if !table.HasValue(self.DefendingSpots, area:GetCenter()) then
					table.insert (self.DefendingSpots, area:GetCenter())
				end
			end
			--[[if area:GetAdjacentAreasAtSide(0)[1] != nil or area:GetAdjacentAreasAtSide(2)[1] != nil then
				if !table.HasValue(self.UnCheckableAreas, area) and !table.HasValue(self.DefendingSpots, area:GetCenter()) then
					self:FindCadingSpots(area)
				end
			end]]
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(self.UnCheckableAreas, area) and !table.HasValue(self.DefendingSpots, area:GetCenter()) then
				self:FindCadingSpots(area)
			end
		end
	end
end

function player.CreateZSBot( name )
	if !game.SinglePlayer() and #player.GetAll() < game.MaxPlayers() and engine.ActiveGamemode() == "zombiesurvival" then
		if name == nil or name == "" then
			local names = {"A Professional With Standards", "AimBot", "AmNot", "Aperture Science Prototype XR7", "Archimedes!", "BeepBeepBoop", "Big Mean Muther Hubbard", "Black Mesa", "BoomerBile", "Cannon Fodder", "CEDA", "Chell", "Chucklenuts", "Companion Cube", "Crazed Gunman", "CreditToTeam", "CRITRAWKETS", "Crowbar", "CryBaby", "CrySomeMore", "C++", "DeadHead", "Delicious Cake", "Divide by Zero", "Dog", "Force of Nature", "Freakin' Unbelievable", "Gentlemanne of Leisure", "GENTLE MANNE of LEISURE ", "GLaDOS", "Glorified Toaster with Legs", "Grim Bloody Fable", "GutsAndGlory!", "Hat-Wearing MAN", "Headful of Eyeballs", "Herr Doktor", "HI THERE", "Hostage", "Humans Are Weak", "H@XX0RZ", "I LIVE!", "It's Filthy in There!", "IvanTheSpaceBiker", "Kaboom!", "Kill Me", "LOS LOS LOS", "Maggot", "Mann Co.", "Me", "Mega Baboon", "Mentlegen", "Mindless Electrons", "MoreGun", "Nobody", "Nom Nom Nom", "NotMe", "Numnutz", "One-Man Cheeseburger Apocalypse", "Poopy Joe", "Pow!", "RageQuit", "Ribs Grow Back", "Saxton Hale", "Screamin' Eagles", "SMELLY UNFORTUNATE", "SomeDude", "Someone Else", "Soulless", "Still Alive", "TAAAAANK!", "Target Practice", "ThatGuy", "The Administrator", "The Combine", "The Freeman", "The G-Man", "THEM", "Tiny Baby Man", "Totally Not A Bot", "trigger_hurt", "WITCH", "ZAWMBEEZ", "Ze Ubermensch", "Zepheniah Mann", "0xDEADBEEF", "10001011101"}
			name = table.Random( names )
		end
		
		--CREATE THE BOT
		ply = player.CreateNextBot( name )
		ply.IsZSBot2 = true --Using IsZSBot2 cuz shitty GitHub ZSBots use IsZSBot and so it would conflict
		
		--FUNCTION DELAYS
		ply.targetFindDelay = CurTime()
		
		--TIMERS
		ply.guardTimer = math.random( 5, 10 )
		ply.runAwayTimer = 0
		ply.newPointTimer = 15
		--ply.lookAroundTimer = 0
		--ply.rotationTimer = 0
		
		--BOT NAVIGATOR
		ply.FollowerEnt = ents.Create( "sent_zsbot_pathfinder" )
		ply.FollowerEnt:Spawn()
		ply.FollowerEnt.Bot = ply
		
		--OTHER STUFF
		ply.LastPath = nil
		ply.lookProp = nil
		ply.lookPos = nil
		ply.lookDistance = 1000
		ply.lastWeapon = nil
		ply.heldProp = nil
		ply.strafeType = -1 --0 = left, 1 = right, 2 = back
		ply.moveType = -1	-- -1 = stop, 0 = f, 1 = fl, 2 = l, 3 = lb, 4 = b, 5 = br, 6 = r, 7 = fr
		ply.shouldGoOutside = false
		ply.canShouldGoOutside = true
		
		--UNUSED THINGYS I MIGHT REMOVE XD
		--[[ply.stopVel = 40
		ply.canRaycast = true]]
		
		--ply.State = 0 --Idle, Hunt, MoveTo, Buy, Hide
		--ply.stateName = "NONE"
		ply.Attacking = false
		ply.Task = 0
		ply.Disposition = 0 --ENGAGE_AND_INVESTIGATE, OPPORTUNITY_FIRE, SELF_DEFENSE, IGNORE_ENEMIES
		ply.Skill = math.random(0, 100)
		--ply.Morale = 0 --EXCELLENT, GOOD, POSITIVE, NEUTRAL, NEGATIVE, BAD, TERRIBLE
		--ply.moraleName = "NONE"
		ply.nearbyFriends = 0
		ply.nearbyEnemies = 0
		
		--NAV AREAS
		--[[ply.DefendingSpots = {  }
		ply.CadingSpots = {  }
		ply.UnCheckableAreas = {  }]]
		
		--CHAT MESSAGES
		ply.sayMessage = ""
		ply.sayTeamMessage = ""
		
		ply.prevSay = -1
		
		--INPUT TIMERS
		ply.canGetOffLadderTimer = true
		ply.b = true
		
		ply.canCJumpTimer = true
		ply.cJumpTimer = false
		
		ply.canUseTimer = true
		ply.useTimer = false
		
		ply.canAttackTimer = true
		ply.attackTimer = false
		
		ply.canAttack2Timer = true
		ply.attack2Timer = false
		
		ply.canDeployTimer = true
		ply.deployTimer = false
		
		ply.canZoomTimer = true
		ply.zoomTimer = false
		
		--INPUT VALUES
		ply.attackHold = false
		ply.attack2Hold = false
		ply.reloadHold = false
		ply.jumpHold = false
		ply.crouchHold = false
		ply.useHold = false
		ply.zoomHold = false
		ply.sprintHold = false
		
		--SMOOTH ROTATION
		ply.lookAngle = Angle(0, 0, 0)
		ply.rotationSpeed = 5
		ply.angle = Angle(0, 0, 0)
		
		--DO STUFF ON SPAWN LIKE CHOOSING LOADOUTS, CHANGING CLASS, ETC
		ply:DoSpawnStuff( false )
	else
		MsgC( Color( 255, 255, 255 ), "Failed to create ZSBot.\n" )
	end
end

concommand.Add( "zs_bot_add", function ( ply, cmd, args, argStr )
	
	local canDo = false
	
	if !IsValid(ply) then
		canDo = true
	end
	
	if IsValid(ply) then
		if ply:IsListenServerHost() then
			canDo = true
		end
	end
	
	if canDo then
		if tonumber (args[1]) == nil then
			args[1] = 1
		end
		
		for i=1, args[1] do 
			if args[2] == nil then
				player.CreateZSBot()
			else
				player.CreateZSBot( args[2] )
			end
		end
	end
end, nil, "zs_bot_add <count> <name> - Adds a bot matching the given criteria." )

concommand.Add( "zs_bot_kick", function ( ply, cmd, args, argStr )
	
	local canDo = false
	
	if !IsValid(ply) then
		canDo = true
	end
	
	if IsValid(ply) then
		if ply:IsListenServerHost() then
			canDo = true
		end
	end
	
	if canDo then
		if argStr == "All" or argStr == "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 then
					bot:Kick()
				end
			end
		end
		if argStr == "Humans" or argStr == "humans" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Team() == 4 then
					bot:Kick()
				end
			end
		end
		if argStr == "Zombies" or argStr == "zombies" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Team() == TEAM_UNDEAD then
					bot:Kick()
				end
			end
		end
		if argStr != "Zombies" and argStr != "zombies" and argStr != "Humans" and argStr != "humans" and argStr != "All" and argStr != "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Name() == argStr then
					bot:Kick()
				end
			end
		end
	end
end, nil, "zs_bot_kick <name> - Kicks a bot matching the given criteria." )
	
concommand.Add( "zs_bot_kill", function ( ply, cmd, args, argStr )
	
	local canDo = false
	
	if !IsValid(ply) then
		canDo = true
	end
	
	if IsValid(ply) then
		if ply:IsListenServerHost() then
			canDo = true
		end
	end
	
	if canDo then
		if argStr == "All" or argStr == "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Alive() then
					bot:Kill()
				end
			end
		end
		if argStr == "Humans" or argStr == "humans" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Alive() and bot:Team() == 4 then
					bot:Kill()
				end
			end
		end
		if argStr == "Zombies" or argStr == "zombies" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Alive() and bot:Team() == TEAM_UNDEAD then
					bot:Kill()
				end
			end
		end
		if argStr != "Zombies" and argStr != "zombies" and argStr != "Humans" and argStr != "humans" and argStr != "All" and argStr != "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot2 and bot:Alive() and bot:Name() == argStr then
					bot:Kill()
				end
			end
		end
	end
end, nil, "zs_bot_kill <name> - Kills a bot matching the given criteria." )

function plymeta:RerollBotClass ()
	BotClasses = {
	"Zombie", "Zombie", "Zombie",
	"Ghoul",
	"Wraith",
	"Bloated Zombie", "Bloated Zombie", "Bloated Zombie",
	"Fast Zombie", "Fast Zombie",
	"Mailed Zombie",
	"Scratcher",
	"Poison Zombie", "Poison Zombie", "Poison Zombie",
	"Screamer",
	"Zombine", "Zombine", "Zombine", "Zombine", "Zombine" 
	}
	
	if not GAMEMODE:GetWaveActive() then return end
	if self:GetZombieClassTable().Name == "Zombie Torso" or self:GetZombieClassTable().Name == "Fresh Dead" or self:GetZombieClassTable().Boss then return end
	local classId = table.Random(BotClasses)
	local class = GAMEMODE.ZombieClasses[classId]
	if not class then
		table.RemoveByValue(BotClasses, classId)
		self:RerollBotClass()
		return
	end
	if class.Wave > GAMEMODE:GetWave() then 
		self:RerollBotClass()
		return
	end
	self:SetZombieClass(class.Index)
end

function plymeta:RunAwayCheck( cmd )
	if IsValid (self.FollowerEnt.TargetEnemy) and self.FollowerEnt.TargetEnemy:Alive() then
		self.b = true
		
		if self.runAwayTimer <= 0 then
			if self:GetPos():Distance( self.FollowerEnt.TargetEnemy:GetPos() ) <= 150 then
				self.runAwayTimer = math.random(1, 3)
			end
		elseif self.Skill > 50 then
			--print ("running away" .. self.runAwayTimer)
			self.Disposition = 0
			
			if !self:GetActiveWeapon().IsMelee then
				for i, meleeWep in ipairs(self:GetWeapons()) do 
					if meleeWep.IsMelee then
						self:SelectWeapon(meleeWep)
						
						break
					end
				end
			end
		end
	end
end

function plymeta:CheckPropPhasing( cmd )
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos(),
		mins = Vector( -18, -18, 0 ),
		maxs = Vector( 18, 18, 73 ),
		ignoreworld = true,
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
	} )
	
	if tr.Entity:IsNailed() then
		--self.cJumpTimer = false
		self.zoomTimer = true
	end
end

function plymeta:ShootAtTarget()
	local skillSteadyShoot = math.Remap( self.Skill, 0, 100, 25, 10 )
	
	local th = util.TraceHull( {
		start = self:EyePos() + self:EyeAngles():Forward() * self:EyePos():Distance(self:AimPoint( self.FollowerEnt.TargetEnemy )),
		mins = Vector( -skillSteadyShoot, -skillSteadyShoot, -skillSteadyShoot ),
		maxs = Vector( skillSteadyShoot, skillSteadyShoot, skillSteadyShoot ),
		ignoreworld = true,
		filter = function( ent ) if ( ent == self.FollowerEnt.TargetEnemy ) then return true end end
	} )
	
	local colour = Color( 255, 0, 0, 0)
	
	if th.Hit then
		self.attackTimer = true
		colour = Color( 0, 255, 0, 0)
	end
	
	debugoverlay.Box( self:EyePos() + self:EyeAngles():Forward() * self:EyePos():Distance(self:AimPoint( self.FollowerEnt.TargetEnemy )), Vector( -skillSteadyShoot, -skillSteadyShoot, -skillSteadyShoot ), Vector( skillSteadyShoot, skillSteadyShoot, skillSteadyShoot ), 0, colour )
end

function plymeta:AimPoint( target )
	if self:Team() == TEAM_UNDEAD then
		if target:IsPlayer() then
			return target:EyePos()
		else
			return target:GetPos()
		end
	end
	
	local numHitBoxGroups = target:GetHitBoxGroupCount()

	for group=0, numHitBoxGroups - 1 do
		local numHitBoxes = target:GetHitBoxCount( group )

		for hitbox=0, numHitBoxes - 1 do
			local bone = target:GetHitBoxBone( hitbox, group )

			--print( "Hit box group " .. group .. ", hitbox " .. hitbox .. " is attached to bone " .. target:GetBoneName( bone ) )
			
			if target:GetBoneName( bone ) == "ValveBiped.Bip01_Head1" or target:GetBoneName( bone ) == "ValveBiped.HC_Body_Bone" or target:GetBoneName( bone ) == "ValveBiped.HC_BodyCube" or target:GetBoneName( bone ) == "ValveBiped.Headcrab_Cube1" then
				
				local mins, maxs = target:GetHitBoxBounds( hitbox, group )
				local pos, rot = target:GetBonePosition( bone )
				
				local center = (mins + maxs) / 2
				
				center = LocalToWorld( center, Angle(0, 0, 0), pos, rot )
				--print ("Mins is ", mins, "Maxs is ", maxs)
				
				debugoverlay.Sphere( center, 3, 0, Color( 255, 255, 255, 0 ), true )
				
				return center
			end
		end
	end
	
	if target:IsPlayer() then
		return target:EyePos()
	else
		return target:GetPos()
	end
end

function plymeta:GetTaskName()
	local humanNames = { 
	"GOTO_ARSENAL",
	"MELEE_ZOMBIES",
	"HEAL_TEAMMATE", 
	"PLACE_RESUPPLY", 
	"WANDER_AROUND", 
	"REPAIR_CADES", 
	"GOTO_CADING_PROP", 
	"MAKE_CADE", 
	"RESUPPLY_AMMO", 
	"PICKUP_LOOT", 
	"DEFEND_CADE", 
	"SNIPING", 
	"FOLLOW",
	"SPAWNKILL_ZOMBIES"
	}
	
	local zombieNames = {
	"GOTO_HUMANS", 
	"HIDE_FROM_HUMANS"
	}
	
	if self:Team() != TEAM_UNDEAD then
		if humanNames[self.Task] != nil then
			return humanNames[self.Task]
		else
			return tostring(self.Task)
		end
	else
		if zombieNames[self.Task] != nil then
			return zombieNames[self.Task]
		else
			return tostring(self.Task)
		end
	end
end

function plymeta:GetDispositionName()
	local names = {
	"ENGAGE_AND_INVESTIGATE",
	"OPPORTUNITY_FIRE",
	"SELF_DEFENSE",
	"IGNORE_ENEMIES"
	}
	
	if names[self.Disposition] != nil then
		return names[self.Disposition]
	else
		return tostring(self.Disposition)
	end
end

function CloseToPointCheck( bot, curgoalPos, goalPos, cmd, lookAtPoint, crouchJump )
	if lookAtPoint == nil then
		lookAtPoint = true
	end
	if crouchJump == nil then
		crouchJump = true
	end
	
	if !IsValid( bot.FollowerEnt.P ) then return end
	
	if IsValid(bot.FollowerEnt.TargetEnemy) then
		if bot.lookAngle == (bot:AimPoint( bot.FollowerEnt.TargetEnemy ) - bot:EyePos()):Angle() then 
			lookAtPoint = false
		end
	end
	
	if crouchJump then
	
		if bot.cJumpDelay < 1 then
			bot.cJumpDelay = bot.cJumpDelay + FrameTime()
		end
		
		if bot.cJumpDelay >= 1 then
			if bot:GetVelocity():Length() < 40 then
				bot.cJumpTimer = true
			end
			
			--debugoverlay.Box( bot:GetPos() + Vector( bot.tangoy:Forward() ) * 25, Vector( -7.5, -7.5, bot:OBBMins().z + 7.5 ), Vector( 7.5, 7.5, bot:OBBMaxs().z - 7.5 ), 0, Color( 255, 255, 255 ) )
			
			
			--local th = util.TraceHull( {
				--start = bot:GetPos() + Vector( bot.tangoy:Forward() ) * 25,
				--endpos = bot:GetPos() + Vector( bot.tangoy:Forward() ) * 25,
				--mins = Vector( -7.5, -7.5, bot:OBBMins().z + 7.5 ),
				--maxs = Vector( 7.5, 7.5, bot:OBBMaxs().z - 7.5 ),
				--filter = function( ent ) if ( ent != bot and ent:GetClass() != "player" and ent:GetClass() != "func_breakable" ) then return true end end
			--} )
			
			--if th.Hit then
				--bot.cJumpTimer = true
			--end
		end
	end
	
	if lookAtPoint then
		if #bot.FollowerEnt.P:GetAllSegments() <= 2 then
			bot:LookatPosXY( cmd, goalPos )
		else
			bot:LookatPosXY(cmd, curgoalPos )
		end
	end
	
	if #bot.FollowerEnt.P:GetAllSegments() <= 2 then
		MoveToPosition(bot, goalPos, cmd)
	else
		MoveToPosition(bot, curgoalPos, cmd)
	end
end

function plymeta:DoLadderMovement (cmd, curgoal)
	if self.b then 
		self.moveType = 0
		self.cJumpDelay = 0
		cmd:SetButtons( IN_FORWARD ) 
		
		local curgoalposXY = (Vector (curgoal.pos.x, curgoal.pos.y, 0) - Vector (self:EyePos().x, self:EyePos().y, 0)):Angle()
		
		self.lookAngle = Angle (-20, curgoalposXY.y, self:EyeAngles().z)
		
		--self.lookAngle = ((curgoal.pos - self:GetPos()):Angle())
	end
									
	if self.canGetOffLadderTimer then
		self.canGetOffLadderTimer = false
		timer.Simple (5,function() 
			if !IsValid(self) then return end
			self.b = false
			self.useHold = true
			timer.Simple (0.05,function() 
				if !IsValid(self) then return end
				self.useHold = false
				self.canGetOffLadderTimer = true
				timer.Simple (0.05,function() 
					if !IsValid(self) then return end
					if self:GetMoveType() == MOVETYPE_LADDER then
						if !IsValid(self) then return end
						self.jumpHold = true
						timer.Simple (0.05,function() 
							self.jumpHold = false
						end)
					end
				end)
			end)
		end)
	end
end

function plymeta:DoSpawnStuff( changeClass )
	--RESET SOME VALUES ORELSE BAD THINGS HAPPEN
	if GAMEMODE.ZombieEscape then self.lookDistance = defaultEscapeLookDistance else self.lookDistance = defaultLookDistance end
	
	self.Task = -1
	self.Disposition = IGNORE_ENEMIES
	self.moveType = -1
	self.newPointTimer = 15
	self.runAwayTimer = 0
	
	if self:Team() != TEAM_UNDEAD then
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self:SetPlayerColor(Vector(math.Rand (0, 1), math.Rand (0, 1), math.Rand (0, 1)))
		end)
		
		if GAMEMODE.ZombieEscape then
			self.Task = FOLLOW
			self.Disposition = ENGAGE_AND_INVESTIGATE
		else
			if GAMEMODE:GetWave() != 0 then
				self.Task = GOTO_ARSENAL
				self.Disposition = ENGAGE_AND_INVESTIGATE
				
				timer.Simple( 4, function() 
					if !IsValid(self) then return end
					self:GiveRandomPresetLoadout()
				end)
			else
				timer.Simple(0, function() 
					if !IsValid(self) then return end
					
					local delay = math.Rand( 1, 15 )
					print ("Buy delay for ", self:Name(), "is ", delay)
			
					timer.Simple(delay, function() 
						if !IsValid(self) then return end
						if game.IsObj() then
							self.Task = FOLLOW
							self.Disposition = ENGAGE_AND_INVESTIGATE
						else
							self.Task = WANDER_AROUND
							self.Disposition = ENGAGE_AND_INVESTIGATE
						end
						self:GiveRandomPresetLoadout()
					end)
				end)
			end
		end
	else
		self.Task = GOTO_HUMANS
		
		if changeClass and !game.IsObj() and !GAMEMODE.ZombieEscape then
			self:RerollBotClass()
		end
	end
end

function plymeta:GiveRandomPresetLoadout()
	if !IsValid( self ) then return end
	
	-- 12 default starting loadouts, the rest are custom
	if math.random(1, 13) == 13 then
		local oof = math.random(1, 2)
		if oof == 1 then
			if GAMEMODE.CheckedOut[self:UniqueID()] or GAMEMODE.ZombieEscape then return end
			GAMEMODE.CheckedOut[self:UniqueID()] = true
			
			self:Give("weapon_zs_resupplybox")
			self:Give("weapon_zs_swissarmyknife")
		elseif oof == 2 then
			if GAMEMODE.CheckedOut[self:UniqueID()] or GAMEMODE.ZombieEscape then return end
			GAMEMODE.CheckedOut[self:UniqueID()] = true
	
			self:Give("weapon_zs_hammer")
			self.BuffMuscular = true
			self:DoMuscularBones()
		end
	else
		gamemode.Call("GiveRandomEquipment", self)
	end
end