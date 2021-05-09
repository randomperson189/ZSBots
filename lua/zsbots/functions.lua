--HUMAN TASKS
GOTO_ARSENAL = 1
MELEE_ZOMBIE = 2
HEAL_TEAMMATE = 3
PLACE_DEPLOYABLE = 4
PACK_DEPLOYABLE = 5
RESUPPLY_AMMO = 6
WANDER_AROUND = 7
REPAIR_CADE = 8
PICKUP_CADING_PROP = 9
MAKE_CADE = 10
PICKUP_LOOT = 11
DEFEND_CADE = 12
SNIPING = 13
FOLLOW = 14
SPAWNKILL_ZOMBIES = 15

--ZOMBIE TASKS
GOTO_HUMANS = 1
HIDE_FROM_HUMANS = 2

--DISPOSITIONS
ENGAGE_AND_INVESTIGATE = 1
OPPORTUNITY_FIRE = 2
SELF_DEFENSE = 3
IGNORE_ENEMIES = 4

--MESSAGES
MSG_MEDIC = 0
MSG_BOSS_OUTSIDE = 1

--OTHERS
BIGGER = 1
BIGGER_OR_EQUAL = 2
SMALLER = 3
SMALLER_OR_EQUAL = 4

HAS_AMMO = 1
HAS_NO_AMMO = 2

defaultLookDistance = 1000
defaultEscapeLookDistance = math.huge
defaultRotationSpeed = 5 --was 10

local plymeta = FindMetaTable("Player")
if not plymeta then return end

local entmeta = FindMetaTable("Entity")
if not entmeta then return end

local vecmeta = FindMetaTable("Vector")
if not vecmeta then return end

timer.Create("CadingSpotsFinder", 3, 0, function()
	for i, arsenal in ipairs(ents.FindByClass("prop_arsenalcrate")) do
		
		arsenal:FindCadingSpots(navmesh.GetNearestNavArea( arsenal:GetPos(), false, 99999999999, false, false, TEAM_ANY ))
		
		timer.Simple( 0, function ()
			if !IsValid( bot ) or !IsValid(arsenal) then return end
			
			if arsenal.UnCheckableAreas[1] != nil then
				table.Empty(arsenal.UnCheckableAreas)
			end
			
			table.insert( arsenal.UnCheckableAreas, navmesh.GetNearestNavArea( arsenal:GetPos(), false, 99999999999, false, false, TEAM_ANY ) )
		end )
	end
end)

