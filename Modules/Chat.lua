local _, SUI = ...

local GROUP_CHAT = { PARTY = true, RAID = true, INSTANCE_CHAT = true }
local ROLE_ICONS = { TANK = INLINE_TANK_ICON, HEALER = INLINE_HEALER_ICON, DAMAGER = INLINE_DAMAGER_ICON }

local function Enabled()
    local settings = SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.chatRoleIcons
    return settings and settings.enabled
end

local function RoleIcon(link, name, chatType)
    if not GROUP_CHAT[chatType] then return end
    local role = UnitGroupRolesAssigned(Ambiguate(name, "none"))
    local icon = not issecretvalue(role) and ROLE_ICONS[role]
    return icon and (icon .. link)
end

-- works on the finished line, so it doesn't care which chat addon built it
local function AddRoleIcons(text)
    if issecretvalue(text) or type(text) ~= "string" then return text end
    if not Enabled() or not text:find("|Hplayer:", 1, true) then return text end
    return (text:gsub("(|Hplayer:([^:|]+):%-?%d+:(%u[%u_]*))", RoleIcon))
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = _G["ChatFrame" .. i]
        -- 2 is the combat log
        if frame and i ~= 2 then
            local AddMessage = frame.AddMessage
            frame.AddMessage = function(chat, text, ...)
                return AddMessage(chat, AddRoleIcons(text), ...)
            end
        end
    end
end)
