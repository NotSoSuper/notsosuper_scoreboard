local PANEL = {}
function PANEL:Init() self:SetText("") end
/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:DoClick()
	if not self:GetParent().Player or LocalPlayer() == self:GetParent().Player then return end
 
	SCOREBOARD.PlayerRows[self:GetParent().Player]:Remove()
	SCOREBOARD.PlayerRows[self:GetParent().Player] = nil 
	SCOREBOARD:InvalidateLayout() 
	self:DoCommand(self:GetParent().Player)
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint(w, h)
	local bgColor = Color(0,0,0,30)

	if self.Selected then
		bgColor = Color(0, 200, 255, 255)
	elseif self.Armed then
		bgColor = Color(255, 255, 0, 255)
	end

	draw.RoundedBox(4, 0, 0, w, h, bgColor)
	draw.SimpleText(self.Text or "", "DefaultSmall", w / 2, h / 2, Color(0,0,0,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("RPSpawnMenuAdminButton", PANEL, "Button")

/*   PlayerKickButton */

PANEL = {}
PANEL.Text = "(un)Wanted"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	if ply.DarkRPVars.wanted then
		RunConsoleCommand("say", "/unwanted " .. tostring( ply:UserID()))
	else
		RunConsoleCommand("say", "/wanted " .. tostring( ply:UserID()))
		Derma_StringRequest("wanted", "Type in a reason:", nil, 
							function(a) 
							LocalPlayer():ConCommand("say /wanted ".. tostring(ply:UserID()).." ".. a)
							end, function() end )
	end
end

vgui.Register("RPPlayerWarrantButton", PANEL, "RPSpawnMenuAdminButton")