function plymeta:DoSpectateDebugUI()
	if GetConVar( "zs_bot_debug_spectator" ):GetInt() == 0 then return end

	for i, ply in ipairs(player.GetHumans()) do
		if ply.FSpectatingEnt == self then
		
			local FE = self.Pathfinder
			local daPos = nil
			local daName = nil

			if self.Task == GOTO_ARSENAL then
				if self:Team() != TEAM_UNDEAD then
					if IsValid( FE.TargetArsenal ) then
						daPos = FE.TargetArsenal:GetPos()
						daName = FE.TargetArsenal
					end
				elseif IsValid( FE.TargetEnemy ) then
					daPos = FE.TargetEnemy:GetPos()
					daName = FE.TargetEnemy
				end
			end

			if self.Task == MELEE_ZOMBIE then
				if self:Team() != TEAM_UNDEAD then
					if IsValid( FE.TargetEnemy ) then
						daPos = FE.TargetEnemy:GetPos()
						daName = FE.TargetEnemy
					end
				elseif FE.TargetPosition != nil then
					daPos = FE.TargetPosition
					daName = FE.TargetPosition
				end
			end

			if self.Task == FOLLOW then
				if IsValid( FE.TargetTeammate ) then 
					daPos = FE.TargetTeammate:GetPos()
					daName = FE.TargetTeammate
				end
			end

			if self.Task == HEAL_TEAMMATE then
				if IsValid( FE.TargetHealing ) then 
					daPos = FE.TargetHealing:GetPos()
					daName = FE.TargetHealing
				end
			end

			if FE.TargetPosition != nil then
				if self.Task == WANDER_AROUND or self.Task == SNIPING then
					daPos = FE.TargetPosition
					daName = FE.TargetPosition
				end
			end

			if IsValid( FE.TargetNailedProp ) and self.Task == REPAIR_CADE then
				daPos = FE.TargetNailedProp:GetPos()
				daName = FE.TargetNailedProp
			end

			if IsValid( FE.TargetCadingProp ) and self.Task == PICKUP_CADING_PROP then
				daPos = FE.TargetCadingProp:GetPos()
				daName = FE.TargetCadingProp
			end

			if FE.TargetCadingSpot != nil then 
				if self.Task == MAKE_CADE or self.Task == DEFEND_CADE or self.Task == PLACE_DEPLOYABLE then
					daPos = FE.TargetCadingSpot
					daName = FE.TargetCadingSpot
				end
			end

			if IsValid( FE.TargetResupply ) and self.Task == RESUPPLY_AMMO then
				--if self:GetPos():QuickDistanceCheck( FE.TargetResupply:GetPos(), BIGGER, 100 ) then
					daPos = FE.TargetResupply:GetPos()
					daName = FE.TargetResupply
				--end
			end

			if IsValid( FE.TargetLootItem ) and self.Task == PICKUP_LOOT then
				daPos = FE.TargetLootItem:GetPos()
				daName = FE.TargetLootItem
			end
			
			if daPos != nil then debugoverlay.Cross(daPos, 7.5, 0, Color( 255, 255, 0, 255 ), true) end
			
			debugoverlay.ScreenText( 0.55, 0.28, "Name: " .. self:Name(), 0, Color(255, 255, 255) )
			debugoverlay.ScreenText( 0.55, 0.3, "Health: " .. self:Health(), 0, Color(255, 255, 0))
			
			if IsValid(self:GetActiveWeapon()) then
				debugoverlay.ScreenText( 0.55, 0.32, "Weapon: " .. tostring(self:GetActiveWeapon():GetClass()), 0, Color(255, 255, 255) )
				
				if self:GetActiveWeapon():GetPrimaryAmmoType() != -1 then
					debugoverlay.ScreenText( 0.55, 0.34, "Ammo: " .. self:GetActiveWeapon():Clip1() .. "/" .. self:GetAmmoCount(self:GetActiveWeapon():GetPrimaryAmmoType()), 0, Color(255, 255, 0))
				end
			end
			
			debugoverlay.ScreenText( 0.55, 0.38, "Skill: " .. self.Skill .. "%", 0, Color(255, 255, 255))
			
			--[[if self:Team() == TEAM_HUMAN and self.Task == PICKUP_LOOT and IsValid(self.Pathfinder.TargetLootItem) then
				debugoverlay.Box(self.Pathfinder.TargetLootItem:GetPos(), self.Pathfinder.TargetLootItem:OBBMins(), self.Pathfinder.TargetLootItem:OBBMaxs(), 0, Color( 255, 255, 0, 0 ))
				debugoverlay.ScreenText( 0.55, 0.44, "Target: " .. tostring(self.Pathfinder.TargetLootItem), 0, Color(255, 255, 0))
			end]]
			
			if !self.Attacking then
				debugoverlay.ScreenText( 0.55, 0.4, "Task: " .. self:GetTaskName(), 0, Color(0, 255, 0))
				debugoverlay.ScreenText( 0.55, 0.42, "Disposition: " .. self:GetDispositionName(), 0, Color(100, 100, 255))
				if daName != nil then debugoverlay.ScreenText( 0.55, 0.44, "Target: " .. tostring(daName), 0, Color(255, 255, 0)) end
			elseif IsValid(self.Pathfinder.TargetEnemy) then
				debugoverlay.ScreenText( 0.55, 0.4, "ATTACKING: " .. self.Pathfinder.TargetEnemy:Name(), 0, Color(255, 0, 0))
			end
			
			debugoverlay.ScreenText( 0.55, 0.54, "Steady view = " .. "N/A", 0, Color(255, 255, 0))
			debugoverlay.ScreenText( 0.55, 0.56, "Nearby friends = " .. self.nearbyFriends, 0, Color(102, 254, 100))
			debugoverlay.ScreenText( 0.55, 0.58, "Nearby enemies = " .. self.nearbyEnemies, 0, Color(254, 100, 100))
			debugoverlay.ScreenText( 0.55, 0.6, "Nav Area: " .. tostring(navmesh.GetNavArea( self:EyePos(), math.huge )), 0, Color(255, 255, 255))
		end
	end
end

function vecmeta:QuickDistanceCheck( otherVector, checkType, dist )
	if checkType == 1 then
		return self:DistToSqr(otherVector) > (dist * dist)
	elseif checkType == 2 then
		return self:DistToSqr(otherVector) >= (dist * dist)
	elseif checkType == 3 then
		return self:DistToSqr(otherVector) < (dist * dist)
	elseif checkType == 4 then
		return self:DistToSqr(otherVector) <= (dist * dist)
	end
	
	return nil
end

function plymeta:BreakableCheck() --Hold the attack button when a func_breakable is infront of them
	if !IsValid(ply) then return end
	
	if GetConVar( "zs_bot_debug_attack" ):GetInt() == 1 then debugoverlay.Box( ply:EyePos() + ply:EyeAngles():Forward() * 35, Vector(-25, -25, -25), Vector(25, 25, 25), 0, Color( 255, 255, 255, 0 ) ) end
	
	local atr = util.TraceHull( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * 35,
		mins = Vector(-25, -25, -25),
		maxs = Vector(25, 25, 25),
		ignoreworld = true,
		filter = function( ent ) if ( string.find(ent:GetClass(), "func_breakable") ) then return true end end
	} )
	
	if IsValid(atr.Entity) then
		ply.attackTimer = true
	end
end

