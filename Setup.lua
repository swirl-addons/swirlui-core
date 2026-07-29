local _, SUI = ...

local PLAYER_CLASS = select(2, UnitClass("player"))
local PLAYER_CLASS_COLOR = RAID_CLASS_COLORS[PLAYER_CLASS]
local PLAYER_CLASS_COLOR_HEX = CreateColor(PLAYER_CLASS_COLOR.r, PLAYER_CLASS_COLOR.g, PLAYER_CLASS_COLOR.b):GenerateHexColor()

local function DetailsRemoveShadows()
    if not C_AddOns.IsAddOnLoaded("Details") then return end
    
    for i = 1, 3 do
        local baseFrame = _G["DetailsBaseFrame" .. i]
        local windowFrame = _G["Details_WindowFrame" .. i]
        local attributeString = _G["DetailsAttributeStringInstance" .. i]
        
        if baseFrame and windowFrame and attributeString then
            attributeString:SetShadowColor(0, 0, 0, 0)
        end
    end
end

local function AddOnSetups()
    DetailsRemoveShadows()
end

local function BugSackMinimapButton()
    if not C_AddOns.IsAddOnLoaded("BugSack") then return end
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end

    local bugSackLDB = LDB:GetDataObjectByName("BugSack")
    if not bugSackLDB then return end

    local bugAddon = _G["BugSack"]
    if not bugAddon or not bugAddon.UpdateDisplay or not bugAddon.GetErrors then return end

    if _G["SwirlUIBugSackButton"] then return end
    local SwirlUIBugSackButton = CreateFrame("Button", "SwirlUIBugSackButton", UIParent, "BackdropTemplate")
    SwirlUIBugSackButton:SetSize(22, 22)
    SwirlUIBugSackButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)
    SwirlUIBugSackButton.Text = SwirlUIBugSackButton:CreateFontString(nil, "OVERLAY")
    SwirlUIBugSackButton.Text:SetFont(SUI.Theme.font.path, 16, "OUTLINE")
    SwirlUIBugSackButton.Text:SetPoint("CENTER", SwirlUIBugSackButton, "CENTER", 0, 0)
    SwirlUIBugSackButton.Text:SetTextColor(1, 1, 1)
    SwirlUIBugSackButton.Text:SetText("|cFF49AF4C0|r")
    SwirlUIBugSackButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    SwirlUIBugSackButton:SetBackdropColor(6/255, 8/255, 8/255, 0.75)
    SwirlUIBugSackButton:SetBackdropBorderColor(0, 0, 0, 1)

    SwirlUIBugSackButton:SetScript("OnClick", function(self, mouseButton)
        if bugSackLDB.OnClick then
            bugSackLDB.OnClick(self, mouseButton)
        end
    end)

    SwirlUIBugSackButton:SetScript("OnEnter", function(self)
        if bugSackLDB.OnTooltipShow then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            SwirlUIBugSackButton:SetBackdropBorderColor(PLAYER_CLASS_COLOR.r, PLAYER_CLASS_COLOR.g, PLAYER_CLASS_COLOR.b, 1)
            bugSackLDB.OnTooltipShow(GameTooltip)
            GameTooltip:Show()
        end
    end)

    SwirlUIBugSackButton:SetScript("OnLeave", function()
        SwirlUIBugSackButton:SetBackdropBorderColor(0, 0, 0, 1)
        GameTooltip:Hide()
    end)

    hooksecurefunc(bugAddon, "UpdateDisplay", function()
        local count = #bugAddon:GetErrors(BugGrabber:GetSessionId())
        if count == 0 then
            SwirlUIBugSackButton.Text:SetText("|cFF49AF4C" .. count .. "|r")
        else
            SwirlUIBugSackButton.Text:SetText("|cFFC63F3F" .. count .. "|r")
        end
    end)
end

