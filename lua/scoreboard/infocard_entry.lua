surface.CreateFont("DefaultBold", {
	font = "DefaultBold",
	size = 13,
	weight = 1000,
	antialias = true
})

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

PANEL = {}

function PANEL:Init()
	self.TextPos = 30
	--self:NoClipping(true)
end

function PANEL:SetText(txt)
	surface.SetFont("DefaultBold")
	local x = surface.GetTextSize(self.Key or "" .. txt)
	x = self.Icon and x + self.TextPos + 20 or x + self.TextPos
	if self.Flag then
		x = x + 20
	end
	self:SetSize(x, self:GetTall())
	self.Text = tostring(txt)
end

function PANEL:SetTextPos(pos)
	self.TextPos = pos
	self:SetText(self.Text)
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

function PANEL:SetIcon(icon)
	self.Icon = icon
	self.MatIcon = Material(icon)
end

function PANEL:SetKey(txt)
	self.Key = txt
end

function PANEL:SetFlag(txt)
	self.Flag = Material("icon16/flags/" .. txt .. ".png")
end

function PANEL:Paint(w, h)
	surface.SetFont("DefaultBold")
	surface.SetDrawColor(color_white)
	if self.Icon then
		surface.SetMaterial(self.MatIcon)
		surface.DrawTexturedRect(0, 0, 16, 16)
		surface.SetTextColor(Color(0, 0, 0, 120))
		surface.SetTextPos(17, 4)
		surface.DrawText(":")
	elseif self.Key then
		surface.SetTextColor(Color(0, 0, 0, 120))
		surface.SetTextPos(0, 0)
		surface.DrawText(self.Key)
	end
	if self.Flag then
		surface.SetMaterial(self.Flag)
		surface.DrawTexturedRect(w - 36, h - 14, 16, 11)
	end
	surface.SetTextColor(Color(0, 70, 0, 200))
	surface.SetTextPos(self.TextPos, self.Icon and 4 or 0)
	surface.DrawText(self.Text)
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

vgui.Register("PlayerInfoEntry", PANEL, "Panel")
