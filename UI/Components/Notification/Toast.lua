local _, SUI = ...
local N = SUI.Components.Notification

local POPUP_W = 260
local POPUP_H = 52

local queue = {}
local active = false
local popup = nil

local function ShowNext()
    if active or #queue == 0 then return end
    if not popup then
        popup = N.BuildPanel("SUI_NotificationPopup", POPUP_W, POPUP_H, "TOOLTIP")
        local msg = popup:CreateFontString(nil, "OVERLAY")
        msg:SetPoint("LEFT", popup, "LEFT", 14, 0)
        msg:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
        msg:SetJustifyH("LEFT")
        msg:SetJustifyV("MIDDLE")
        N.ApplyFont(msg, "small")
        popup.msg = msg
    end
    active = true

    local item = table.remove(queue, 1)
    local dur = item.duration or 2

    N.SetBackdrop(popup, N.T().bgDark, N.T().border)
    N.ApplyAccent(popup)
    popup.msg:SetText(item.text)
    popup:ClearAllPoints()
    popup:SetPoint("TOP", UIParent, "TOP", 0, -100)

    N.FadeIn(popup)
    C_Timer.After(N.FADE_TIME + dur, function()
        N.FadeOut(popup, function()
            active = false
            ShowNext()
        end)
    end)
end

function SUI.Components.ShowToast(text, duration)
    table.insert(queue, { text = text, duration = duration })
    ShowNext()
end
