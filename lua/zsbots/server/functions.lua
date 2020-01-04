TASK_TEST_ONE = 1
TASK_TEST_TWO = 2

function SayPresetMessage(bot, category, teamOnly, target)
	if teamChat == nil then teamChat = false end
	
	if bot.prevSay == category then return end
	if GetConVar( "zs_bot_can_chat" ):GetInt() == 0 then return end
	
	bot.prevSay = category
	target = tostring(target)
	
	local function botSay(bot, msg)
		if teamOnly then
			bot:Say(msg, true)
		else
			bot:Say(msg)
		end
	end 
	
	if category == 0 then
		--Medic messages
		local randMsg = math.random(0, 2)
		
		if randMsg == 0 then
			botSay(bot, "MEDIC!")
		elseif randMsg == 1 then
			botSay(bot, "I need a medic!")
		elseif randMsg == 2 then
			botSay(bot, "I need heals!")
		end
	elseif category == 1 then
		--Boss outside messages
		local randMsg = math.random(0, 1)
		
		if randMsg == 0 then
			botSay(bot, target .. " outside.")
		elseif randMsg == 1 then
			botSay(bot, target .. " is outside the cade.")
		end
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

debug.getregistry().Player.LookatPosXY = function( self, cmd, pos )
	local theAngle = (Vector (pos.x, pos.y, 0) - Vector (self:GetPos().x, self:GetPos().y, 0)):Angle()
	self.lookAngle = Angle( theAngle.x, theAngle.y, 0 )
end