function plymeta:SetBotControlling( controlling )
	if self:IsBot() then return end
	
	if controlling then
		if !self.IsZSBot2 then
			print ( "Started bot controlling " .. self:Name() )
			self:SetBotValues()
			self.IsZSBot2 = true
			self:SetTask( GOTO_ARSENAL )
		end
	else
		if self.IsZSBot2 then
			print ( "Stopped bot controlling " .. self:Name() )
			self.IsZSBot2 = false
			if IsValid(self.Pathfinder) then self.Pathfinder:Remove() end
		end
	end
end

function plymeta:SetTask( task )
	self.Task = task
	
	if IsValid(self.Pathfinder) then self.Pathfinder:NavCheck() end
end

function plymeta:SetLookAt( position )
	self.lookAngle = (position - self:EyePos()):Angle()
end

function plymeta:DispositionCheck( cmd, enemy )
	if self.Disposition == IGNORE_ENEMIES or self:Team() == TEAM_UNDEAD or !IsValid(enemy) or !enemy:Alive() or self:GetMoveType() == MOVETYPE_LADDER then return end
	
	local tr = util.TraceLine( {
		start = self:EyePos(),
		endpos = self:AimPoint( self.Pathfinder.TargetEnemy ),
		mask = MASK_SHOT,
		filter = function( ent ) if ( ent != self.Pathfinder.TargetEnemy and ent != self and !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
	} )
	
	if self.Disposition == ENGAGE_AND_INVESTIGATE then --ENGAGE_AND_INVESTIGATE
		if self:GetPos():QuickDistanceCheck( self.Pathfinder.TargetEnemy:GetPos(), SMALLER_OR_EQUAL, self.lookDistance ) then
			if !tr.Hit then
				self:SetLookAt(self:AimPoint( self.Pathfinder.TargetEnemy ))
				
				self:ShootAtTarget()
			end
		else
			
		end
	elseif self.Disposition == OPPORTUNITY_FIRE then --OPPORTUNITY_FIRE
		if self:GetPos():QuickDistanceCheck( self.Pathfinder.TargetEnemy:GetPos(), SMALLER_OR_EQUAL, self.lookDistance ) then
			if !tr.Hit then
				self:SetLookAt(self:AimPoint( self.Pathfinder.TargetEnemy ))
				
				if self.Skill > 25 and IsValid(self:GetActiveWeapon()) then
					if self:GetActiveWeapon():GetNextSecondaryFire() <= CurTime() then
						self.attack2Hold = true
					end
				end
				
				self:ShootAtTarget()
			end
		else
			
		end
	elseif self.Disposition == SELF_DEFENSE then --SELF_DEFENSE
		
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
	
	-----------------------------------------------------------------------------------------
	
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
	
	-----------------------------------------------------------------------------------------
	
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
	
	-----------------------------------------------------------------------------------------
	
	if self.canAttack2Timer then
		if self.attack2Timer then
			self.canAttack2Timer = false
			
			self.attack2Hold = true
			
			timer.Simple (0.1, function()
				if !IsValid (self) then return end
				self.attack2Timer = false
				self.canAttack2Timer = true
			end)
		end
	end
	
	-----------------------------------------------------------------------------------------
	
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
					self.lookAngle = Angle (0, self:EyeAngles().y, self:EyeAngles().z)
					timer.Simple (0.5, function()
						if !IsValid (self) then return end
						self:SetTask( GOTO_ARSENAL )
						self.deployTimer = false --comment this out if things no work properly
						self.canDeployTimer = true
					end)
				end)
			end)
		end
	end
	
	-----------------------------------------------------------------------------------------
	
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
					
					if self:GetVelocity():Length() < 10 and self.moveType != -1 then
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
	
	-----------------------------------------------------------------------------------------
	
	if self.canExitLadderCheck and self.exitLadderCheck then
		self.canExitLadderCheck = false
		
		self.lastPos = self:GetPos()
		
		timer.Simple (0.1, function()
			if !IsValid(self) then return end
			
			if self:GetPos() == self.lastPos then	
				self.useHold = true
				
				timer.Simple (0.05,function() 
					if !IsValid(self) then return end
					if self:GetMoveType() == MOVETYPE_LADDER then
						if !IsValid(self) then return end
						self.jumpHold = true
					end
				end)
			end
			
			self.exitLadderCheck = false
			self.canExitLadderCheck = true
		end)
	end
end