local function MailMinimapDataText()
    local SwirlUIMailButton = CreateFrame("Frame", "SwirlUIMailButton", UIParent)
    SwirlUIMailButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -5, -2)

    SwirlUIMailButton.texture = SwirlUIMailButton:CreateTexture(nil, "OVERLAY")
    SwirlUIMailButton.texture:SetAllPoints(SwirlUIMailButton)
    SwirlUIMailButton.texture:SetTexture("Interface\\AddOns\\SwirlUI\\Media\\mail.tga")
    SwirlUIMailButton:SetSize(16, 16)

    SwirlUIMailButton:RegisterEvent("UPDATE_PENDING_MAIL")
    
    function SwirlUIMailButton:UpdateMailVisibility()
        if HasNewMail() then
            self:Show()
        else
            self:Hide()
        end
    end

    SwirlUIMailButton:SetScript("OnEvent", function(self, event)
        if event == "UPDATE_PENDING_MAIL" then
            self:UpdateMailVisibility()
        end
    end)

    SwirlUIMailButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddLine("Unread mail from:")
        local m1, m2, m3 = GetLatestThreeSenders()
        GameTooltip:AddLine(m1)
        GameTooltip:AddLine(m2)
        GameTooltip:AddLine(m3)
        GameTooltip:Show()
    end)

    SwirlUIMailButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    SwirlUIMailButton:UpdateMailVisibility()
end

local function MinimapData()
    BugSackMinimapButton()
    MailMinimapDataText()
end

local function ApplyChatBubbleSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.chatBubbles.enabled then
        ChatBubbleFont:SetFont(SUI.Theme.font.path, SwirlUIDB.uiSettings.chatBubbles.fontSize, "OUTLINE")
    end
end

local function ApplyUIErrorsSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.uiErrors.enabled then
        UIErrorsFrame:SetFont(SUI.Theme.font.path, SwirlUIDB.uiSettings.uiErrors.fontSize, "OUTLINE")
        UIErrorsFrame:SetShadowOffset(0, 0)
        UIErrorsFrame:ClearAllPoints()
        UIErrorsFrame:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.uiErrors.offsetX, SwirlUIDB.uiSettings.uiErrors.offsetY)
    end
end

local function ApplyActionStatusSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.actionStatus.enabled then
        ActionStatus.Text:SetFont(SUI.Theme.font.path, SwirlUIDB.uiSettings.actionStatus.fontSize, "OUTLINE")
        ActionStatus.Text:SetShadowOffset(0, 0)
        ActionStatus.Text:ClearAllPoints()
        ActionStatus.Text:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.actionStatus.offsetX, SwirlUIDB.uiSettings.actionStatus.offsetY)
    end
end

function ApplyMouseClickSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.mouseClick then
        if SwirlUIDB.uiSettings.mouseClick.lfgListFrame then
            local frame = LFGListFrame.ApplicationViewer.UnempoweredCover
            if frame then
                frame:EnableMouse(false)
                frame:EnableMouseWheel(false)
                frame:SetToplevel(false)
            end
        end
        if SwirlUIDB.uiSettings.mouseClick.extraActionButton then
            ExtraActionBarFrame:EnableMouse(false)
            ExtraAbilityContainer:EnableMouse(false)
        end
    end
end

local function CreateAuraBorder(auraFrame, icon)
    if auraFrame.Border then return end
    icon = icon or auraFrame.Icon

    local border = CreateFrame("Frame", nil, auraFrame)
    border:SetAllPoints(icon)
    border:SetFrameLevel(auraFrame:GetFrameLevel() - 1)
    auraFrame.Border = border

    local borders = {
        {points = {"TOPLEFT", "TOPRIGHT"}, size = "Height"},
        {points = {"BOTTOMLEFT", "BOTTOMRIGHT"}, size = "Height"},
        {points = {"TOPLEFT", "BOTTOMLEFT"}, size = "Width"},
        {points = {"TOPRIGHT", "BOTTOMRIGHT"}, size = "Width"},
    }

    for _, borderData in ipairs(borders) do
        local edge = border:CreateTexture(nil, "OVERLAY")
        edge:SetColorTexture(0, 0, 0, 1)
        edge:SetPoint(borderData.points[1], 0, 0)
        edge:SetPoint(borderData.points[2], 0, 0)
        edge["Set" .. borderData.size](edge, 1)
    end
end

