if SERVER then
	include ("zsbots/server/cvars.lua")
	include ("zsbots/server/functions.lua")
	include ("zsbots/server/ai.lua")
end

if CLIENT then
	--include ("zsbots/client/debughud.lua")
end