function plymeta:InputCheck(cmd)
	if self:IsFrozen() then 
		self.moveType = -1
		self.cJumpDelay = 0
		
		return
	end
	
	if self.moveType == -1 then
		self.cJumpDelay = 0
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 0 then
		cmd:SetForwardMove( 20000 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 1 then
		cmd:SetForwardMove( 20000 )
		cmd:SetSideMove( -20000 )
	elseif self.moveType == 2 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( -20000 )
	elseif self.moveType == 3 then
		cmd:SetForwardMove( -20000 )
		cmd:SetSideMove( -20000 )
	elseif self.moveType == 4 then
		cmd:SetForwardMove( -20000 )
		cmd:SetSideMove( 0 )
	elseif self.moveType == 5 then
		cmd:SetForwardMove( -20000 )
		cmd:SetSideMove( 20000 )
	elseif self.moveType == 6 then
		cmd:SetForwardMove( 0 )
		cmd:SetSideMove( 20000 )
	elseif self.moveType == 7 then
		cmd:SetForwardMove( 20000 )
		cmd:SetSideMove( 20000 )
	end

	if self.strafeType == 0 then
		cmd:SetSideMove( 20000 )
	elseif self.strafeType == 1 then
		cmd:SetSideMove( -20000 )
	else
		--cmd:SetSideMove( 0 )
	end
	
--------------------------------------------------
	
	local forward = 0
	local attack = 0
	local attack2 = 0
	local reload = 0
	local jump = 0
	local crouch = 0
	local use = 0
	local zoom = 0
	local sprint = 0
	
	if self:GetMoveType() != MOVETYPE_LADDER then self.forwardHold = false end
	if self.forwardHold then
		forward = IN_FORWARD
	end
	
	if self.backHold then
		back = IN_BACK
	end
	if self.leftHold then
		left = IN_MOVELEFT
	end
	if self.rightHold then
		right = IN_MOVERIGHT
	end
	
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
	if self.crouchHold or self.crouchHoldOnce then
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
		
		--[[timer.Simple(0, function()
			if !IsValid(self) then return end
			
			self.sprintHold = false
		end)]]
	end
	
	cmd:SetButtons(bit.bor( forward, attack, attack2, reload, jump, crouch, use, zoom, sprint ))
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
		local msgs = {bot.Pathfinder.TargetEnemy:GetZombieClassTable().Name .. " outside.", bot.Pathfinder.TargetEnemy:GetZombieClassTable().Name .. " is outside the cade."}
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

function plymeta:LookatPosXY( cmd, pos, forward )
	if forward == nil then forward = false end
	local theAngle = nil
	
	if forward then
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

	for i, bot in ipairs(player.GetAll()) do
		if bot.IsZSBot2 then
			table.insert( zsbots, bot )
		end
	end
	
	return zsbots
end

function CountNearbyFriends( thisEnt, radius )
	local tbl = {  }
	
	for i, friend in ipairs( ents.FindInSphere(thisEnt:EyePos(), radius) ) do
		if friend:IsPlayer() and friend:Team() == thisEnt:Team() and friend:Alive() and friend != thisEnt then
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = thisEnt:AimPoint( friend ),
				mask = MASK_SHOT,
				filter = function( ent ) if ( !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") ) then return true end end
			} )
			
			if !tr.Hit then
				table.insert(tbl, friend)
			end
		end
	end
	
	return #tbl
end

--------------FIND NEAREST--------------------------------------
function FindNearestEnemy( className, thisEnt )
	
	local nearestEnt
	local range = math.huge
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( entity:GetPos() )
        if ( distance <= range and entity != thisEnt and entity:Team() != thisEnt:Team() and entity:Alive() and entity:GetZombieClassTable().Name != "Crow" ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function AnEnemyIsInSight(className, thisEnt)
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
		if ( entity != thisEnt and entity:Team() != thisEnt:Team() and entity:Alive() and entity:GetZombieClassTable().Name != "Crow" ) then
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = thisEnt:AimPoint(entity),
				filter = function( ent ) if ( !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") and !ent.IsBarricadeObject ) then return true end end
			} )
			
			if !tr.Hit then
				return true
			end
		end
    end 
	
    return false
end

