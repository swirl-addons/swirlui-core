local _, SUI = ...

local C = SUI.Components

function C.T() return SUI.Theme end

function C.ApplyFont(fs, size)
    local sz = size == "small" and SUI.FontSize
           or  size == "large" and (SUI.FontSize + 2)
           or  SUI.FontSize
    fs:SetFont(SUI.Font, sz, "OUTLINE")
    fs:SetShadowOffset(0, 0)
    fs:SetShadowColor(0, 0, 0, 0)
end

function C.SetBackdrop(frame, bg, border)
    local theme = C.T()
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.borderSize,
    })
    if bg     then frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4]) end
    if border then frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4]) end
end

function C.AnimateBorderColor(frame, animGroup, fromColor, toColor)
    animGroup:Stop()
    local cr, cg, cb = frame:GetBackdropBorderColor()
    fromColor.r, fromColor.g, fromColor.b = cr, cg, cb
    animGroup:Play()
end
