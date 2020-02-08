if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	self:SetModel( "models/editor/playerstart.mdl" )
    self:SetHealth(math.huge)
	self:SetNoDraw( true )
	self:SetSolid( SOLID_NONE )
	self.Bot = nil
	self.TargetEnemy = nil
	self.TargetArsenal = nil
	self.TargetResupply = nil
	self.TargetTeammate = nil
	self.TargetHealing = nil
	self.TargetNailedProp = nil
	self.TargetCadingProp = nil
	self.TargetCadingSpot = nil
	self.TargetLootItem = nil
	self.TargetPosition = Vector( 0, 0, 0 )
	self.CurSegment = 2
end

function ENT:ChasePos( options )
	self.P = Path( "Follow" )
	self.P:SetMinLookAheadDistance( options.lookahead or 300 )
	self.P:SetGoalTolerance( options.goaltolerance or 20 )
	
	self:ComputePath (self.P, self:GetPos())
	
	if !self.P:IsValid() then return end
	while self.P:IsValid() do
		if self.P:GetAge() > 1 and self.Bot:Alive() and self.Bot:GetZombieClassTable().Name != "Crow" then
			
			if self.Bot.Task == GOTO_ARSENAL then
				if self.Bot:Team() != TEAM_UNDEAD then
					if IsValid( self.TargetArsenal ) then
						if self.Bot:GetPos():Distance( self.TargetArsenal:GetPos() ) > 200 then
							self:ComputePath (self.P, self.TargetArsenal:GetPos())
						end
					end
				elseif IsValid( self.TargetEnemy ) then
					self:ComputePath (self.P, self.TargetEnemy:GetPos())
				end
			end
			
			if self.Bot.Task == MELEE_ZOMBIES then
				if self.Bot:Team() != TEAM_UNDEAD then
					if IsValid( self.TargetEnemy ) then
						self:ComputePath (self.P, self.TargetEnemy:GetPos())
					end
				elseif self.TargetPosition != nil then
					self:ComputePath (self.P, self.TargetPosition)
				end
			end
			
			if self.Bot.Task == FOLLOW then
				if IsValid( self.TargetTeammate ) then 
					self:ComputePath (self.P, self.TargetTeammate:GetPos())
				end
			end
			
			if self.Bot.Task == HEAL_TEAMMATE then
				if IsValid( self.TargetHealing ) then 
					self:ComputePath (self.P, self.TargetTeammate:GetPos())
				end
			end
			
			if self.TargetPosition != nil then
				if self.Bot.Task == WANDER_AROUND or self.Bot.Task == SNIPING then
					self:ComputePath (self.P, self.TargetPosition)
				end
			end
		
			if IsValid( self.TargetNailedProp ) and self.Bot.Task == REPAIR_CADE then
				self:ComputePath (self.P, self.TargetNailedProp:GetPos())
			end
		
			if IsValid( self.TargetCadingProp ) and self.Bot.Task == GOTO_CADING_PROP then
				self:ComputePath (self.P, self.TargetCadingProp:GetPos())
			end
		
			if self.TargetCadingSpot != nil then 
				if self.Bot.Task == MAKE_CADE or self.Bot.Task == DEFEND_CADE then
					self:ComputePath (self.P, self.TargetCadingSpot)
				end
			end
			
			if IsValid( self.TargetResupply ) and self.Bot.Task == RESUPPLY_AMMO then
				--if self.Bot:GetPos():Distance( self.TargetResupply:GetPos() ) > 100 then
					self:ComputePath (self.P, self.TargetResupply:GetPos())
				--end
			end
			
			if IsValid( self.TargetLootItem ) and self.Bot.Task == PICKUP_LOOT then
				self:ComputePath (self.P, self.TargetLootItem:GetPos())
			end
			
			if self.loco:IsStuck() then
				self:HandleStuck()
				return
			end
		end
	
		if GetConVar( "zs_bot_debug" ):GetInt() == 1 then
			self.P:Draw()
		end
		
		coroutine.yield()
	end
end

function ENT:RunBehaviour()
	while ( true ) do
		self:ChasePos( {} )
		
		coroutine.yield()
	end
end

function ENT:ComputePath (path, pos)
	path:Compute( self, pos, function( area, fromArea, ladder, elevator, length )
		if ( !IsValid( fromArea ) ) then

			// first area in path, no cost
			return 0

		else
		
		if ( !self.loco:IsAreaTraversable( area ) ) then
			// our locomotor says we can't move here
			return -1
			
		end

		// compute distance traveled along path so far
		local dist = 0

		local cost = dist + fromArea:GetCostSoFar()

		// check height change
		local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange( area )
		if ( deltaZ >= self.loco:GetStepHeight() ) then
			if ( deltaZ >= self.loco:GetMaxJumpHeight() ) then
				// too high to reach
				return -1
			end

			// jumping is slower than flat ground
			local jumpPenalty = 5
			cost = cost + jumpPenalty * dist
		end

		return cost
		end
	end )
	
	self.CurSegment = 2
end