function FindNearestEnemyInSight( className, thisEnt, seeThruTrans )
	
	if seeThruTrans == nil then seeThruTrans = true end
	
	local nearestEnt
	local range = math.huge
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( entity:GetPos() )
		
        if ( distance <= range and entity != thisEnt and entity:Team() != thisEnt:Team() and entity:Alive() and entity:GetZombieClassTable().Name != "Crow" ) then
			
			if seeThruTrans then
				local tr = util.TraceLine( {
					start = thisEnt:EyePos(),
					endpos = thisEnt:AimPoint(entity),
					mask = MASK_SHOT,
					filter = function( ent ) if ( !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") and !ent.IsBarricadeObject ) then return true end end
				} )
				
				if !tr.Hit  then
					nearestEnt = entity
					range = distance
				end
			else
				local tr = util.TraceLine( {
					start = thisEnt:EyePos(),
					endpos = thisEnt:AimPoint(entity),
					filter = function( ent ) if ( !ent:IsPlayer() and !string.find(ent:GetClass(), "prop_physics") and !string.find(ent:GetClass(), "func_breakable") and !ent.IsBarricadeObject ) then return true end end
				} )
				
				if !tr.Hit  then
					nearestEnt = entity
					range = distance
				end
			end
        end 
    end 
    return nearestEnt
end

function FindNearestEntity( className, thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range ) then
        
            nearestEnt = ent
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestTeammate( className, thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range and ent != thisEnt and ent:Team() == thisEnt:Team() and ent:Alive() and ent:GetZombieClassTable().Name != "Crow" ) then
        
            nearestEnt = ent
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestHealTarget( className, thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range and ent != thisEnt and ent:Team() == thisEnt:Team() and ent:Alive() and ent:Health() <= (3 / 4 * ent:GetMaxHealth()) ) then
        
            nearestEnt = ent
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestPlayerTeammate( className, thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range and ent != thisEnt and !ent:IsBot() and ent:Alive() and ent:Team() == thisEnt:Team() ) then
        
            nearestEnt = ent
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestProp( thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range ) then
        	if string.find(ent:GetClass(), "prop_physics") then
        		if !ent:IsNailed() then
					nearestEnt = ent
					range = distance
            	end
            end
        end 
    end 
    return nearestEnt
end

function FindNearestPropOrBreakable( thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range ) then
        	if string.find(ent:GetClass(), "prop_physics") or string.find(ent:GetClass(), "func_breakable") or ent:GetClass() == "func_door_rotating" then
            	nearestEnt = ent
            	range = distance
            end
        end 
    end 
    return nearestEnt
end

function FindNearestNailedPropOrBreakable( thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range ) then
        	if string.find(ent:GetClass(), "prop_physics") then
        		if ent:IsNailed() then
            		nearestEnt = ent
            		range = distance
            	end
            end
            if string.find(ent:GetClass(), "func_breakable") then
            	nearestEnt = ent
            	range = distance
            end
        end 
    end 
    return nearestEnt
end

function FindNearestNailedProp( thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
        if ( distance <= range ) then
        	if string.find(ent:GetClass(), "prop_physics") then
        		if ent:IsNailed() then
					if ent:GetBarricadeHealth() < ent:GetMaxBarricadeHealth() and ent:GetBarricadeRepairs() > 0 then
						nearestEnt = ent
						range = distance
					end
            	end
            end
        end 
    end 
    return nearestEnt
end

function FindNearestLoot( thisEnt )

	local nearestEnt
	local range = math.huge
    
    for i, ent in ipairs( ents.FindInSphere( thisEnt:GetPos(), 550 ) ) do 
    	local distance = thisEnt:GetPos():DistToSqr( ent:GetPos() )
		if ( distance <= range ) then
			if IsValid( thisEnt:GetActiveWeapon() ) then
				if ent:GetClass() == "prop_weapon" then
					if !IsValid (thisEnt:GetWeapon(ent:GetWeaponType())) then
						nearestEnt = ent
						range = distance
					end
					
				elseif ent:GetClass() == "prop_ammo" then
					nearestEnt = ent
					range = distance
				end
				
			elseif ent:GetClass() == "prop_weapon" or ent:GetClass() == "prop_ammo" then
				nearestEnt = ent
				range = distance
			end
		end
    end 
    return nearestEnt
end

function FindNearestHidingSpot( thisEnt )
	local nearestSpot
	local range = math.huge
    
    for i, area in ipairs( navmesh:GetAllNavAreas( thisEnt:GetPos(), 0 ) ) do 
		for i2, spot in ipairs( area:GetHidingSpots() ) do
			local distance = thisEnt:GetPos():DistToSqr( spot )
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = Vector(spot.x, spot.y, spot.z + (thisEnt:EyePos().z - thisEnt:GetPos().z)),
				mask = MASK_SHOT,
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

function FindNearestSniperSpot( thisEnt )
	local nearestSpot
	local range = math.huge
    
    for i, area in ipairs( navmesh:GetAllNavAreas( thisEnt:GetPos(), 0 ) ) do 
		for i2, spot in ipairs( area:GetExposedSpots() ) do
			local distance = thisEnt:GetPos():DistToSqr( spot )
			
			local tr = util.TraceLine( {
				start = thisEnt:EyePos(),
				endpos = Vector(spot.x, spot.y, spot.z + (thisEnt:EyePos().z - thisEnt:GetPos().z)),
				mask = MASK_SHOT,
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
	local myAngle = bot:EyeAngles().y
	
	if myAngle > 360 then
		myAngle = myAngle - 360
	end
	if myAngle < 0 then
		myAngle = myAngle + 360
	end
	
	local angleAround = vec - myAngle
	
	if angleAround > 360 then
		angleAround = angleAround - 360
	end
	if angleAround < 0 then
		angleAround = angleAround + 360
	end
	
	--print ("my eye angles", myAngle, "the angle", vec, "the angle around", angleAround)
	
	if angleAround <= 22.5 or angleAround > 337.5 then
		bot.moveType = 0
		--print ("Forward")
	end
	if angleAround > 22.5 and angleAround <= 67.5 then
		bot.moveType = 1
		--print ("Forward Left")
	end
	if angleAround > 67.5 and angleAround <= 112.5 then
		bot.moveType = 2
		--print ("Left")
	end
	if angleAround > 112.5 and angleAround <= 157.5 then
		bot.moveType = 3
		--print ("Left Back")
	end
	if angleAround > 157.5 and angleAround <= 202.5 then
		bot.moveType = 4
		--print ("Back")
	end
	if angleAround > 202.5 and angleAround <= 247.5 then
		bot.moveType = 5
		--print ("Back Right")
	end
	if angleAround > 247.5 and angleAround <= 292.5 then
		bot.moveType = 6
		--print ("Right")
	end
	if angleAround > 292.5 and angleAround <= 337.5 then
		bot.moveType = 7
		--print ("Forward Right")
	end
end

function plymeta:GetOtherWeapon(ammoCheck)
	if ammoCheck == nil then ammoCheck = 0 end
	
	local daWep = nil
	
	for i, wep in ipairs(self:GetWeapons()) do 
		if wep != self:GetActiveWeapon() then
			if ammoCheck == HAS_AMMO then
				if wep:Clip1() > 0 or self:GetAmmoCount( wep:GetPrimaryAmmoType() ) > 0 then
					if !wep.IsMelee and !wep.Primary.Heal and !wep.AmmoIfHas and wep:GetPrimaryAmmoType() != -1 then
						daWep = wep
						
						break
					end
				end
			elseif ammoCheck == HAS_NO_AMMO then
				if wep:Clip1() <= 0 or self:GetAmmoCount( wep:GetPrimaryAmmoType() ) <= 0 then
					if !wep.IsMelee and !wep.Primary.Heal and !wep.AmmoIfHas and wep:GetPrimaryAmmoType() != -1 then
						daWep = wep
						
						break
					end
				end
			else
				daWep = wep
			end
		end
	end
	
	return daWep
end

function CheckNavMeshAttributes( bot, cmd )
	
	local navArea = navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY )
	if !IsValid(navArea) then return end
	
	if navArea:GetAttributes() == NAV_MESH_CROUCH then
		bot.crouchHoldOnce = true
	elseif navArea:GetAttributes() == NAV_MESH_JUMP then
		bot.cJumpTimer = true
		
		bot.prevJumpNav = true
		bot.moveBack = false
	elseif !bot:OnGround() then
		if bot.prevJumpNav then
			bot.moveBack = true
		else
			bot.moveBack = false
		end
	else
		bot.prevJumpNav = false
		bot.moveBack = false
	end
end

function entmeta:FindCadingSpots( centerArea )
	if self.UnCheckableAreas == nil then self.UnCheckableAreas = {} end
	if self.DefendingSpots == nil then self.DefendingSpots = {} end
	
	if table.HasValue( self.UnCheckableAreas, centerArea ) or !IsValid( centerArea) then return end
	
	local northConnectedAreas = centerArea:GetAdjacentAreasAtSide(0)
	local southConnectedAreas = centerArea:GetAdjacentAreasAtSide(2)
	local eastConnectedAreas = centerArea:GetAdjacentAreasAtSide(1)
	local westConnectedAreas = centerArea:GetAdjacentAreasAtSide(3)
	
	--PrintTable (self.UnCheckableAreas)
	if GetConVar( "zs_bot_debug_defending_spots" ):GetInt() == 1 then print ("Checking around " .. tostring(centerArea) .. " for cading spots.") end
	
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
		
		--SET THE VALUES OF THE BOT
		ply:SetBotValues()
		
		--DO STUFF ON SPAWN LIKE CHOOSING LOADOUTS, CHANGING CLASS, ETC
		ply:DoSpawnStuff( false )
	else
		MsgC( Color( 255, 255, 255 ), "Failed to create ZSBot.\n" )
	end
end

function plymeta:SetBotValues()
	--FUNCTION DELAYS
	self.targetFindDelay = CurTime()
	
	--TIMERS
	self.guardTimer = math.random( 5, 10 )
	self.runAwayTimer = 0
	self.newPointTimer = 15
	self.giveUpTimer = 0
	--self.lookAroundTimer = 0
	--self.rotationTimer = 0
	
	--BOT NAVIGATOR
	if !IsValid(self.Pathfinder) then
		self.Pathfinder = ents.Create( "sent_zsbot_pathfinder" )
		self.Pathfinder:Spawn()
		self.Pathfinder.Bot = self
	end
	
	--OTHER STUFF
	self.LastPath = nil
	self.lastPos = vector_origin
	self.lookProp = nil
	self.lookPos = nil
	self.lookDistance = 1000
	self.cJumpDelay = 0
	self.strafeType = -1 -- 0 = left, 1 = right, 2 = back
	self.moveType = -1	-- -1 = stop, 0 = f, 1 = fl, 2 = l, 3 = lb, 4 = b, 5 = br, 6 = r, 7 = fr
	self.shouldGoOutside = false
	self.onlyFollowPlayers = false
	self.prevJumpNav = false
	self.moveBack = false
	
	--UNUSED THINGIES I MIGHT REMOVE XD
	--[[self.stopVel = 40
	self.canRaycast = true]]
	
	--self.State = 0 -- Idle, Hunt, MoveTo, Buy, Hide
	--self.stateName = "NONE"
	self.Attacking = false
	self.Task = 0
	self.Disposition = IGNORE_ENEMIES -- ENGAGE_AND_INVESTIGATE, OPPORTUNITY_FIRE, SELF_DEFENSE, IGNORE_ENEMIES
	self.Skill = math.random(0, 100)
	--self.Morale = 0 -- EXCELLENT, GOOD, POSITIVE, NEUTRAL, NEGATIVE, BAD, TERRIBLE
	--self.moraleName = "NONE"
	self.nearbyFriends = 0
	self.nearbyEnemies = 0
	
	--NAV AREAS
	--[[self.DefendingSpots = {  }
	self.CadingSpots = {  }
	self.UnCheckableAreas = {  }]]
	
	--CHAT MESSAGES
	self.sayMessage = ""
	self.sayTeamMessage = ""
	
	self.prevSay = -1
	
	--INPUT TIMERS
	self.canExitLadderCheck = true
	self.exitLadderCheck = false
	
	self.canCJumpTimer = true
	self.cJumpTimer = false
	
	self.canUseTimer = true
	self.useTimer = false
	
	self.canAttackTimer = true
	self.attackTimer = false
	
	self.canAttack2Timer = true
	self.attack2Timer = false
	
	self.canDeployTimer = true
	self.deployTimer = false
	
	self.canZoomTimer = true
	self.zoomTimer = false
	
	--INPUT VALUES
	self.forwardHold = false
	self.attackHold = false
	self.attack2Hold = false
	self.reloadHold = false
	self.jumpHold = false
	self.crouchHold = false
	self.crouchHoldOnce = false
	self.useHold = false
	self.zoomHold = false
	self.sprintHold = false
	
	--SMOOTH ROTATION
	self.lookAngle = Angle(0, 0, 0)
	self.rotationSpeed = 5
	self.angle = Angle(0, 0, 0)
end

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

function plymeta:LootCheck()
	
	if self.giveUpTimer > 0 then self.giveUpTimer = self.giveUpTimer - FrameTime() end
	
	if GetConVar( "zs_bot_can_pick_up_loot" ):GetInt() != 0 and IsValid( self.Pathfinder.TargetLootItem ) and !IsValid( self.Pathfinder.TargetEnemy ) and self.giveUpTimer <= 0 then
		local lootTrace = util.TraceLine( {
			start = self:EyePos(),
			endpos = self.Pathfinder.TargetLootItem:LocalToWorld(self.Pathfinder.TargetLootItem:OBBCenter()),
			mask = MASK_SHOT,
			filter = function( ent ) if ( ent != self.Pathfinder.TargetLootItem and !ent:IsPlayer() ) then return true end end
		} )
		
		--debugoverlay.Line( self:EyePos(), self.Pathfinder.TargetLootItem:LocalToWorld(self.Pathfinder.TargetLootItem:OBBCenter()), 0, Color( 255, 255, 255 ), false )
		
		--if IsValid (self.Pathfinder.TargetEnemy) then
			if !lootTrace.Hit then
				self.giveUpTimer = math.Rand(5, 7)
				self:SetTask( PICKUP_LOOT )
			end
		--[[else
			if !tr.Hit then
				self:SetTask( PICKUP_LOOT )
			end
		end]]
	end
end

function plymeta:RunAwayCheck( cmd )
	if IsValid (self.Pathfinder.TargetEnemy) then
		self.b = true
		
		if self.runAwayTimer <= 0 then
			if self:GetPos():QuickDistanceCheck( self.Pathfinder.TargetEnemy:GetPos(), SMALLER_OR_EQUAL, 150 ) then
				self.runAwayTimer = math.random(1, 3)
			end
		elseif self.Skill > 50 then
			--print ("running away" .. self.runAwayTimer)
			self.Disposition = IGNORE_ENEMIES
			
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

function plymeta:CheckPropPhasing()
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos(),
		mins = Vector( -18, -18, 0 ),
		maxs = Vector( 18, 18, 73 ),
		ignoreworld = true,
		filter = function( ent ) if ( string.find(ent:GetClass(), "prop_physics") ) then return true end end
	} )
	
	if tr.Entity:IsNailed() then
		--self.cJumpTimer = false
		self.zoomTimer = true
	end
end

function plymeta:ShootAtTarget()
	local skillSteadyShoot = math.Remap( self.Skill, 0, 100, 25, 10 )
	
	local th = util.TraceHull( {
		start = self:EyePos() + self:EyeAngles():Forward() * self:EyePos():Distance(self:AimPoint( self.Pathfinder.TargetEnemy )),
		mins = Vector( -skillSteadyShoot, -skillSteadyShoot, -skillSteadyShoot ),
		maxs = Vector( skillSteadyShoot, skillSteadyShoot, skillSteadyShoot ),
		ignoreworld = true,
		filter = function( ent ) if ( ent == self.Pathfinder.TargetEnemy ) then return true end end
	} )
	
	local colour = Color( 255, 0, 0, 0)
	
	if th.Hit then
		self.attackTimer = true
		colour = Color( 0, 255, 0, 0)
	end
	
	if GetConVar( "zs_bot_debug_attack" ):GetInt() == 1 then debugoverlay.Box( self:EyePos() + self:EyeAngles():Forward() * self:EyePos():Distance(self:AimPoint( self.Pathfinder.TargetEnemy )), Vector( -skillSteadyShoot, -skillSteadyShoot, -skillSteadyShoot ), Vector( skillSteadyShoot, skillSteadyShoot, skillSteadyShoot ), 0, colour ) end
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
				
				--debugoverlay.Sphere( center, 3, 0, Color( 255, 0, 0, 0 ), true )
				
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
	"MELEE_ZOMBIE",
	"HEAL_TEAMMATE", 
	"PLACE_DEPLOYABLE",
	"PACK_DEPLOYABLE",
	"RESUPPLY_AMMO",
	"WANDER_AROUND", 
	"REPAIR_CADE", 
	"PICKUP_CADING_PROP", 
	"MAKE_CADE", 
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
	
	if !IsValid( bot.Pathfinder.P ) then return end
	
	if bot.moveBack then
		bot.moveType = 4
		return
	end
	
	if IsValid(bot.Pathfinder.TargetEnemy) then
		if bot.lookAngle == (bot:AimPoint( bot.Pathfinder.TargetEnemy ) - bot:EyePos()):Angle() then 
			lookAtPoint = false
		end
	end
	
	bot:BreakableCheck()
	
	if crouchJump then
	
		if bot.cJumpDelay < 1 then
			bot.cJumpDelay = bot.cJumpDelay + FrameTime()
		end
		
		if bot.cJumpDelay >= 1 and bot:GetVelocity():Length() < 40 then
			bot.cJumpTimer = true
		end
	end
	
	if lookAtPoint then
		if #bot.Pathfinder.P:GetAllSegments() <= 2 then
			bot:LookatPosXY( cmd, goalPos )
		else
			bot:LookatPosXY(cmd, curgoalPos )
		end
	end
	
	if #bot.Pathfinder.P:GetAllSegments() <= 2 then
		MoveToPosition(bot, goalPos, cmd)
	else
		MoveToPosition(bot, curgoalPos, cmd)
	end
end

function plymeta:DoLadderMovement (cmd, curgoal)
	self.moveType = 0
	self.forwardHold = true
	self.cJumpDelay = 0
	
	local curgoalposXY = (Vector (curgoal.pos.x, curgoal.pos.y, 0) - Vector (self:EyePos().x, self:EyePos().y, 0)):Angle()
	
	if self:GetPos().z <= curgoal.pos.z then
		self.lookAngle = Angle (-20, curgoalposXY.y, self:EyeAngles().z)
		--GAMEMODE:TopNotify("up")
	else
		self.lookAngle = Angle (40, curgoalposXY.y, self:EyeAngles().z)
		--GAMEMODE:TopNotify("down")
	end
	
	--self:SetLookAt(curgoal.pos)
	
	if self:Team() != TEAM_UNDEAD then self:SetBarricadeGhosting(true) end
	
	if self.lookPos == nil then self.exitLadderCheck = true end
end

function plymeta:DoSpawnStuff( changeClass )
	--RESET SOME VALUES ORELSE BAD THINGS HAPPEN
	if GAMEMODE.ZombieEscape then self.lookDistance = defaultEscapeLookDistance else self.lookDistance = defaultLookDistance end
	
	self:SetTask( 0 )
	self.Disposition = IGNORE_ENEMIES
	self.moveType = -1
	self.newPointTimer = 15
	self.runAwayTimer = 0
	self.giveUpTimer = 0
	
	if self:Team() != TEAM_UNDEAD then
		timer.Simple(0, function()
			if !IsValid(self) then return end
			
			if self:IsBot() then
				self:SetPlayerColor(Vector(math.Rand (0, 1), math.Rand (0, 1), math.Rand (0, 1)))
			end
		end)
		
		if GAMEMODE.ZombieEscape then
			self:SetTask( FOLLOW )
			self.Disposition = ENGAGE_AND_INVESTIGATE
		else
			if GAMEMODE:GetWave() != 0 then
				self:SetTask( GOTO_ARSENAL )
				self.Disposition = ENGAGE_AND_INVESTIGATE
				
				timer.Simple( 4, function() 
					if !IsValid(self) then return end
					gamemode.Call("GiveRandomEquipment", self)
				end)
			else
				timer.Simple(0, function() 
					if !IsValid(self) then return end
					
					local delay = math.Rand( 1, 15 )
					print ("Buy delay for ", self:Name(), "is ", delay)
			
					timer.Simple(delay, function() 
						if !IsValid(self) then return end
						if game.IsObj() then
							self:SetTask( FOLLOW )
						else
							self:SetTask( GOTO_ARSENAL )
						end
						self.Disposition = ENGAGE_AND_INVESTIGATE
						gamemode.Call("GiveRandomEquipment", self)
					end)
				end)
			end
		end
	else
		self:SetTask( GOTO_HUMANS )
		
		if changeClass and !game.IsObj() and !GAMEMODE.ZombieEscape then
			self:RerollBotClass()
		end
	end
end