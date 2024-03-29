﻿function MODULE:ShouldHideBars()
    return self.BarsDisabled
end

function MODULE:HUDShouldDraw(element)
    if table.HasValue(self.HiddenHUDElements, element) then return false end
end

function MODULE:HUDPaintBackground()
    if self:ShouldDrawBranchWarning() then self:DrawBranchWarning() end
    if self:ShouldDrawBlur() then self:DrawBlur() end
    self:RenderEntities()
end

function MODULE:HUDPaint()
    local weapon = LocalPlayer():GetActiveWeapon()
    if self:ShouldDrawAmmo(weapon) then self:DrawAmmo(weapon) end
    if self:ShouldDrawCrosshair() then self:DrawCrosshair() end
    if self:ShouldDrawVignette() then self:DrawVignette() end
end

function MODULE:ForceDermaSkin()
    return self.DarkTheme and "lilia_darktheme" or "lilia"
end

function MODULE:ShowPlayerCard(target, isStaff)
    if not isStaff then return end
    local playerCard = vgui.Create("DFrame")
    playerCard:SetSize(ScrW() * 0.35, ScrH() * 0.3)
    playerCard:Center()
    playerCard:SetTitle(target:Name())
    playerCard:MakePopup()
    local name = playerCard:Add("DLabel")
    name:SetFont("liaMediumFont")
    name:SetPos(ScrW() * 0.35 * 0.5, 30)
    name:SetText(target:Name())
    name:SizeToContents()
    name:SetTextColor(Color(255, 255, 255, 255))
    name:CenterHorizontal()
    local scroll = playerCard:Add("DScrollPanel")
    scroll:SetPos(0, 50)
    scroll:SetSize(ScrW() * 0.35 - 40, ScrH() * 0.25 - 20)
    scroll:Center()
    function scroll:Paint()
    end

    local desc = scroll:Add("DLabel")
    desc:SetPos(0, 185)
    desc:SetFont("liaSmallFont")
    desc:SetText("Description: " .. target:getChar():getDesc())
    desc:SetAutoStretchVertical(true)
    desc:SetWrap(true)
    desc:SetSize(ScrW() * 0.35, 10)
    desc:SetTextColor(Color(255, 255, 255, 255))
    desc:PerformLayout()
    local teamLabel = scroll:Add("DLabel")
    teamLabel:SetFont("liaSmallFont")
    teamLabel:SetText("Team: " .. team.GetName(target:Team()))
    teamLabel:SetTextColor(Color(255, 255, 255, 255))
    teamLabel:SizeToContents()
    teamLabel:SetPos(0, desc:GetTall() + 30)
    teamLabel:PerformLayout()
    local pingLabel = scroll:Add("DLabel")
    pingLabel:SetFont("liaSmallFont")
    pingLabel:SetText("Ping: " .. target:Ping())
    pingLabel:SetTextColor(Color(255, 255, 255, 255))
    pingLabel:SetPos(0, teamLabel:GetTall() + desc:GetTall() + 40)
    pingLabel:PerformLayout()
    local armorLabel = scroll:Add("DLabel")
    armorLabel:SetFont("liaSmallFont")
    armorLabel:SetText("Armor: " .. target:Armor())
    armorLabel:SetTextColor(Color(255, 255, 255, 255))
    armorLabel:SetPos(0, pingLabel:GetTall() + teamLabel:GetTall() + desc:GetTall() + 50)
    armorLabel:PerformLayout()
    local healthLabel = scroll:Add("DLabel")
    healthLabel:SetFont("liaSmallFont")
    healthLabel:SetText("Health: " .. target:Health())
    healthLabel:SetTextColor(Color(255, 255, 255, 255))
    healthLabel:SetPos(0, armorLabel:GetTall() + pingLabel:GetTall() + teamLabel:GetTall() + desc:GetTall() + 60)
    healthLabel:PerformLayout()
    local totalHeight = desc:GetTall() + teamLabel:GetTall() + pingLabel:GetTall() + armorLabel:GetTall() + healthLabel:GetTall() + 70
    local userGroupLabel = scroll:Add("DLabel")
    userGroupLabel:SetFont("liaSmallFont")
    userGroupLabel:SetText("User Group: " .. target:GetUserGroup())
    userGroupLabel:SetTextColor(Color(255, 255, 255, 255))
    userGroupLabel:SetPos(0, totalHeight)
    userGroupLabel:SetSize(500, userGroupLabel:GetTall())
    userGroupLabel:PerformLayout()
end