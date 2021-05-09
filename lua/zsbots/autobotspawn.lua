if botsSpawned == nil then botsSpawned = false end

local function ZSPlayerInitialSpawn(ply)
	if !botsSpawned then
		if GetConVar( "zs_bot_autospawn_count" ):GetInt() > 0 then
			for i = 1, GetConVar( "zs_bot_autospawn_count" ):GetInt() do
				player.CreateZSBot()
			end
		end
		
		botsSpawned = true
	end
end
hook.Add("PlayerInitialSpawn", "ZSPlayerInitialSpawn", ZSPlayerInitialSpawn)