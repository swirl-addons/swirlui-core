local _, SwirlUI = ...

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
    SwirlUIBugSackButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 1.5, 1.5)
    SwirlUIBugSackButton.Text = SwirlUIBugSackButton:CreateFontString(nil, "OVERLAY")
    SwirlUIBugSackButton.Text:SetFont(SwirlUI.Font, 16, "OUTLINE")
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
    SwirlUIMailButton.texture:SetTexture("Interface\\AddOns\\SwirlUI\\media\\mail.tga")
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

local function SetupFrameAlphas()
    local Frames = {
        ZoneTextFrame,
        SubZoneTextFrame,
        ObjectiveTrackerFrame.Header.Background,
        QuestObjectiveTracker.Header.Background,
        WorldQuestObjectiveTracker.Header.Background,
        ScenarioObjectiveTracker.Header.Background,
        MonthlyActivitiesObjectiveTracker.Header.Background,
        BonusObjectiveTracker.Header.Background,
        ProfessionsRecipeTracker.Header.Background,
        AchievementObjectiveTracker.Header.Background,
        CampaignQuestObjectiveTracker.Header.Background,
    }
    for _, Frame in pairs(Frames) do
        Frame:SetAlpha(0)
        Frame:Hide()
        Frame:SetScript("OnShow", function(Frame) 
            Frame:SetAlpha(0)
            Frame:Hide()
        end)
    end
end

local function ApplyChatBubbleSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.chatBubbles.enabled then
        ChatBubbleFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.chatBubbles.fontSize, "OUTLINE")
    end
end

local function ApplyUIErrorsSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.uiErrors.enabled then
        UIErrorsFrame:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.uiErrors.fontSize, "OUTLINE")
        UIErrorsFrame:SetShadowOffset(0, 0)
        UIErrorsFrame:ClearAllPoints()
        UIErrorsFrame:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.uiErrors.offsetX, SwirlUIDB.uiSettings.uiErrors.offsetY)
    end
end

local function ApplyActionStatusSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.actionStatus.enabled then
        ActionStatus.Text:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.actionStatus.fontSize, "OUTLINE")
        ActionStatus.Text:SetShadowOffset(0, 0)
        ActionStatus.Text:ClearAllPoints()
        ActionStatus.Text:SetPoint("CENTER", UIParent, "CENTER", SwirlUIDB.uiSettings.actionStatus.offsetX, SwirlUIDB.uiSettings.actionStatus.offsetY)
    end
end

local function ApplyQuestObjectivesSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.questObjectives.enabled then
        ObjectiveTrackerLineFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.questObjectives.fontSize, "OUTLINE")
        ObjectiveTrackerLineFont:SetShadowOffset(0, 0)
        ObjectiveTrackerHeaderFont:SetFont(SwirlUI.Font, SwirlUIDB.uiSettings.questObjectives.fontSize, "OUTLINE")
        ObjectiveTrackerHeaderFont:SetShadowOffset(0, 0)
        if SwirlUIDB.uiSettings.questObjectives.removeGraphics then
            SetupFrameAlphas()
        end
    end
end

local function MoveAbstractFrameworkPopups()
    if AFConfig then
        if SwirlUIDB.uiSettings.moveAFPopups then
            AFConfig["popups"] = {
                ["orientation"] = "top_to_bottom",
                ["position"] = {
                    "TOP",
                    0,
                    -100,
                },
            }
        else
            AFConfig["popups"] = nil
        end
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

local function CreateAuraBorder(auraFrame)
    if auraFrame.Border then return end

    local border = CreateFrame("Frame", nil, auraFrame)
    border:SetAllPoints(auraFrame.Icon)
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

local function SkinAuras(auraFrame)
    if auraFrame.isAuraAnchor or not auraFrame.Icon then return end

    local auraSizes = SwirlUIDB.uiSettings.skinAuras
    auraFrame.Icon:SetSize(auraSizes.width or 32, auraSizes.height or 32)
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

    if auraFrame.Duration then
        auraFrame.Duration:ClearAllPoints()
        auraFrame.Duration:SetPoint("CENTER", auraFrame.Icon, "CENTER", 0, 0)
        local fontSize = (SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.fontSize) or 12
        auraFrame.Duration:SetFont(SwirlUI.Font, fontSize, "OUTLINE")
        auraFrame.Duration:SetShadowOffset(0, 0)
    end

    if auraFrame.Count then
        auraFrame.Count:ClearAllPoints()
        auraFrame.Count:SetPoint("BOTTOMRIGHT", auraFrame.Icon, "BOTTOMRIGHT", 0, 1)
        local fontSize = (SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.fontSize) or 12
        auraFrame.Count:SetFont(SwirlUI.Font, fontSize, "OUTLINE")
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

