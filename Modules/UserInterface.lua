local _, SUI = ...
local C = SUI.Components

local function T() return SUI.Theme end

local userInterfaceTab

local function BuildUIScaleCard(scrollChild, y)
    local theme = T()
    local card  = C:CreateCard(scrollChild, "UI Scale")
    scrollChild:PlaceCard(card, y)

    local scaleSlider = C:CreateSlider(card, "UI Scale", 0.1, 2.0, 0.01,
        function() return tonumber(GetCVar("UIScale")) or 1 end,
        function(v) UIParent:SetScale(v); SetCVar("UIScale", v) end)
    card:AddWidget(scaleSlider, 36, theme.padding.small)

    local presets = { 0.53, 0.63, 0.71, 1.0 }
    local btnRow  = CreateFrame("Frame", nil, card)
    btnRow:SetHeight(24)
    card:AddWidget(btnRow, 24, theme.padding.small)

    C_Timer.After(0, function()
        local availW = btnRow:GetWidth()
        if availW <= 0 then availW = card:GetWidth() - theme.padding.med * 2 end
        local n    = #presets
        local btnW = math.floor((availW - (n - 1) * theme.padding.small) / n)
        for i, scale in ipairs(presets) do
            local b = C:CreateButton(btnRow, tostring(scale), {
                width    = btnW,
                height   = 24,
                callback = function()
                    SetCVar("UIScale", scale)
                    UIParent:SetScale(scale)
                    scaleSlider:SetVal(scale)
                    SUI.SettingsChanged = true
                end,
            })
            b:SetPoint("TOPLEFT", btnRow, "TOPLEFT", (i - 1) * (btnW + theme.padding.small), 0)
        end
    end)

    return y + card:GetHeight() + theme.padding.small
end

local function BuildChatBubblesCard(scrollChild, y)
    local theme = T()
    local card  = C:CreateCard(scrollChild, "Chat Bubbles")
    scrollChild:PlaceCard(card, y)

    local toggle = C:CreateToggle(card, "Enable",
        SwirlUIDB.uiSettings.chatBubbles.enabled,
        function(v)
            SwirlUIDB.uiSettings.chatBubbles.enabled = v
            SUI.SettingsChanged = true
        end)
    card:AddWidget(toggle, 36, theme.padding.small)

    local fsSlider = C:CreateSlider(card, "Font Size", 2, 24, 1,
        function() return SwirlUIDB.uiSettings.chatBubbles.fontSize end,
        function(v) SwirlUIDB.uiSettings.chatBubbles.fontSize = v end)
    card:AddWidget(fsSlider, 36, theme.padding.small)

    return y + card:GetHeight() + theme.padding.small
end

local function BuildOffsetCard(scrollChild, y, cardTitle, dbKey)
    local theme = T()
    local card  = C:CreateCard(scrollChild, cardTitle)
    scrollChild:PlaceCard(card, y)

    local db = SwirlUIDB.uiSettings[dbKey]

    local toggle = C:CreateToggle(card, "Enable", db.enabled,
        function(v) db.enabled = v; SUI.SettingsChanged = true end)
    card:AddWidget(toggle, 36, theme.padding.small)

    local fsSlider = C:CreateSlider(card, "Font Size", 8, 24, 1,
        function() return db.fontSize end,
        function(v) db.fontSize = v end)
    card:AddWidget(fsSlider, 36, theme.padding.small)

    local xSlider = C:CreateSlider(card, "X Offset", -500, 500, 1,
        function() return db.offsetX end,
        function(v) db.offsetX = v end)
    card:AddWidget(xSlider, 36, theme.padding.small)

    local ySlider = C:CreateSlider(card, "Y Offset", -500, 500, 1,
        function() return db.offsetY end,
        function(v) db.offsetY = v end)
    card:AddWidget(ySlider, 36, theme.padding.small)

    return y + card:GetHeight() + theme.padding.small
end

local function BuildMouseClickCard(scrollChild, y)
    local theme = T()
    local card  = C:CreateCard(scrollChild, "Mouse Click")
    scrollChild:PlaceCard(card, y)

    local function GetMC(k)
        return SwirlUIDB.uiSettings.mouseClick and SwirlUIDB.uiSettings.mouseClick[k] or false
    end
    local function SetMC(k, v)
        if not SwirlUIDB.uiSettings.mouseClick then
            SwirlUIDB.uiSettings.mouseClick = { extraActionButton = false, lfgListFrame = false }
        end
        SwirlUIDB.uiSettings.mouseClick[k] = v
        SUI.SettingsChanged = true
    end

    local extraToggle = C:CreateToggle(card, "Remove Empty Spacing around Extra Action Button",
        GetMC("extraActionButton"),
        function(v) SetMC("extraActionButton", v) end)
    card:AddWidget(extraToggle, 36, theme.padding.small)

    local lfgToggle = C:CreateToggle(card, "Enable Click-Through in LFG",
        GetMC("lfgListFrame"),
        function(v) SetMC("lfgListFrame", v) end)
    card:AddWidget(lfgToggle, 36, theme.padding.small)

    return y + card:GetHeight() + theme.padding.small
end

local function CreateUserInterfaceTab()
    local theme  = T()
    local parent = SUI.frames.userInterfaceContent

    userInterfaceTab = CreateFrame("Frame", "SwirlUI_UserInterfaceTab", parent)
    userInterfaceTab:SetAllPoints(parent)
    SUI.frames.userInterfaceTab = userInterfaceTab

    local scrollChild = C:CreateTabScroller(userInterfaceTab)

    local y = theme.padding.small
    y = BuildUIScaleCard(scrollChild, y)
    y = BuildChatBubblesCard(scrollChild, y)
    y = BuildOffsetCard(scrollChild, y, "UI Errors",     "uiErrors")
    y = BuildOffsetCard(scrollChild, y, "Action Status", "actionStatus")
    y = BuildMouseClickCard(scrollChild, y)

    scrollChild:Commit(y)
end

function SUI.BuildUserInterfaceTab()
    if not userInterfaceTab then
        CreateUserInterfaceTab()
    end
    userInterfaceTab:Show()
end
