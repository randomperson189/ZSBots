local CATEGORY_NAME = "ZS Bots"

--Add ZS Bot--
function ulx.addzsbots( calling_ply, amount, name )
	if amount <= 1 then
		amount = 1
	end
	
	timer.Simple( 0, function()
		for i=1, amount do
			CreateZSBot(name)
		end
	end )
	
	ulx.fancyLogAdmin( calling_ply, "#A added #i ZS Bots.", amount, name )
end
local addzsbots = ulx.command( CATEGORY_NAME, "ulx addzsbots", ulx.addzsbots, "!addzsbots" )
addzsbots:addParam{ type = ULib.cmds.NumArg, min = 1, default = 1, hint = "Amount", ULib.cmds.optional}
addzsbots:addParam{ type = ULib.cmds.StringArg, hint = "Name", ULib.cmds.optional}
addzsbots:defaultAccess(ULib.ACCESS_ADMIN)
addzsbots:help( "Adds a ZS Bot." )

--Kick ZS Bots--
function ulx.kickzsbots( calling_ply, amount, should_kickall )
	if should_kickall then
		for i, ply in ipairs( player.GetZSBots() ) do
			ply:Kick("")
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A removed all ZS Bots." )
	else
		for i=1, amount do
			if IsValid(player.GetZSBots()[i]) then
				player.GetZSBots()[i]:Kick()
			end
		end
		
		ulx.fancyLogAdmin( calling_ply, "#A removed #i ZS Bots.", amount )
	end
end
local kickzsbots = ulx.command( CATEGORY_NAME, "ulx kickzsbots", ulx.kickzsbots, "!kickzsbots" )
kickzsbots:addParam{ type = ULib.cmds.NumArg, min = 1, default = 1, hint = "Amount", ULib.cmds.optional}
kickzsbots:addParam{ type=ULib.cmds.BoolArg, invisible=true }
kickzsbots:defaultAccess(ULib.ACCESS_ADMIN)
kickzsbots:help( "Removes a ZS Bot." )
kickzsbots:setOpposite( "ulx kickallzsbots", { _, _, true }, "!kickallzsbots" )

--Slay ZS Bots--
function ulx.slayzsbots( calling_ply )
	for i, ply in ipairs( player.GetZSBots() ) do
		if ply:Alive() and !ply:IsFrozen() then
			ply:Kill("")
		end
	end
	
	ulx.fancyLogAdmin( calling_ply, "#A slayed all ZS Bots." )
end
local slayzsbots = ulx.command( CATEGORY_NAME, "ulx slayzsbots", ulx.slayzsbots, "!slayzsbots" )
slayzsbots:defaultAccess(ULib.ACCESS_ADMIN)
slayzsbots:help( "Slays all ZS Bots." )

--ZS Bot say--
function ulx.zsbotsay( calling_ply, target_plys, message, say_team )
	for i, ply in ipairs(target_plys) do
		if ply:IsBot() and ply.IsZSBot then
			if say_team then
				ply:Say(message, true)
			else
				ply:Say(message)
			end
		else
			table.RemoveByValue(target_plys, ply)
		end
	end
	
	if say_team then
		ulx.fancyLogAdmin( calling_ply, true, "#A made #T say a team message.", target_plys )
	else
		ulx.fancyLogAdmin( calling_ply, true, "#A made #T say a message.", target_plys )
	end
end
local zsbotsay = ulx.command( CATEGORY_NAME, "ulx zsbotsay", ulx.zsbotsay, "!zsbotsay", true )
zsbotsay:addParam{ type = ULib.cmds.PlayersArg }
zsbotsay:addParam{ type = ULib.cmds.StringArg, hint = "message" }
zsbotsay:addParam{ type = ULib.cmds.BoolArg, hint = "Team only", ULib.cmds.optional }
zsbotsay:defaultAccess( ULib.ACCESS_ADMIN )
zsbotsay:help( "Makes a ZS Bot say a message" )