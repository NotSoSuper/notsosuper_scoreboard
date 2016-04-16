local function UpdatePlayerRating()
	local ent, rating = net.ReadEntity(), net.ReadUInt(8)
	if IsValid(ent) then
		ent.Ratings[rating] = ent.Ratings[rating] + 1
	end
end

net.Receive("RATINGS.UpdatePlayerRating", UpdatePlayerRating)

local temp = {}

local function LoadPlayerRating()
	local tab = net.ReadTable()
	local ply = NULL
	for _, v in pairs(player.GetAll()) do
		if v:SteamID() == tab[1]["sid"] then
			ply = v
		end
	end
	if IsValid(ply) then
		ply.Ratings[1] = tonumber(tab[1]["rating1"])
		ply.Ratings[2] = tonumber(tab[1]["rating2"])
		ply.Ratings[3] = tonumber(tab[1]["rating3"])
		ply.Ratings[4] = tonumber(tab[1]["rating4"])
		ply.Ratings[5] = tonumber(tab[1]["rating5"])
		ply.Ratings[6] = tonumber(tab[1]["rating6"])
	else
		table.insert(temp, tab)
	end
end

net.Receive("RATINGS.BroadcastRatings", LoadPlayerRating)

hook.Add("OnEntityCreated", "InitRatings", function(ent)
	if type(ent) == "Player" then
		ent.Ratings = {0, 0, 0, 0, 0, 0}
		for k, v in pairs(temp) do
			if v[1]["sid"] == ent:SteamID() then
				ent.Ratings[1] = tonumber(v[1]["rating1"])
				ent.Ratings[2] = tonumber(v[1]["rating2"])
				ent.Ratings[3] = tonumber(v[1]["rating3"])
				ent.Ratings[4] = tonumber(v[1]["rating4"])
				ent.Ratings[5] = tonumber(v[1]["rating5"])
				ent.Ratings[6] = tonumber(v[1]["rating6"])
			end
		end
	end
end)