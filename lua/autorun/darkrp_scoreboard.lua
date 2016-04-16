if SERVER then 

	util.AddNetworkString("SB_sendplayerip")
	util.AddNetworkString("SB_synctime")
	AddCSLuaFile( "autorun/darkrp_scoreboard.lua" )
	AddCSLuaFile( "scoreboard/admin_buttons.lua" )
	AddCSLuaFile( "scoreboard/player_frame.lua" )
	AddCSLuaFile( "scoreboard/player_infocard.lua" )
	AddCSLuaFile( "scoreboard/player_row.lua" )
	AddCSLuaFile( "scoreboard/scoreboard.lua" )
	AddCSLuaFile( "scoreboard/vote_button.lua" )
	AddCSLuaFile( "scoreboard/infocard_entry.lua" )
	
	function SB_sendip(ply)
		net.Start("SB_sendplayerip")
			net.WriteUInt(ply:EntIndex(), 16)
			net.WriteString(ply:IPAddress())
		net.Broadcast()
		net.Start("SB_synctime")
			net.WriteUInt(math.Round(CurTime()), 32)
		net.Send(ply)
	end
	
	hook.Add("PlayerInitialSpawn", "SB_SendPlayerIP", SB_sendip)
	return
end

include("scoreboard/scoreboard.lua")

local pScoreBoard = nil
local time
local __SBind = {} --fuck
ScoreBoardDesc = "change me"

--inb4 api goes down... ITS DOWN
local function LoadLocationData(ent, ip)
--	http.Fetch("http://freegeoip.net/xml/" .. (ent == LocalPlayer() and "" or ip), function(contents)
    http.Fetch("http://freegeoip.lwan.ws/xml/" .. (ent == LocalPlayer() and "" or ip), function(contents)
		local code = contents:match("<CountryCode>(..)</CountryCode>")
		local country = contents:match("<CountryName>(.+)</CountryName>")
        local state = contents:match("<RegionName>(.+)</RegionName>")
			country = state .. ",  " .. country
		ent.CountryInfo = {code, country}
	end)
end

net.Receive("SB_synctime", function()
	time = net.ReadUInt(32)
end)
net.Receive("SB_sendplayerip", function()
	if !__SBind then __SBind = {} end
	local ent, ip = net.ReadUInt(16), net.ReadString()
	if Entity(ent):IsValid() then
		LoadLocationData(Entity(ent), ip)
	else
		table.insert(__SBind, {ent, ip})
	end
end)

hook.Add("OnEntityCreated", "SB_sendplayerip", function(ent)
	if type(ent) == "Player" then
		for k, v in ipairs(__SBind) do
			if v[1] == ent:EntIndex() then
				LoadLocationData(ent, v[2])
				table.remove(__SBind, k)
			end
		end
	end
end)

/*---------------------------------------------------------
Name: gamemode:CreateScoreboard()
Desc: Creates/Recreates the scoreboard
---------------------------------------------------------*/

local function CreateScoreboard()
	if pScoreBoard then
		pScoreBoard:Remove()
		pScoreBoard = nil
	end

	pScoreBoard = vgui.Create("RPScoreBoard")
	if !SCOREBOARD.Time then pScoreBoard.Time = time end
end

/*---------------------------------------------------------
Name: gamemode:ScoreboardShow()
Desc: Sets the scoreboard to visible
---------------------------------------------------------*/
local function ScoreboardShow()

	GAMEMODE.ShowScoreboard = true
	gui.EnableScreenClicker(true)

	if not pScoreBoard then
		CreateScoreboard()
	end

	pScoreBoard:SetVisible(true)
	for _, v in ipairs(player.GetAll()) do
		if IsValid(v) and !pScoreBoard:GetPlayerRow(v) then
			pScoreBoard:AddPlayerRow(v)
		end
	end

	return true
end

/*---------------------------------------------------------
Name: gamemode:ScoreboardHide()
Desc: Hides the scoreboard
---------------------------------------------------------*/
hook.Add( "ScoreboardHide", "DarkRP_Override_H", function()
	GAMEMODE.ShowScoreboard = false
	gui.EnableScreenClicker(false)
	if pScoreBoard then
		pScoreBoard:SetVisible(false)
	end
end )


hook.Add( "InitPostEntity", "HackyScoreBoardFix", function()

	GAMEMODE.ScoreboardShow = ScoreboardShow

end )