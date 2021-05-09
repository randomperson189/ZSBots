hook.Add("PlayerInitialSpawn", "ZSPlayerInitialSpawn", function(ply)
	if botsSpawned == nil then
		botsSpawned = true
		
		if GetConVar( "zs_bot_autospawn_count" ):GetInt() > 0 then
			for i = 1, GetConVar( "zs_bot_autospawn_count" ):GetInt() do
				player.CreateZSBot()
			end
		end
	end
end )
