include("admin_buttons.lua")
include("infocard_entry.lua")
include("vote_button.lua")

local star = Material("gui/silkicons/star.png")
local PANEL = {}

function PANEL:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(237, 200, 0, 150))
	surface.SetDrawColor(Color(255, 255, 255, 255))
	surface.SetMaterial(star)
	surface.DrawTexturedRect(w - 18, h - 18, 16, 16)
end

vgui.Register("AdminSlot", PANEL, "Panel")

local function TimeStr(time)
	local time = math.Round(time)
	local sec = time % 60
	time = math.Round(time / 60)
	local min = time % 60
	time = math.Round(time / 60)
	local hours = time / 24
	
	return string.format("%i hours, %i minutes", hours, min)
end

local adminranks = {"superadmin"}

local function AdminCheck(ply)
	return table.HasValue(adminranks, ply:GetUserGroup())
end

PANEL = {}

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()
	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	self.Ratings = {}
	
	self.btnKick = vgui.Create("RPSpawnMenuAdminButton", self)
	self.btnKick.Text = "Kick"
	self.btnKick.DoClick = function(self)
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 110)
		frame:Center()
		frame:SetTitle("Type in a reason")
		frame:NoClipping(true)
		frame:MakePopup()
		frame.Player = self:GetParent().Player
		frame.lbl = vgui.Create("DLabel", frame)
		frame.lbl:SetText("Reason:")
		frame.lbl:SizeToContents()
		frame.lbl:SetPos(20, 40 - frame.lbl:GetTall())
		frame.lbl:SetVisible(true)
		local txt = vgui.Create("DTextEntry", frame)
		txt:SetSize(260, 20)
		txt:SetPos(20, 40)
		txt:RequestFocus()
		txt.OnEnter = function(self)
			SCOREBOARD.PlayerRows[self:GetParent().Player]:Remove()
			SCOREBOARD.PlayerRows[self:GetParent().Player] = nil 
			SCOREBOARD:InvalidateLayout() 
			RunConsoleCommand("ulx", "kick", self:GetParent().Player:Nick(), (self:GetValue():Trim() == "" and "N/A" or self:GetValue():Trim()))
			frame:Close()
		end
		local btn = vgui.Create("DButton", frame)
		btn:SetSize(64, 20)
		btn:SetPos(frame:GetWide() - 70, frame:GetTall() - 25)
		btn:SetText("Kick")
		btn.DoClick = function(self)
			SCOREBOARD.PlayerRows[self:GetParent().Player]:Remove()
			SCOREBOARD.PlayerRows[self:GetParent().Player] = nil 
			SCOREBOARD:InvalidateLayout() 
			RunConsoleCommand("ulx", "kick", self:GetParent().Player:Nick(), (txt:GetValue():Trim() == "" and "N/A" or txt:GetValue():Trim()))
			frame:Close()
		end
	end
	self.btnSpec = vgui.Create("RPSpawnMenuAdminButton", self)
	self.btnSpec.Text = "Spec"
	self.btnSpec.DoClick = function(self)
		RunConsoleCommand("ulx", "spectate", self:GetParent().Player:Nick())
	end
	self.btnBan = vgui.Create("RPSpawnMenuAdminButton", self)
	self.btnBan.Text = "Ban"
	self.btnBan.DoClick = function(self)
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 130)
		frame:Center()
		frame:SetTitle("Insert ban lenght and reason")
		frame:NoClipping(true)
		frame:MakePopup()
		frame.lbl1 = vgui.Create("DLabel", frame)
		frame.lbl1:SetText("Hours:")
		frame.lbl1:SizeToContents()
		frame.lbl1:SetPos(20, 40 - frame.lbl1:GetTall())
		frame.lbl1:SetVisible(true)
		frame.lbl2 = vgui.Create("DLabel", frame)
		frame.lbl2:SetText("Minutes:")
		frame.lbl2:SizeToContents()
		frame.lbl2:SetPos(160, 40 - frame.lbl1:GetTall())
		frame.lbl2:SetVisible(true)
		frame.lbl3 = vgui.Create("DLabel", frame)
		frame.lbl3:SetText("Reason:")
		frame.lbl3:SizeToContents()
		frame.lbl3:SetPos(20, 72 - frame.lbl1:GetTall())
		frame.lbl3:SetVisible(true)
		frame.Player = self:GetParent().Player
		frame.txt = vgui.Create("DTextEntry", frame)
		frame.txt:SetSize(120, 20)
		frame.txt:SetPos(20, 40)
		frame.txt:RequestFocus()
		frame.txt.OnKeyCodePressed = function(k)
			if k == KEY_TAB then
				frame.txt3:RequestFocus()
			end
		end
		frame.txt.OnEnter = function(self)
			if tonumber(self:GetValue():Trim()) then
				frame.txt2.BanTime = tonumber(self:GetValue():Trim()) * 60
				frame.txt3:RequestFocus()
			end
		end		
		frame.txt:SetVisible(true)
		
		
		frame.txt2 = vgui.Create("DTextEntry", frame)
		frame.txt2:SetSize(260, 20)
		frame.txt2:SetPos(20, 72)
		frame.txt2.OnEnter = function(self)
			local bantime = 0
		//	if tonumber(frame.txt:GetValue():Trim()) and tonumber(frame.txt3:GetValue():Trim()) then
				bantime = (tonumber(frame.txt:GetValue():Trim() * 60) or 0) + (tonumber(frame.txt3:GetValue():Trim()) or 0)
		//	end
			print(bantime)
			SCOREBOARD.PlayerRows[self:GetParent().Player]:Remove()
			SCOREBOARD.PlayerRows[self:GetParent().Player] = nil 
			SCOREBOARD:InvalidateLayout() 
			RunConsoleCommand("ulx", "ban", self:GetParent().Player:Nick(), bantime, (self:GetValue():Trim() == "" and "N/A" or self:GetValue():Trim()))
			frame:Close()
		end
		frame.txt2:SetVisible(true)
		
		frame.txt3 = vgui.Create("DTextEntry", frame)
		frame.txt3:SetSize(120, 20)
		frame.txt3:SetPos(160, 40)
		frame.txt3:RequestFocus()
		frame.txt3.OnKeyCodePressed = function(k)
			if k == KEY_TAB then
				frame.txt2:RequestFocus()
			end
		end
		frame.txt3.OnEnter = function(self)
			if tonumber(self:GetValue():Trim()) then
				frame.BanTime = (frame.BanTime or 0) + tonumber(self:GetValue():Trim())
				frame.txt2:RequestFocus()
			end
		end		
		frame.txt3:SetVisible(true)
		local btn = vgui.Create("DButton", frame)
		btn:SetSize(64, 20)
		btn:SetPos(frame:GetWide() - 70, frame:GetTall() - 30)
		btn:SetText("Ban")
		btn.DoClick = function(self)
			local bantime = 0
		//	if tonumber(frame.txt:GetValue():Trim()) and tonumber(frame.txt3:GetValue():Trim()) then
				bantime = (tonumber(frame.txt:GetValue():Trim() * 60) or 0) + (tonumber(frame.txt3:GetValue():Trim()) or 0)
		//	end
			print(bantime)
			SCOREBOARD.PlayerRows[self:GetParent().Player]:Remove()
			SCOREBOARD.PlayerRows[self:GetParent().Player] = nil 
			SCOREBOARD:InvalidateLayout() 
			RunConsoleCommand("ulx", "ban", self:GetParent().Player:Nick(), bantime, (frame.txt2:GetValue():Trim() == "" and "N/A" or frame.txt2:GetValue():Trim()))
			frame:Close()
		end
	end
	self.btnPWarrant = vgui.Create("RPPlayerWarrantButton", self)
	self.AdminSlot = vgui.Create("AdminSlot", self)

