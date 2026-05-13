local _, SUI = ...

local C = SUI.Components

function C.T() return SUI.Theme end

function C.ApplyFont(fs, size)
    local font = C.T().font
    local sz = size == "small" and font.size.small
           or size == "large" and (font.size.normal + 2)
           or font.size.normal
    fs:SetFont(font.path, sz, "OUTLINE")
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
    if bg then frame:SetBackdropColor(bg.r, bg.g, bg.b, bg.a) end
    if border then frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a) end
end

function C.AnimateBorderColor(frame, animGroup, fromColor, toColor)
    animGroup:Stop()
    local cr, cg, cb = frame:GetBackdropBorderColor()
    fromColor.r, fromColor.g, fromColor.b = cr, cg, cb
    animGroup:Play()
end