local function SetupAuraHooks()
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() SkinAuraFrames() end)
    hooksecurefunc(DebuffFrame, "UpdateAuraButtons", function() SkinAuraFrames() end)
end

local function ApplyAuraSettings()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.skinAuras and SwirlUIDB.uiSettings.skinAuras.enabled then
        SkinAuraFrames()
        SetupAuraHooks()
    end
end

local function ApplyUISettings()
    ApplyChatBubbleSettings()
    ApplyUIErrorsSettings()
    ApplyActionStatusSettings()
    ApplyQuestObjectivesSettings()
    ApplyMouseClickSettings()
    ApplyAuraSettings()
end

local function RegisterUISettingsCallbacks()
    local AF = _G.AbstractFramework
    if not AF then return end

    AF.RegisterCallback("SwirlUI_ChatBubbles_Changed", ApplyChatBubbleSettings, "medium", "ChatBubblesUpdate")
    AF.RegisterCallback("SwirlUI_UIErrors_Changed", ApplyUIErrorsSettings, "medium", "UIErrorsUpdate")
    AF.RegisterCallback("SwirlUI_ActionStatus_Changed", ApplyActionStatusSettings, "medium", "ActionStatusUpdate")
    AF.RegisterCallback("SwirlUI_QuestObjectives_Changed", ApplyQuestObjectivesSettings, "medium", "QuestObjectivesUpdate")
    AF.RegisterCallback("SwirlUI_AbstractFrameworkPopups_Changed", MoveAbstractFrameworkPopups, "medium", "AbstractFrameworkPopupsUpdate")
    AF.RegisterCallback("SwirlUI_MouseClick_Changed", ApplyMouseClickSettings, "medium", "MouseClickUpdate")
    AF.RegisterCallback("SwirlUI_Auras_Changed", ApplyAuraSettings, "medium", "AurasUpdate")
end

local function CheckProfileVersionUpdates()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    for _, profile in ipairs(SwirlUI.ImportProfiles) do
        if (profile.string or profile.data) and IsAddOnLoaded(profile.name) then
            local currentVersion = profile.version
            local storedVersion = SwirlUIDB.profileVersions[profile.name]
            
            if storedVersion and storedVersion ~= currentVersion then
                local addonColor = SwirlUI.ApplyColor(profile.name, profile.color)
                local versionColor = SwirlUI.ApplyColor(currentVersion, SwirlUI.Friendly)
                SwirlUI.Utils:Print(string.format("Update available for %s to v%s", addonColor, versionColor))
            end
        end
    end
end

local function CheckProfilesReady()
    if SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.silence then return end
    local readyProfiles = {}
    
    for _, profile in ipairs(SwirlUI.Utils:GetAllProfiles()) do
        local status = SwirlUI.Utils:GetAddonStatus(profile)
        if status == SwirlUI.STATUS.READY then
            table.insert(readyProfiles, profile)
        end
    end
    
    if #readyProfiles > 0 then
        local readyCount = #readyProfiles
        local readyColor = SwirlUI.ApplyColor(readyCount, SwirlUI.Neutral)
        SwirlUI.Utils:Print(string.format("Profiles ready: %s", readyColor))
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
        moveAFPopups = true,
        chatBubbles = { enabled = true, fontSize = 8 },
        uiErrors = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        actionStatus = { enabled = true, fontSize = 12, offsetX = 0, offsetY = 200 },
        questObjectives = { enabled = true, fontSize = 12, removeGraphics = true },
        chat = { disableChatShadows = true },
        mouseClick = { extraActionButton = true, lfgListFrame = true },
        skinAuras = { enabled = true, width = 32, height = 32, fontSize = 12 },
        tooltip = { enabled = true, attachToCursor = true },
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

    -- setting default popup location instead of asking user
    MoveAbstractFrameworkPopups()
end

function SwirlUI:Initialize()
    SetupDB()

    ApplyUISettings()
    RegisterUISettingsCallbacks()
    AddOnSetups()
    MinimapData()

    CheckProfileVersionUpdates()
    CheckProfilesReady()
end