local function FormatCompactDuration(timeLeft)
    if timeLeft >= 86400 then
        return string.format("%dd", math.floor(timeLeft / 86400 + 0.5))
    end
    if timeLeft >= 3600 then
        return string.format("%dh", math.floor(timeLeft / 3600 + 0.5))
    end
    if timeLeft >= 60 then
        return string.format("%dm", math.floor(timeLeft / 60 + 0.5))
    end
    return string.format("%d", math.floor(timeLeft + 0.5))
end

local function SkinAuras(auraFrame)
    if auraFrame.isAuraAnchor or not auraFrame.Icon then return end

    local auraSettings = SwirlUIDB.uiSettings.skinAuras
    auraFrame.Icon:SetSize(auraSettings.width or 37, auraSettings.height or 37)
    auraFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    if auraFrame.DebuffBorder then
        auraFrame.DebuffBorder:Hide()
        auraFrame.DebuffBorder:SetAlpha(0)
        auraFrame.DebuffBorder:SetTexture(nil)
    elseif auraFrame.BuffBorder then
        auraFrame.BuffBorder:SetTexture(nil)
    end

    if not auraFrame.Border then
        CreateAuraBorder(auraFrame)
    end

    local width, height = auraFrame:GetSize()
    if width and height and width > 0 and height > 0 then
        auraFrame.Border:ClearAllPoints()
        auraFrame.Border:SetPoint("TOPLEFT", auraFrame.Icon, "TOPLEFT", -1, 1)
        auraFrame.Border:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 1, -1)
    end

    local fontSize = auraSettings.fontSize or 12

    if auraFrame.Duration then
        auraFrame.Duration:ClearAllPoints()
        auraFrame.Duration:SetPoint("CENTER", auraFrame.Icon, "CENTER", 0, 0)
        auraFrame.Duration:SetFont(SUI.Theme.font.path, fontSize, "OUTLINE")
        auraFrame.Duration:SetShadowOffset(0, 0)

        if not auraFrame._swirlDurationHooked and type(auraFrame.UpdateDuration) == "function" then
            auraFrame._swirlDurationHooked = true
            hooksecurefunc(auraFrame, "UpdateDuration", function(self, timeLeft)
                if not (SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.enabled) then return end
                if type(timeLeft) ~= "number" then return end
                if issecretvalue and issecretvalue(timeLeft) then return end
                if timeLeft <= 0 then return end
                self.Duration:SetText(FormatCompactDuration(timeLeft))
            end)
        end
    end

    if auraFrame.Count then
        auraFrame.Count:ClearAllPoints()
        auraFrame.Count:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 0, 1)
        auraFrame.Count:SetFont(SUI.Theme.font.path, fontSize, "OUTLINE")
    end
end

local function SkinAuraFrames()
    local frames = {BuffFrame, DebuffFrame}
    for _, frame in pairs(frames) do
        if frame and frame.auraFrames then
            if frame.CollapseAndExpandButton then
                frame.CollapseAndExpandButton:SetAlpha(0)
                frame.CollapseAndExpandButton:SetScript("OnClick", nil)
            end

            for _, auraFrame in pairs(frame.auraFrames) do
                SkinAuras(auraFrame)
            end
        end
    end
end

local auraHooksInstalled = false
local function SetupAuraHooks()
    if auraHooksInstalled then return end
    auraHooksInstalled = true
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(DebuffFrame, "UpdateAuraButtons", function() SkinAuraFrames() end)
end

function SUI.ApplyAuraSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.enabled then
        SkinAuraFrames()
        SetupAuraHooks()
    end
end

local function SkinExtraButton(button)
    local icon = button.Icon or button.icon
    if not icon then return end

    if button.IconMask then button.IconMask:Hide() end

    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    local normal = button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture())
    if normal then normal:SetAlpha(0) end
    if button.style then button.style:SetAlpha(0) end

    if not button.Border then
        CreateAuraBorder(button, icon)
    end
    button.Border:Show()
    button.Border:ClearAllPoints()
    button.Border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    button.Border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
end

local function SkinExtraButtons()
    if ZoneAbilityFrame then
        if ZoneAbilityFrame.Style then ZoneAbilityFrame.Style:SetAlpha(0) end
        if ZoneAbilityFrame.SpellButtonContainer then
            for _, button in pairs({ZoneAbilityFrame.SpellButtonContainer:GetChildren()}) do
                SkinExtraButton(button)
            end
        end
    end
    if ExtraActionButton1 then
        SkinExtraButton(ExtraActionButton1)
    end
