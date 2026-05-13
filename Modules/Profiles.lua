local _, SUI = ...
local C  = SUI.Components

local function T() return SUI.Theme end

local profilesTab
local scrollChild, genCard

local function CreateProfilesTab()
    local theme = T()
    local parent = SUI.frames.profilesContent

    profilesTab = CreateFrame("Frame", "SwirlUI_ProfilesTab", parent)
    profilesTab:SetAllPoints(parent)
    SUI.frames.profilesTab = profilesTab

    scrollChild = C:CreateTabScroller(profilesTab)

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

function SUI.BuildProfilesTab()
    if not profilesTab then
        CreateProfilesTab()
    end
    profilesTab:Show()
end
