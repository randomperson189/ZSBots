--CreateConVar( "zs_bot_debug_nav", 0, FCVAR_SERVER_CAN_EXECUTE, "Debug ZSBots navigation." )
--CreateConVar( "zs_bot_quota", 0, FCVAR_SERVER_CAN_EXECUTE, "Description here" )
--CreateConVar( "zs_bot_say", "", FCVAR_SERVER_CAN_EXECUTE, "Display bot message." )
--CreateConVar( "zs_bot_say_team", "", FCVAR_SERVER_CAN_EXECUTE, "Display bot message to team." )
--CreateConVar( "zs_bot_melee_only", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may pick up loot." )

CreateConVar( "zs_bot_debug", 0, FCVAR_SERVER_CAN_EXECUTE, "Debug ZSBots." )

CreateConVar( "zs_bot_muscular", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots will always have the muscular trait." )
CreateConVar( "zs_bot_infinite_ammo", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots will have unlimited ammo." )

CreateConVar( "zs_bot_can_cade", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may cade." )
CreateConVar( "zs_bot_can_buy", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may buy from arsenal crates." )
CreateConVar( "zs_bot_can_place_deployables", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may place deployables." )
CreateConVar( "zs_bot_can_pick_up_loot", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may pick up loot." )
CreateConVar( "zs_bot_can_chat", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "If nonzero, ZSBots may send chat messages." )