end

local extraButtonHooksInstalled = false
local function SetupExtraButtonHooks()
    if extraButtonHooksInstalled then return end
    extraButtonHooksInstalled = true
    if ZoneAbilityFrame and ZoneAbilityFrame.SpellButtonContainer and ZoneAbilityFrame.SpellButtonContainer.SetContents then
        hooksecurefunc(ZoneAbilityFrame.SpellButtonContainer, "SetContents", SkinExtraButtons)
    end
    if ExtraActionBarFrame then
        ExtraActionBarFrame:HookScript("OnShow", SkinExtraButtons)
    end
end

function SUI.ApplyExtraButtonSkin()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinExtraButtons and SwirlUIDB.uiSettings.skinExtraButtons.enabled then
        SkinExtraButtons()
        SetupExtraButtonHooks()
    end
end

local function ApplyUISettings()
    ApplyChatBubbleSettings()
    ApplyUIErrorsSettings()
    ApplyActionStatusSettings()
    ApplyMouseClickSettings()
    SUI.ApplyAuraSettings()
    SUI.ApplyExtraButtonSkin()
    SUI.Skins:Run()
end

local function CheckProfileVersionUpdates()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    for _, profile in ipairs(SUI.ImportProfiles) do
        if (profile.string or profile.data) and IsAddOnLoaded(profile.name) then
            local currentVersion = profile.version
            local storedVersion = SwirlUIDB.profileVersions[profile.name]
            
            if storedVersion and storedVersion ~= currentVersion then
                local addonColor = WrapTextInColorCode(profile.name, profile.color)
                local versionColor = WrapTextInColorCode(currentVersion, SUI.Friendly)
                SUI.Utils:Print(string.format("Update available for %s to v%s", addonColor, versionColor))
            end
        end
    end
end

local function CheckProfilesReady()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    local readyProfiles = {}

    for _, profile in ipairs(SUI.Utils:GetAllProfiles()) do
        local status = SUI.Utils:GetAddonStatus(profile)
        if status == SUI.STATUS.READY then
            table.insert(readyProfiles, profile)
        end
    end

    if #readyProfiles > 0 then
        local readyCount = #readyProfiles
        local readyColor = WrapTextInColorCode(string(readyCount), SUI.Theme.warning)
        SUI.Utils:Print(string.format("Profiles ready: %s", readyColor))
    end
end

local function SetupDB()
    if not SwirlUIDB then
        SwirlUIDB = {
            profileVersions = {},
            uiSettings = {},
        }
    end

    if not SwirlUIDB.profileVersions then
        SwirlUIDB.profileVersions = {}
    end

    local defaultUiSettings = {
        silence = false,
        chatBubbles = { enabled = true, fontSize = 8 },
        uiErrors = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        actionStatus = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        mouseClick = { extraActionButton = true, lfgListFrame = true },
        skinAuras = { enabled = true, width = 37, height = 37, fontSize = 12 },
        skinExtraButtons = { enabled = true },
        skins = { enabled = true, rareScanner = true, waypointUI = false },
    }

    if not SwirlUIDB.uiSettings then
        SwirlUIDB.uiSettings = {}
    end

    for key, defaultValue in pairs(defaultUiSettings) do
        if SwirlUIDB.uiSettings[key] == nil then
            SwirlUIDB.uiSettings[key] = defaultValue
        elseif type(defaultValue) == "table" and type(SwirlUIDB.uiSettings[key]) == "table" then
            for subKey, subDefault in pairs(defaultValue) do
                if SwirlUIDB.uiSettings[key][subKey] == nil then
                    SwirlUIDB.uiSettings[key][subKey] = subDefault
                end
            end
        elseif type(defaultValue) ~= type(SwirlUIDB.uiSettings[key]) then
            SwirlUIDB.uiSettings[key] = defaultValue
        end
    end
end

function SUI:Initialize()
    SetupDB()

    ApplyUISettings()
    AddOnSetups()
    MinimapData()

    CheckProfileVersionUpdates()
    CheckProfilesReady()
end