local _, SUI = ...
local C = SUI.Components
local T, ApplyFont, SetBackdrop, AnimateBorderColor = C.T, C.ApplyFont, C.SetBackdrop, C.AnimateBorderColor

function C:CreateButton(parent, labelText, config)
    config = config or {}
    local theme    = T()
    local width    = config.width    or 120
    local height   = config.height   or 24
    local callback = config.callback or function() end
    local tooltip  = config.tooltip

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    SetBackdrop(btn, theme.bgMedium, theme.border)

    local animGroup = btn:CreateAnimationGroup()
    local anim      = animGroup:CreateAnimation("Animation")
    anim:SetDuration(0.15)
    local fromColor = { r = 0, g = 0, b = 0 }
    local toColor   = { r = 0, g = 0, b = 0 }

    animGroup:SetScript("OnUpdate", function(self)
        local p = self:GetProgress() or 0
        btn:SetBackdropBorderColor(
            fromColor.r + (toColor.r - fromColor.r) * p,
            fromColor.g + (toColor.g - fromColor.g) * p,
            fromColor.b + (toColor.b - fromColor.b) * p, 1)
    end)
    animGroup:SetScript("OnFinished", function()
        btn:SetBackdropBorderColor(toColor.r, toColor.g, toColor.b, 1)
    end)

    local label = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(label, "normal")
    label:SetText(labelText or "")
    label:SetTextColor(theme.accent[1], theme.accent[2], theme.accent[3], 1)
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.label = label

    btn:SetScript("OnEnter", function()
        local ac = T().accent
        toColor.r, toColor.g, toColor.b = ac[1], ac[2], ac[3]
        AnimateBorderColor(btn, animGroup, fromColor, toColor)
        if tooltip then
            GameTooltip:SetOwner(btn, "ANCHOR_TOP")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        local bd = T().border
        toColor.r, toColor.g, toColor.b = bd[1], bd[2], bd[3]
        AnimateBorderColor(btn, animGroup, fromColor, toColor)
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", callback)

    function btn:SetLabel(text)  label:SetText(text) end
    function btn:SetCallback(fn) btn:SetScript("OnClick", fn) end
    function btn:SetEnabled(enabled)
        if enabled then btn:Enable(); btn:SetAlpha(1)
        else btn:Disable(); btn:SetAlpha(0.4) end
    end

    return btn
end
