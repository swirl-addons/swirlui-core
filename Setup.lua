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

local function MinimapData()
    BugSackMinimapButton()
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

local function ApplyUISettings()
    ApplyChatBubbleSettings()
    ApplyUIErrorsSettings()
    ApplyActionStatusSettings()
    ApplyMouseClickSettings()
end

local function RegisterUISettingsCallbacks()
    local AF = _G.AbstractFramework
    if not AF then return end

    AF.RegisterCallback("SwirlUI_ChatBubbles_Changed", ApplyChatBubbleSettings, "medium", "ChatBubblesUpdate")
    AF.RegisterCallback("SwirlUI_UIErrors_Changed", ApplyUIErrorsSettings, "medium", "UIErrorsUpdate")
    AF.RegisterCallback("SwirlUI_ActionStatus_Changed", ApplyActionStatusSettings, "medium", "ActionStatusUpdate")
    AF.RegisterCallback("SwirlUI_AbstractFrameworkPopups_Changed", MoveAbstractFrameworkPopups, "medium", "AbstractFrameworkPopupsUpdate")
    AF.RegisterCallback("SwirlUI_MouseClick_Changed", ApplyMouseClickSettings, "medium", "MouseClickUpdate")
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
        mouseClick = { extraActionButton = true, lfgListFrame = true },
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