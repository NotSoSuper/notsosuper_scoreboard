surface.CreateFont("Default", {
	font = "Default",
	size = 13,
	weight = 500,
	antialias = true
})

local PANEL = {}

function PANEL:Init()
	self.Text = "Sample text"
	self.a = 255
	self.ta = 255
	local oldsize = self.SetSize
	self.SetSize = function(self, w, h)
	oldsize(self, w, h)
	end
end

function PANEL:SetText(txt)
	self.Text = txt
	surface.SetFont("Default")
	local w = surface.GetTextSize(txt)
	w = w + 10
	self:SetSize(w, self:GetTall())
end

function PANEL:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 255))
	draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(255, 255, 200, 255))
	surface.SetFont("Default")
	surface.SetTextColor(Color(0, 0, 0, 255))
	surface.SetTextPos(5, 2)
	surface.DrawText(self.Text)
end

vgui.Register("InfoBaloon", PANEL, "Panel")

PANEL  = {}

function PANEL:Init()
	self.Icon = ""
	self.Rating = 0
	self.Player = NULL
	self:SetSize(20, 36)
	self:SetText("")
end

function PANEL:SetIcon(icon)
	self.Icon = Material(icon)
end

function PANEL:SetRating(rating)
	self.Rating = rating
end

function PANEL:SetDescription(txt)
	if self.desc then return end
	self.desc = vgui.Create("InfoBaloon", self)
	local x, y = self:GetPos()
	self.desc:SetPos(x - 12, y - 12)
	self.desc:SetSize(1, 20)
	self.desc:SetText(txt)
	self.desc:SetVisible(false)
	self.desc:NoClipping(true)
end

function PANEL:SetPlayer(ply)
	self.Player = ply
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(Color(0, 0, 0, 30))
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(color_white)
	surface.SetMaterial(self.Icon)
	surface.DrawTexturedRect(2, 2, 16, 16)
	surface.SetFont("Default")
	surface.SetTextColor(Color(0, 0, 0, 150))
	local wi = surface.GetTextSize(tostring(self.Player.Ratings[self.Rating]))
	surface.SetTextPos(w / 2 - wi / 2, 20)
	surface.DrawText(tostring(self.Player.Ratings[self.Rating]))
end

function PANEL:DoClick()
	RunConsoleCommand("rateuser", self.Player:UserID(), self.Rating)
end

function PANEL:OnCursorEntered()
	timer.Simple(0.7, function()
	if self:IsVisible() and self.desc then
		local x, y = self:CursorPos()
		if x > 0 and x < self:GetWide() and y > 0 and y < self:GetTall() then
			self.desc:SetVisible(true) 
		end
	end
	end)
end

function PANEL:Think()
	local x, y = self:CursorPos()
	if x < 0 or x > self:GetWide() or y < 0 or y > self:GetTall() then
		if self.desc then self.desc:SetVisible(false) end
	end
end

vgui.Register("PlayerRatingButton", PANEL, "Button")

 