local _, SUI = ...
local C  = SUI.Components

local function T() return SUI.Theme end

local generalTab
local scrollChild, genCard

local function CreateGeneralTab()
    local theme = T()
    local parent = SUI.frames.generalContent

    generalTab = CreateFrame("Frame", "SwirlUI_GeneralTab", parent)
    generalTab:SetAllPoints(parent)
    SUI.frames.generalTab = generalTab

    scrollChild = C:CreateTabScroller(generalTab)

    local y = theme.padding.small

    genCard = C:CreateCard(scrollChild, "General Settings")
    scrollChild:PlaceCard(genCard, y)

    local silenceToggle = C:CreateToggle(genCard, string.format("Silence %s Chat Messages", SUI.NameNoCore),
        SwirlUIDB.uiSettings.silence,
        function(val)
            SwirlUIDB.uiSettings.silence = val
            SUI.SettingsChanged = true
        end)
    genCard:AddWidget(silenceToggle, 36, theme.padding.small)

    y = y + genCard:GetHeight() + theme.padding.small

end

function SUI.BuildGeneralTab()
    if not generalTab then
        CreateGeneralTab()
    end
    generalTab:Show()
end
