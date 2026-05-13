local _, SUI = ...
local C = SUI.Components
local T, SetBackdrop = C.T, C.SetBackdrop

function C:ApplyScrollbar(scrollFrame, scrollChild, parent)
    local theme = T()
    local sbW   = theme.scrollbarWidth

    local track = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    track:SetWidth(sbW)
    track:SetPoint("TOPRIGHT",    parent, "TOPRIGHT",    0, 0)
    track:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    SetBackdrop(track, CreateColor(0.08, 0.08, 0.08, 0.6), theme.border)

    local thumb = CreateFrame("Frame", nil, track, "BackdropTemplate")
    thumb:SetWidth(sbW - 2)
    SetBackdrop(thumb, CreateColor(theme.accent.r, theme.accent.g, theme.accent.b, 0.75), CreateColor(0, 0, 0, 0))
    thumb:SetPoint("RIGHT", track, "RIGHT", -1, 0)

    local thumbTop = thumb:CreateTexture(nil, "OVERLAY")
    thumbTop:SetHeight(1)
    thumbTop:SetColorTexture(0, 0, 0, 1)
    thumbTop:SetPoint("TOPLEFT",  thumb, "TOPLEFT",  0, 0)
    thumbTop:SetPoint("TOPRIGHT", thumb, "TOPRIGHT", 0, 0)

    local thumbBot = thumb:CreateTexture(nil, "OVERLAY")
    thumbBot:SetHeight(1)
    thumbBot:SetColorTexture(0, 0, 0, 1)
    thumbBot:SetPoint("BOTTOMLEFT",  thumb, "BOTTOMLEFT",  0, 0)
    thumbBot:SetPoint("BOTTOMRIGHT", thumb, "BOTTOMRIGHT", 0, 0)

    track:Hide()

    local function UpdateThumb()
        local frameH = scrollFrame:GetHeight()
        local childH = scrollChild:GetHeight()
        if frameH == 0 or childH <= frameH then track:Hide(); return end
        track:Show()
        local trackH    = track:GetHeight()
        local ratio     = frameH / childH
        local thumbH    = math.max(20, trackH * ratio)
        thumb:SetHeight(thumbH)
        local scroll    = scrollFrame:GetVerticalScroll()
        local maxScroll = childH - frameH
        local offset    = (scroll / maxScroll) * (trackH - thumbH)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP",   track, "TOP",   0, -offset)
        thumb:SetPoint("RIGHT", track, "RIGHT", -1, 0)
    end

    scrollFrame:HookScript("OnScrollRangeChanged", UpdateThumb)
    scrollFrame:HookScript("OnVerticalScroll",     UpdateThumb)
    scrollChild:HookScript("OnSizeChanged",        UpdateThumb)

    thumb:EnableMouse(true)
    local dragging = false
    local dragStartY, dragStartScroll

    thumb:SetScript("OnMouseDown", function(_, btn)
        if btn ~= "LeftButton" then return end
        dragging        = true
        dragStartY      = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        dragStartScroll = scrollFrame:GetVerticalScroll()
    end)

    local updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function()
        if not dragging then return end
        local curY      = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local delta     = dragStartY - curY
        local trackH    = track:GetHeight()
        local childH    = scrollChild:GetHeight()
        local frameH    = scrollFrame:GetHeight()
        local maxScroll = math.max(0, childH - frameH)
        local scrollDelta = delta * (maxScroll / (trackH - thumb:GetHeight()))
        scrollFrame:SetVerticalScroll(math.max(0, math.min(maxScroll, dragStartScroll + scrollDelta)))
        UpdateThumb()
    end)

    thumb:SetScript("OnMouseUp", function() dragging = false end)

    return track
end

function C:CreateTabScroller(tabFrame)
    local theme = T()
    local sbW   = theme.scrollbarWidth + 2

    local scrollFrame = CreateFrame("ScrollFrame", nil, tabFrame)
    scrollFrame:SetPoint("TOPLEFT",     tabFrame, "TOPLEFT",      1, -1)
    scrollFrame:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -1,  1)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        local cur  = sf:GetVerticalScroll()
        local maxS = sf:GetVerticalScrollRange()
        sf:SetVerticalScroll(delta > 0 and math.max(cur - 40, 0) or math.min(cur + 40, maxS))
    end)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    local scrollbarVisible = false

    local function UpdateScrollChildWidth()
        local w = scrollFrame:GetWidth()
        if w > 0 then
            scrollChild:SetWidth(scrollbarVisible and (w - sbW) or w)
        end
    end

    local function UpdateScrollBarVisibility()
        local contentH = scrollChild:GetHeight()
        local frameH   = scrollFrame:GetHeight()
        scrollbarVisible = contentH > frameH
        UpdateScrollChildWidth()
    end

    scrollFrame:HookScript("OnScrollRangeChanged", UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged",         UpdateScrollBarVisibility)
    scrollChild:HookScript("OnSizeChanged",         UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged",          UpdateScrollChildWidth)

    local track = C:ApplyScrollbar(scrollFrame, scrollChild, tabFrame)

    track:HookScript("OnShow", function() scrollbarVisible = true;  UpdateScrollChildWidth() end)
    track:HookScript("OnHide", function() scrollbarVisible = false; UpdateScrollChildWidth() end)

    function scrollChild:PlaceCard(card, yOffset)
        card:SetPoint("TOPLEFT", self, "TOPLEFT",  theme.padding.small, -yOffset)
        card:SetPoint("RIGHT",   self, "RIGHT",   -theme.padding.small,  0)
        return yOffset
    end

    function scrollChild:Commit(yOffset)
        C_Timer.After(0, function()
            self:SetHeight(yOffset + theme.padding.small)
            UpdateScrollBarVisibility()
        end)
    end

    scrollChild.scrollFrame = scrollFrame

    C_Timer.After(0, UpdateScrollChildWidth)

    return scrollChild
end