end

function PANEL:AddRating(icon, rating, desc)
	local pnl = vgui.Create("PlayerRatingButton", self)
	pnl:SetIcon(icon)
	pnl:SetRating(rating)
	pnl:SetPlayer(self.Player)
	pnl:SetDescription(desc)
	pnl:SetVisible(true)
	table.insert(self.Ratings, pnl)
end
	
/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:SetInfo(c, k, v, desc)
	if not v or v == "" then v = "N/A" end
	for k1, v1 in pairs(self.InfoLabels[c]) do
		if v1.Icon == k or v1.Key == k then
			if v1.Icon == "icon16/world.png" then
				v1:SetText(v[2])
				v1:SetFlag(v[1]) --because of http lag
			else
				v1:SetText(v)
			end
			return
		end
	end
	local len = table.Count(self.InfoLabels[c])
	self.InfoLabels[c][len + 1] = vgui.Create("PlayerInfoEntry", self)
	if k:sub(#k - 3, #k) == ".png" then
		self.InfoLabels[c][len + 1]:SetIcon(k)
		if k == "icon16/world.png" then
			self.InfoLabels[c][len + 1]:SetFlag(v[1]:lower())
		end
	else
		self.InfoLabels[c][len + 1]:SetKey(k)
	end
	self.InfoLabels[c][len + 1]:SetText(type(v) == "table" and v[2] or v)
	if desc then
		self.InfoLabels[c][len + 1]:SetDescription(desc)
	end
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer(ply)
	self.Player = ply
	self:UpdatePlayerData()
	self:AddRating("icon16/user.png", 1, "This Player Is A Good RolePlayer!")
	self:AddRating("icon16/emoticon_smile.png", 2, "Very Nice Roleplayer!")
	self:AddRating("icon16/heart.png", 3, "This player is Friendly!")
	self:AddRating("icon16/palette.png", 4, "This player is Smart!")
	self:AddRating("icon16/star.png", 5, "This player is Helpful!")
	self:AddRating("icon16/wrench.png", 6, "This Player Is A Good Builder!")
end

/*---------------------------------------------------------
Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not IsValid(self.Player) then return end


	self:SetInfo(1, "icon16/steam.png", self.Player:SteamID(), "The player's SteamID")
	self:SetInfo(1, "icon16/world.png", self.Player.CountryInfo, "The player's location")
	self:SetInfo(1, "icon16/medal_gold_1.png", self.Player:GetUserGroup(), "The player's usergroup")
	self:SetInfo(2, "icon16/clock.png", TimeStr(self.Player:GetUTimeTotalTime()), "How long the player has been playing")
	self:SetInfo(2, "icon16/fugue/block.png", self.Player:GetCount("props") + self.Player:GetCount("ragdolls") + self.Player:GetCount("effects"), "How many props the player has spawned")
	self:SetInfo(2, "icon16/car.png", self.Player:GetCount("vehicles") > 0 and "Yes" or "No", "Has the player got a car?")
	self:SetInfo(1, "icon16/money.png", "$" .. self.Player:getDarkRPVar("money"), "The player's money")
	self:SetInfo(2, "icon16/gun.png", self.Player:Frags(), "The player's kills")

	self:InvalidateLayout()
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
--function PANEL:ApplySchemeSettings()
--	for _k, column in pairs(self.InfoLabels) do
--		for k, v in pairs(column) do
--			v.Key:SetFGColor(0, 0, 0, _k == 2 and 120 or 100)
--			v.Value:SetFGColor(0, 70, 0, 200)
--		end
--	end
--end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()
	if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end

	self.PlayerUpdate = CurTime() + 0.25
	self:UpdatePlayerData()
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	local x = 5
	for colnum, column in pairs(self.InfoLabels) do
		local y = 0

		for k, v in pairs(column) do
			v:SetPos(x, y + ((v.Icon == "icon16/money.png" or v.Icon == "icon16/gun.png") and 17 or 0))
			v:SetSize(v:GetWide(), v.Icon and 18 or 15)
			y = y + v:GetTall() + 1
		end
		-- x = RightMost + 10
		x = x + 300
	end
	for k, p in ipairs(self.Ratings) do
		p:SetPos(self:GetWide() - (k * 25), 0)
	end

	if not self.Player or
		self.Player == LocalPlayer() or
		not AdminCheck(LocalPlayer()) then
			self.btnKick:SetVisible(false)
			self.btnBan:SetVisible(false)
			self.btnSpec:SetVisible(false)
			self.AdminSlot:SetVisible(false)
			self.InfoLabels[1][4]:SetVisible(false)
			self.InfoLabels[2][4]:SetVisible(false)
	else
		self.btnKick:SetVisible(true)
		self.btnBan:SetVisible(true)
		self.btnSpec:SetVisible(true)
	--	self.AdminSlot:SetVisible(true)

		self.btnSpec:SetPos(self:GetWide() - 52 * 3 - 8, 72)
		self.btnSpec:SetSize(48, 20)		
		
		self.btnBan:SetPos(self:GetWide() - 52 * 2 - 8, 72)
		self.btnBan:SetSize(48, 20)

		self.btnKick:SetPos(self:GetWide() - 52 - 8, 72)
		self.btnKick:SetSize(56, 20)
							
		self.AdminSlot:SetPos(3, 72)
		self.AdminSlot:SetSize(420, 20)

		self.InfoLabels[1][4]:SetVisible(true)
		self.InfoLabels[2][4]:SetVisible(true)
		--self.InfoLabels[2][3]:SetVisible(true)
		--self.InfoLabels[2][1]:SetTextPos(73)
		--self.InfoLabels[2][2]:SetTextPos(73)
		--self.InfoLabels[2][3]:SetTextPos(73)
	end
	
	local Team = LocalPlayer():Team()
	if self.Player ~= LocalPlayer() and ( Team == TEAM_POLICE or Team == TEAM_CHIEF or Team == TEAM_MAYOR ) then
		self.btnPWarrant:SetVisible(true)
		self.btnPWarrant:SetSize(self.btnPWarrant:GetWide(), 20)
		if LocalPlayer():IsAdmin() then
			self.btnPWarrant:SetPos(self:GetWide() - 52 * 4 - 24, 72)
		else
			self.btnPWarrant:SetPos(self:GetWide() - 68, 52)
		end
	else
		self.btnPWarrant:SetVisible(false)
	end

	--for k, v in ipairs(self.VoteButtons) do
	--	v:InvalidateLayout()
	--	v:SetPos(self:GetWide() -  k * 25, 0)
	--	v:SetSize(20, 32)
	--end
end

function PANEL:Paint()
	return true
end

vgui.Register("RPScorePlayerInfoCard", PANEL, "Panel")