--[[timer.Create( "ZSBotQuotaCheck", 0.5, 0, function ()
	if #GetZSBots() < GetConVar( "zs_bot_quota" ):GetInt() and #player.GetAll() < game.MaxPlayers() then
		CreateZSBot()
	end
	if #GetZSBots() > GetConVar( "zs_bot_quota" ):GetInt() then
		GetZSBots()[#GetZSBots()]:Kick()
	end	
end)]]

function player.GetZSBots()
	local zsbots = {  }

	for i, bot in ipairs(player.GetBots()) do
		if bot.IsZSBot then
			table.insert( zsbots, bot )
		end
	end
	
	return zsbots
end

function FindNearestEntity( className, thisEnt, range )

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

function CountNearbyFriends( bot, radius )
	--debugoverlay.Sphere( bot:EyePos(), radius, 0.5, Color( 255, 255, 255, 0 ), true )
	local tbl = {  }
	
	for i, friend in ipairs( ents.FindInSphere(bot:EyePos(), radius) ) do
		if friend:GetClass() == "player" and friend:Team() == bot:Team() and friend != bot then
			table.insert(tbl, friend)
		end
	end
	
	return #tbl
end

function CountNearbyEnemies( bot, radius )
	local tbl = {  }
	
	for i, enemy in ipairs( ents.FindInSphere(bot:EyePos(), radius) ) do
		if enemy:GetClass() == "player" and enemy:Team() != bot:Team() and enemy != bot then
			table.insert(tbl, enemy)
		end
	end
	
	return #tbl
end

function FindNearestEntity2( className, thisEnt, range )

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

function FindNearestProp2( thisEnt, range )

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

function FindNearestTeammate( className, thisEnt, range )

	local nearestEnt
    
    for i, entity in ipairs( ents.FindByClass( className ) ) do 
    	local distance = thisEnt:GetPos():Distance( entity:GetPos() )
        if ( distance <= range and entity != thisEnt and entity:Team() == thisEnt:Team() and entity:Health() <= (3 / 4 * entity:GetMaxHealth()) ) then
        
            nearestEnt = entity
            range = distance
            
        end 
    end 
    return nearestEnt
end

function FindNearestProp3( thisEnt, range )

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

function GetRandomPositionOnNavmesh( pos, radius, stepdown, stepup )
	local randomPos = pos + Angle(0, math.random(-180, 180), 0):Forward() * math.random(0, radius)
	local posOnNavmesh = navmesh.GetNearestNavArea( randomPos, false, 99999999999, false, false, TEAM_ANY ):GetClosestPointOnArea( randomPos )
	
	return posOnNavmesh
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

	if navmesh.GetNearestNavArea( bot:GetPos(), false, 99999999999, false, false, TEAM_ANY ):GetAttributes() == NAV_MESH_CROUCH then
		if bot.attackHold then
			cmd:SetButtons( bit.bor( IN_DUCK, IN_ATTACK ) )
		elseif bot.jumpHold then
			cmd:SetButtons( bit.bor( IN_DUCK, IN_JUMP ) )
		else
			cmd:SetButtons( IN_DUCK )
		end
	end
	
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

function FindCadingSpotsInArea( bot, centerArea )
	
	if table.HasValue( bot.UnCheckableAreas, centerArea ) or !IsValid( centerArea) then return end
	
	local northConnectedAreas = centerArea:GetAdjacentAreasAtSide(0)
	local southConnectedAreas = centerArea:GetAdjacentAreasAtSide(2)
	local eastConnectedAreas = centerArea:GetAdjacentAreasAtSide(1)
	local westConnectedAreas = centerArea:GetAdjacentAreasAtSide(3)
	
	--PrintTable (bot.UnCheckableAreas)
	print ("Checking around " .. tostring(centerArea) .. " for cading spots")
	
	if !table.HasValue( bot.UnCheckableAreas, centerArea ) then
		table.insert( bot.UnCheckableAreas, centerArea )
	end
	
	for i, area in ipairs(northConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			
			if area:GetAdjacentAreasAtSide(1)[1] == nil and area:GetAdjacentAreasAtSide(3)[1] == nil then
				if !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
					table.insert (bot.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(bot.UnCheckableAreas, area) and !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
				FindCadingSpotsInArea( bot, area )
			end
		end
	end
	
	for i, area in ipairs(southConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(1)[1] == nil and area:GetAdjacentAreasAtSide(3)[1] == nil then
				if !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
					table.insert (bot.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(bot.UnCheckableAreas, area) and !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
				FindCadingSpotsInArea( bot, area )
			end
		end
	end
	
	for i, area in ipairs(eastConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(0)[1] == nil and area:GetAdjacentAreasAtSide(2)[1] == nil then
				if !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
					table.insert (bot.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(bot.UnCheckableAreas, area) and !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
				FindCadingSpotsInArea( bot, area )
			end
		end
	end
	
	for i, area in ipairs(westConnectedAreas) do
		if area:GetSizeX() < centerArea:GetSizeX() and area:GetSizeY() < centerArea:GetSizeY() then
			if area:GetAdjacentAreasAtSide(0)[1] == nil and area:GetAdjacentAreasAtSide(2)[1] == nil then
				if !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
					table.insert (bot.DefendingSpots, area:GetCenter())
				end
			end
		end
		if area:GetSizeX() >= centerArea:GetSizeX() or area:GetSizeY() >= centerArea:GetSizeY() then
			if !table.HasValue(bot.UnCheckableAreas, area) and !table.HasValue(bot.DefendingSpots, area:GetCenter()) then
				FindCadingSpotsInArea( bot, area )
			end
		end
	end
end

function CreateZSBot( name )
	if !game.SinglePlayer() and #player.GetAll() < game.MaxPlayers() and engine.ActiveGamemode() == "zombiesurvival" then
		if name == nil or name == "" then
			local names = {"A Professional With Standards", "AimBot", "AmNot", "Aperture Science Prototype XR7", "Archimedes!", "BeepBeepBoop", "Big Mean Muther Hubbard", "Black Mesa", "BoomerBile", "Cannon Fodder", "CEDA", "Chell", "Chucklenuts", "Companion Cube", "Crazed Gunman", "CreditToTeam", "CRITRAWKETS", "Crowbar", "CryBaby", "CrySomeMore", "C++", "DeadHead", "Delicious Cake", "Divide by Zero", "Dog", "Force of Nature", "Freakin' Unbelievable", "Gentlemanne of Leisure", "GENTLE MANNE of LEISURE ", "GLaDOS", "Glorified Toaster with Legs", "Grim Bloody Fable", "GutsAndGlory!", "Hat-Wearing MAN", "Headful of Eyeballs", "Herr Doktor", "HI THERE", "Hostage", "Humans Are Weak", "H@XX0RZ", "I LIVE!", "It's Filthy in There!", "IvanTheSpaceBiker", "Kaboom!", "Kill Me", "LOS LOS LOS", "Maggot", "Mann Co.", "Me", "Mega Baboon", "Mentlegen", "Mindless Electrons", "MoreGun", "Nobody", "Nom Nom Nom", "NotMe", "Numnutz", "One-Man Cheeseburger Apocalypse", "Poopy Joe", "Pow!", "RageQuit", "Ribs Grow Back", "Saxton Hale", "Screamin' Eagles", "SMELLY UNFORTUNATE", "SomeDude", "Someone Else", "Soulless", "Still Alive", "TAAAAANK!", "Target Practice", "ThatGuy", "The Administrator", "The Combine", "The Freeman", "The G-Man", "THEM", "Tiny Baby Man", "Totally Not A Bot", "trigger_hurt", "WITCH", "ZAWMBEEZ", "Ze Ubermensch", "Zepheniah Mann", "0xDEADBEEF", "10001011101"}
			name = table.Random( names )
		end
		
		ply = player.CreateNextBot( name )
		
		ply.IsZSBot = true
		ply.targetFindDelay = CurTime()
		ply.guardTimer = math.random( 5, 10 )
		ply.runAwayTimer = 0
		--ply.rotationUpdateDelay = CurTime()

		ply.FollowerEnt = ents.Create( "sent_zsbot_pathfinder" )
		ply.FollowerEnt:Spawn()
		ply.FollowerEnt.Bot = ply
		
		ply.LastPath = nil
		ply.attackProp = nil
		ply.lookProp = nil
		ply.lookPos = nil
		ply.lastWeapon = nil
		ply.heldProp = nil
		
		--ply.State = 0 --Idle, Hunt, MoveTo, Buy, Hide
		--ply.stateName = "NONE"
		ply.Task = -1
		ply.taskName = "NONE"
		ply.Disposition = 0 --ENGAGE_AND_INVESTIGATE, OPPORTUNITY_FIRE, SELF_DEFENSE, IGNORE_ENEMIES
		ply.dispositionName = "NONE"
		ply.Skill = math.random(0, 100)
		--ply.Morale = 0 --EXCELLENT, GOOD, POSITIVE, NEUTRAL, NEGATIVE, BAD, TERRIBLE
		--ply.moraleName = "NONE"
		ply.nearbyFriends = 0
		ply.nearbyEnemies = 0
		
		ply.DefendingSpots = {  }
		ply.CadingSpots = {  }
		ply.UnCheckableAreas = {  }
		
		ply.sayMessage = ""
		ply.sayTeamMessage = ""
		
		ply.prevSay = -1
		
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
		
		ply.canLookAroundTimer = true
		ply.lookAroundTimer = false
		
		ply.canZoomTimer = true
		ply.zoomTimer = false
		
		ply.attackHold = false
		ply.attack2Hold = false
		ply.jumpHold = false
		ply.crouchHold = false
		ply.useHold = false
		ply.zoomHold = false
		ply.strafeType = -1 --0 = left, 1 = right, 2 = back
		ply.moveType = -1	-- -1 = stop, 0 = f, 1 = fl, 2 = l, 3 = lb, 4 = b, 5 = br, 6 = r, 7 = fr
		ply.stopVel = 40
		ply.canRaycast = true
		
		ply.shouldGoOutside = false
		ply.canShouldGoOutside = true
		
		ply.lookAngle = Angle(0, 0, 0)
		ply.rotationSpeed = 5 -- was 10
		ply.angle = Angle(0, 0, 0)
		
		DoSpawnStuff( ply, false )
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
				CreateZSBot()
			else
				CreateZSBot( args[2] )
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
				if bot:IsBot() and bot.IsZSBot then
					bot:Kick()
				end
			end
		end
		if argStr == "Humans" or argStr == "humans" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Team() == 4 then
					bot:Kick()
				end
			end
		end
		if argStr == "Zombies" or argStr == "zombies" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Team() == TEAM_UNDEAD then
					bot:Kick()
				end
			end
		end
		if argStr != "Zombies" and argStr != "zombies" and argStr != "Humans" and argStr != "humans" and argStr != "All" and argStr != "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Name() == argStr then
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
				if bot:IsBot() and bot.IsZSBot and bot:Alive() then
					bot:Kill()
				end
			end
		end
		if argStr == "Humans" or argStr == "humans" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Alive() and bot:Team() == 4 then
					bot:Kill()
				end
			end
		end
		if argStr == "Zombies" or argStr == "zombies" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Alive() and bot:Team() == TEAM_UNDEAD then
					bot:Kill()
				end
			end
		end
		if argStr != "Zombies" and argStr != "zombies" and argStr != "Humans" and argStr != "humans" and argStr != "All" and argStr != "all" then
			for i, bot in ipairs( player.GetAll() ) do
				if bot:IsBot() and bot.IsZSBot and bot:Alive() and bot:Name() == argStr then
					bot:Kill()
				end
			end
		end
	end
end, nil, "zs_bot_kill <name> - Kills a bot matching the given criteria." )

function RerollBotClass (thisEnt)

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
	if thisEnt:GetZombieClassTable().Name == "Zombie Torso" or thisEnt:GetZombieClassTable().Name == "Fresh Dead" or thisEnt:GetZombieClassTable().Boss then return end
	local classId = table.Random(BotClasses)
	local class = GAMEMODE.ZombieClasses[classId]
	if not class then
		table.RemoveByValue(BotClasses, classId)
		RerollBotClass(thisEnt)
		return
	end
	if class.Wave > GAMEMODE:GetWave() then 
		RerollBotClass(thisEnt)
		return
	end
	thisEnt:SetZombieClass(class.Index)
end

function CheckPropPhasing (bot, cmd)
	local tr = util.TraceHull( {
		start = bot:GetPos(),
		endpos = bot:GetPos(),
		mins = Vector( -18, -18, 0 ),
		maxs = Vector( 18, 18, 73 ),
		ignoreworld = true,
		filter = function( ent ) if ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer" ) then return true end end
	} )
	
	if tr.Entity:IsNailed() then
		--bot.cJumpTimer = false
		bot.zoomTimer = true
	end
end

function ShootAtTarget( bot )
	local th = util.TraceHull( {
		start = bot:EyePos() + bot:EyeAngles():Forward() * bot:EyePos():Distance(AimPoint( bot )),
		mins = Vector( -25, -25, -25 ),
		maxs = Vector( 25, 25, 25 ),
		ignoreworld = true,
		filter = function( ent ) if ( ent == bot.FollowerEnt.Target ) then return true end end
	} )
	
	if th.Entity == bot.FollowerEnt.Target then
		bot.attackTimer = true
	end
end

function AimPoint( bot )
	if bot:Team() == TEAM_UNDEAD then return bot.FollowerEnt.Target:EyePos() end
	
	local numHitBoxGroups = bot.FollowerEnt.Target:GetHitBoxGroupCount()

	for group=0, numHitBoxGroups - 1 do
		local numHitBoxes = bot.FollowerEnt.Target:GetHitBoxCount( group )

		for hitbox=0, numHitBoxes - 1 do
			local bone = bot.FollowerEnt.Target:GetHitBoxBone( hitbox, group )

			--print( "Hit box group " .. group .. ", hitbox " .. hitbox .. " is attached to bone " .. bot.FollowerEnt.Target:GetBoneName( bone ) )
			
			if bot.FollowerEnt.Target:GetBoneName( bone ) == "ValveBiped.Bip01_Head1" then
				
				local mins, maxs = bot.FollowerEnt.Target:GetHitBoxBounds( hitbox, group )
				local pos, rot = bot.FollowerEnt.Target:GetBonePosition( bone )
				
				local center = (mins + maxs) / 2
				
				center = LocalToWorld( center, Angle(0, 0, 0), pos, rot )
				--print ("Mins is ", mins, "Maxs is ", maxs)
				
				debugoverlay.Sphere( center, 3, 0, Color( 255, 255, 255, 0 ), true )
				
				return center
			end
		end
	end
	
	return bot.FollowerEnt.Target:EyePos()
end

function SetTaskNames( bot )
	if bot.Task == 0 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "MELEE_ZOMBIES"
		else
			bot.taskName = "GOTO_HUMANS"
		end
	elseif bot.Task == 1 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "GOTO_ARSENAL"
		else
			bot.taskName = "HIDE_FROM_HUMANS"
		end
	elseif bot.Task == 2 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "HEAL_TEAMMATE"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 3 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "PLACE_RESUPPLY"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 4 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "WANDER_AROUND"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 5 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "REPAIR_CADES"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 6 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "GOTO_CADING_PROP"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 7 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "MAKE_CADE"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 8 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "RESUPPLY_AMMO"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 9 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "PICKUP_LOOT"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 10 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "DEFEND_CADE"
		else
			bot.taskName = bot.Task
		end
	elseif bot.Task == 11 then
		if bot:Team() != TEAM_UNDEAD then
			bot.taskName = "SNIPING"
		else
			bot.taskName = bot.Task
		end
	else
		bot.taskName = bot.Task
	end
	
	
	if bot.Disposition == 0 then
		bot.dispositionName = "ENGAGE_AND_INVESTIGATE"
	elseif bot.Disposition == 1 then
		bot.dispositionName = "OPPORTUNITY_FIRE"
	elseif bot.Disposition == 2 then
		bot.dispositionName = "SELF_DEFENSE"
	elseif bot.Disposition == 3 then
		bot.dispositionName = "IGNORE_ENEMIES"
	else
		bot.dispositionName = bot.Disposition
	end
end

function CloseToPointCheck( bot, curgoalPos, goalPos, cmd, lookAtPoint, crouchJunp )
	if lookAtPoint == nil then
		lookAtPoint = true
	end
	if crouchJump == nil then
		crouchJump = true
	end
	
	if !IsValid( bot.FollowerEnt.P ) then return end
	
	if crouchJump then
	
		if bot.cJumpDelay < 1 then
			bot.cJumpDelay = bot.cJumpDelay + FrameTime()
		end
		
		if bot.cJumpDelay >= 1 then
			if bot:GetVelocity():Length() < bot.stopVel then
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

function DoLadderMovement (bot, cmd, curgoal)
	if bot.b then 
		bot.moveType = 0
		bot.cJumpDelay = 0
		cmd:SetButtons( IN_FORWARD ) 
		
		local curgoalposXY = (Vector (curgoal.pos.x, curgoal.pos.y, 0) - Vector (bot:EyePos().x, bot:EyePos().y, 0)):Angle()
		
		bot.lookAngle = Angle (-20, curgoalposXY.y, bot:EyeAngles().z)
		
		--bot.lookAngle = ((curgoal.pos - bot:GetPos()):Angle())
	end
									
	if bot.canGetOffLadderTimer then
		bot.canGetOffLadderTimer = false
		timer.Simple (5,function() 
			if !IsValid(bot) then return end
			bot.b = false
			bot.useHold = true
			timer.Simple (0.05,function() 
				if !IsValid(bot) then return end
				bot.useHold = false
				bot.canGetOffLadderTimer = true
				timer.Simple (0.05,function() 
					if !IsValid(bot) then return end
					if bot:GetMoveType() == MOVETYPE_LADDER then
						if !IsValid(bot) then return end
						bot.jumpHold = true
						timer.Simple (0.05,function() 
							bot.jumpHold = false
						end)
					end
				end)
			end)
		end)
	end
end

function DoSpawnStuff( ply, changeClass )
	ply.Task = -1
	ply.moveType = -1
	ply.runAwayTimer = 0
	
	if ply:Team() != TEAM_UNDEAD then
		
		timer.Simple(0, function()
			if !IsValid(ply) then return end
			
			ply:SetPlayerColor(Vector(math.Rand (0, 1), math.Rand (0, 1), math.Rand (0, 1)))
		end)
		
		if GAMEMODE:GetWave() != 0 then
			ply.Task = 1
			
			timer.Simple( 4, function() 
				if !IsValid(ply) then return end
				GiveBotWeapons( ply )
			end)
		else
			timer.Simple(0, function() 
				if !IsValid(ply) then return end
				
				local delay = math.Rand( 1, 15 )
				print ("Buy delay for ", ply:Name(), "is ", delay)
		
				timer.Simple(delay, function() 
					if !IsValid(ply) then return end
					ply.Task = 1
					GiveBotWeapons( ply )
				end)
			end)
		end
		
	else
		ply.Task = 0
		
		if changeClass then
			RerollBotClass( ply )
		end
	end
end

function GiveBotWeapons( ply )
	if !IsValid( ply ) then return end
	
	-- 12 default starting loadouts, the rest are custom
	if math.random(1, 13) == 13 then
		local oof = math.random(1, 2)
		if oof == 1 then
			if GAMEMODE.CheckedOut[ply:UniqueID()] or GAMEMODE.ZombieEscape then return end
			GAMEMODE.CheckedOut[ply:UniqueID()] = true
			
			ply:Give("weapon_zs_resupplybox")
			ply:Give("weapon_zs_swissarmyknife")
		elseif oof == 2 then
			if GAMEMODE.CheckedOut[ply:UniqueID()] or GAMEMODE.ZombieEscape then return end
			GAMEMODE.CheckedOut[ply:UniqueID()] = true
	
			ply:Give("weapon_zs_hammer")
			ply.BuffMuscular = true
			ply:DoMuscularBones()
		end
	else
		gamemode.Call("GiveRandomEquipment", ply)
	end
end