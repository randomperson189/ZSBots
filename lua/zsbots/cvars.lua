--CreateConVar( "zs_bot_quota", 0, FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, "Description here" )
--CreateConVar( "zs_bot_say", "", FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, "Display bot message." )
--CreateConVar( "zs_bot_say_team", "", FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, "Display bot message to team." )
--CreateConVar( "zs_bot_melee_only", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots are forced to use their melee weapon." )
--CreateConVar( "zs_bot_debug", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Debug ZSBots (developer must be set to 1 in the console to work)." )

CreateConVar( "zs_bot_debug_spectator", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Show the debug menu while spectating ZSBots. (developer must be set to 1 in the console to work and FSpectate is needed)" )
CreateConVar( "zs_bot_debug_attack", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Debug ZSBots attack detection." )
CreateConVar( "zs_bot_debug_path", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Debug ZSBots pathfinding." )
CreateConVar( "zs_bot_debug_defending_spots", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Debug ZSBots defending spots." )

CreateConVar( "zs_bot_muscular", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots will always have the muscular trait." )
CreateConVar( "zs_bot_infinite_ammo", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots will have unlimited ammo." )

CreateConVar( "zs_bot_can_cade", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots may cade." )
CreateConVar( "zs_bot_can_buy", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots may buy from arsenal crates." )
CreateConVar( "zs_bot_can_place_deployables", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots may place deployables." )
CreateConVar( "zs_bot_can_pick_up_loot", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots may pick up loot." )
CreateConVar( "zs_bot_can_chat", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "If nonzero, ZSBots may send chat messages." )

CreateConVar( "zs_bot_force_zombie", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Force ZSBots to be zombies." )

CreateConVar( "zs_bot_autospawn_count", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED, FCVAR_ARCHIVE}, "How many ZSBots to spawn at the start." )

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