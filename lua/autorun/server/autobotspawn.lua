botsSpawned = false

local function ZSPlayerInitialSpawn(ply)
	if !botsSpawned then
		botsSpawned = true
		
		if GetConVar( "zs_bot_autospawn_count" ):GetInt() > 0 then
			for i = 1, GetConVar( "zs_bot_autospawn_count" ):GetInt() do
				player.CreateZSBot()
			end
		end
	end
end
hook.Add("PlayerInitialSpawn", "ZSPlayerInitialSpawn", ZSPlayerInitialSpawn)