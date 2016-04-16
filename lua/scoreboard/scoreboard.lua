include("player_row.lua")
include("player_frame.lua")

local LABEL = {}  --garry

function LABEL:Init()
	self:SetPaintBackgroundEnabled(false)
end

vgui.Register("SB_Label", LABEL, "Label")

local function TimeStr(time)
	local time = math.floor(time)
	local sec = time % 60
	time = math.floor(time / 60)
	local min = time % 60
	time = math.floor(time / 60)
	local hours = time % 24
	time = math.floor(time / 24)
	
	return string.format("The server has been up for %i days, %i hours, %i minutes and %i seconds", time, hours, min, sec)
end

surface.CreateFont( "ScoreboardHeader", {
	font = "coolvetica",
	size = 32,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )
surface.CreateFont( "ScoreboardSubtitle", {
	font = "coolvetica",
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )
surface.CreateFont( "Coolvetica18", {
	font = "coolvetica",
	size = 19,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true
} )

local texGradient = surface.GetTextureID("gui/center_gradient")

local PANEL = {}

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	SCOREBOARD = self

	self.Hostname = vgui.Create("SB_Label", self)
	self.Hostname:SetText(GetHostName())

	self.Description = vgui.Create("SB_Label", self)
	self.Description:SetText(ScoreBoardDesc or "")

	self.PlayerFrame = vgui.Create("RPPlayerFrame", self)

	self.PlayerRows = {}

	for _, v in ipairs(player.GetAll()) do
		if IsValid(v) and !self:GetPlayerRow(v) then
			self:AddPlayerRow(v)
		end
	end

	-- Update the scoreboard every 1 second
	--timer.Create("ScoreboardUpdater", 1, 0, function() self:UpdateScoreboard() end)

	self.lblJob = vgui.Create("SB_Label", self)
	self.lblJob:SetText("Job")

	self.lblPing = vgui.Create("SB_Label", self)
	self.lblPing:SetText("Ping")
	
	self.lblWarranted = vgui.Create("SB_Label", self)
	self.lblWarranted:SetText("Wanted")
	
	self.UpTime = vgui.Create("SB_Label", self)
	
	self.Donator = vgui.Create("SB_Label", self)
	self.Donator:SetText("Donator")
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow(ply)
	local button = vgui.Create("RPScorePlayerRow", self.PlayerFrame:GetCanvas())
	button:SetPlayer(ply)
	button:InvalidateLayout()
	self.PlayerRows[ ply ] = button
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow(ply)
	return self.PlayerRows[ ply ]
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), Color(255, 255, 255, 98))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(50, 50, 50, 50)
	surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())
 
	-- White Inner Box
	draw.RoundedBox(4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 23, Color(0, 0, 0, 98))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 50)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 23)

	-- Sub Header
	draw.RoundedBox(4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, Color(0, 0, 0, 200))
	surface.SetTexture(texGradient)
	surface.SetDrawColor(0, 0, 0, 50)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self.Description:GetTall() + 8)
	self.UpTime:SetText(TimeStr(SCOREBOARD.Time + CurTime()))
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(800, ScrH() * 0.85)
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2 - 50)

	self.Hostname:SizeToContents()
	self.Hostname:SetPos(16, 16)

	self.Description:SizeToContents()
	self.Description:SetPos(16, 64)

	self.PlayerFrame:SetPos(5, self.Description.y + self.Description:GetTall() + 20)
	self.PlayerFrame:SetSize(self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10)

	local y = 0

	local PlayerSorted = {}

	for k, v in pairs(self.PlayerRows) do
		table.insert(PlayerSorted, v)
	end

	table.sort(PlayerSorted, function (a , b) return a:HigherOrLower(b) end)

	for k, v in ipairs(PlayerSorted) do
		v:SetPos(0, y)
		v:SetSize(self.PlayerFrame:GetWide(), v:GetTall())

		self.PlayerFrame:GetCanvas():SetSize(self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall())
		y = y + v:GetTall() + 1
	end

	self.Hostname:SetText(GetHostName())

	self.lblPing:SizeToContents()
	self.lblJob:SizeToContents()
	self.lblWarranted:SizeToContents()
	self.Donator:SizeToContents()
	self.UpTime:SizeToContents()
	self.UpTime:SetSize(self.UpTime:GetWide() + 30, self.UpTime:GetTall())
	self.lblPing:SetPos(self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.lblJob:SetPos(self:GetWide() - 50*7 - self.lblJob:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.lblWarranted:SetPos(self:GetWide() - 50*9 - self.lblJob:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.Donator:SetPos(self:GetWide() - 50 * 3 - self.Donator:GetWide() / 2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.UpTime:SetPos(5, self:GetTall() - self.UpTime:GetTall() - 3)
end

/*---------------------------------------------------------
Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.Hostname:SetFontInternal("ScoreboardHeader")
	self.Description:SetFontInternal("ScoreboardSubtitle")

	self.Hostname:SetFGColor(Color(0, 0, 0, 200))
	self.Description:SetFGColor(color_white)

	self.lblPing:SetFontInternal("DefaultSmall")
	self.lblJob:SetFontInternal("DefaultSmall")
	self.lblWarranted:SetFontInternal("DefaultSmall")

	self.lblPing:SetFGColor(Color(0, 0, 0, 255))
	self.lblJob:SetFGColor(Color(0, 0, 0, 255))
	self.lblWarranted:SetFGColor(Color(0, 0, 0, 255))
	self.Donator:SetFGColor(Color(0, 0, 0, 255))
	self.Donator:SetFontInternal("DefaultSmall")

	self.UpTime:SetFGColor(Color(0, 0, 0, 220))
	self.UpTime:SetFontInternal("Coolvetica18")
end

hook.Add("OnEntityCreated", "SCOREBOARD.AddPlayer", function(ent)
	if type(ent) == "Player" and SCOREBOARD then
		timer.Create("__sbadd" .. ent:EntIndex(), 0, 0, function() if ent.DarkRPVars then SCOREBOARD:AddPlayerRow(ent) SCOREBOARD:InvalidateLayout() timer.Destroy("__sbadd" .. ent:EntIndex()) end end)
	end
end)

hook.Add("EntityRemoved", "SCOREBOARD.RemovePlayer", function(ent)
	if type(ent) == "Player" and SCOREBOARD then
		if SCOREBOARD.PlayerRows[ent] then
			SCOREBOARD.PlayerRows[ent]:Remove()
			SCOREBOARD.PlayerRows[ent] = nil
			SCOREBOARD:InvalidateLayout()
		end
	end
end)



vgui.Register("RPScoreBoard", PANEL, "Panel")
