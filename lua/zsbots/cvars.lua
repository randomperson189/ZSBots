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