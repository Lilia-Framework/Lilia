﻿local PANEL = {}
local VoicePanels = {}
function PANEL:Init()
    local hi = vgui.Create("DLabel", self)
    hi:SetFont("liaIconsMedium")
    hi:Dock(LEFT)
    hi:DockMargin(8, 0, 8, 0)
    hi:SetTextColor(color_white)
    hi:SetText(" ")
    hi:SetWide(30)
    self.LabelName = vgui.Create("DLabel", self)
    self.LabelName:SetFont("liaMediumFont")
    self.LabelName:Dock(FILL)
    self.LabelName:DockMargin(0, 0, 0, 0)
    self.LabelName:SetTextColor(color_white)
    self.Color = color_transparent
    self:SetSize(280, 32 + 8)
    self:DockPadding(4, 4, 4, 4)
    self:DockMargin(2, 2, 2, 2)
    self:Dock(BOTTOM)
end

function PANEL:Setup(client)
    self.client = client
    self.name = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:getChar():getName()
    self.LabelName:SetText(self.name)
    self:InvalidateLayout()
end

function PANEL:Paint(w, h)
    if not IsValid(self.client) then return end
    lia.util.drawBlur(self, 1, 2)
    surface.SetDrawColor(0, 0, 0, 50 + self.client:VoiceVolume() * 50)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(255, 255, 255, 50 + self.client:VoiceVolume() * 120)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:Think()
    if IsValid(self.client) then self.LabelName:SetText(self.name) end
    if self.fadeAnim then self.fadeAnim:Run() end
end

function PANEL:FadeOut(anim, delta)
    if anim.Finished then
        if IsValid(VoicePanels[self.client]) then
            VoicePanels[self.client]:Remove()
            VoicePanels[self.client] = nil
            return
        end
        return
    end

    self:SetAlpha(255 - (255 * (delta * 2)))
end

vgui.Register("VoicePanel", PANEL, "DPanel")
function MODULE:PlayerStartVoice(client)
    if not IsValid(g_VoicePanelList) or not self.IsVoiceEnabled then return end
    hook.Run("PlayerEndVoice", client)
    if IsValid(VoicePanels[client]) then
        if VoicePanels[client].fadeAnim then
            VoicePanels[client].fadeAnim:Stop()
            VoicePanels[client].fadeAnim = nil
        end

        VoicePanels[client]:SetAlpha(255)
        return
    end

    if not IsValid(client) then return end
    local pnl = g_VoicePanelList:Add("VoicePanel")
    pnl:Setup(client)
    VoicePanels[client] = pnl
end

local function VoiceClean()
    for k, _ in pairs(VoicePanels) do
        if not IsValid(k) then hook.Run("PlayerEndVoice", k) end
    end
end

function MODULE:PlayerEndVoice(client)
    if IsValid(VoicePanels[client]) then
        if VoicePanels[client].fadeAnim then return end
        VoicePanels[client].fadeAnim = Derma_Anim("FadeOut", VoicePanels[client], VoicePanels[client].FadeOut)
        VoicePanels[client].fadeAnim:Start(2)
    end
end

local function CreateVoiceVGUI()
    gmod.GetGamemode().PlayerStartVoice = function() end
    gmod.GetGamemode().PlayerEndVoice = function() end
    if IsValid(g_VoicePanelList) then g_VoicePanelList:Remove() end
    g_VoicePanelList = vgui.Create("DPanel")
    g_VoicePanelList:ParentToHUD()
    g_VoicePanelList:SetSize(270, ScrH() - 200)
    g_VoicePanelList:SetPos(ScrW() - 320, 100)
    g_VoicePanelList:SetPaintBackground(false)
end

timer.Create("VoiceClean", 10, 0, VoiceClean)
hook.Add("InitPostEntity", "CreateVoiceVGUI", CreateVoiceVGUI)
