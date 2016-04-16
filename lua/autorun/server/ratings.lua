AddCSLuaFile("autorun/client/cl_ratings.lua")
RATINGS = {}
RATINGS.Names = {
	 "Good Roleplayer",
	 "Very Nice Roleplayer!",
	 "Friendly",
	 "Smart",
	 "Helpful",
	 "Good Builder"
}
	 
util.AddNetworkString("RATINGS.BroadcastRatings")
util.AddNetworkString("RATINGS.UpdatePlayerRating")

function RATINGS.CreateTables()
	if !sql.TableExists("player_ratings") then
		local created = sql.Query("CREATE TABLE player_ratings (sid varchar(255) PRIMARY KEY UNIQUE, rating1 smallint, rating2 smallint, rating3 smallint, rating4 smallint, rating5 smallint, rating6 smallint)")
		if created then MsgN("Ratings table created") end
	end
end

hook.Add("Initialize", "RATINGS.CreateTables", RATINGS.CreateTables)

function RATINGS.LoadRatings(ply)
	sql.Query("INSERT INTO player_ratings VALUES ('" .. ply:SteamID() .. "', 0, 0, 0, 0, 0, 0)")
	local result = sql.Query("SELECT * FROM player_ratings WHERE sid = '" .. ply:SteamID() .. "'")
	
	if result then
		ply.Ratings = {result[1]["rating1"], result[1]["rating2"], result[1]["rating3"], result[1]["rating4"], result[1]["rating5"], result[1]["rating6"]}  
		net.Start("RATINGS.BroadcastRatings")
			net.WriteTable(result)
		net.Broadcast()
	end
end

hook.Add("PlayerInitialSpawn", "RATINGS.LoadRatings", RATINGS.LoadRatings)

function RATINGS.AddRating(ply, rating)
	ply.Ratings[rating] = ply.Ratings[rating] + 1
	sql.Query("UPDATE player_ratings SET rating" .. tostring(rating) .. " = " .. tostring(ply.Ratings[rating]) .. " WHERE sid = '" .. ply:SteamID() .. "'")
	
	net.Start("RATINGS.UpdatePlayerRating")
		net.WriteEntity(ply)
		net.WriteUInt(rating, 8)
	net.Broadcast()
end

concommand.Add("rateuser", function(ply, cmd, args)
	local target
	for k, v in pairs(player.GetAll()) do
		if v:UserID() == tonumber(args[1]) then
			target = v
		end
	end
	if target == ply then return end
	if !ply.Rated then 
		ply.Rated = {} 
	end
	for k, v in pairs(ply.Rated) do
		if k == target:SteamID() then
			if CurTime() - v >= 1200 then --1200 secs is 20 mins
				RATINGS.AddRating(target, tonumber(args[2]))
				target:ChatPrint(ply:Nick() .. " rated you ".. RATINGS.Names[tonumber(args[2])])
				ply.Rated[k] = CurTime()
			end
			return
		end
	end
	target:ChatPrint(ply:Nick() .. " rated you ".. RATINGS.Names[tonumber(args[2])])
	ply.Rated[target:SteamID()] = CurTime()
	RATINGS.AddRating(target, tonumber(args[2]))
end)