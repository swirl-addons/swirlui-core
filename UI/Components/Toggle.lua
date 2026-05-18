local _, SUI = ...
local C = SUI.Components
local T, SetBackdrop = C.T, C.SetBackdrop

function C:CreateToggle(parent, labelText, initialState, onChange)
    local theme         = T()
    local TOGGLE_W      = theme.toggleWidth
    local TOGGLE_H      = 16
    local KNOB          = TOGGLE_H - 2
    local PAD           = 1
    local ANIM_DUR      = 0.18
    local OFF_X         = PAD
    local ON_X          = TOGGLE_W - KNOB - PAD

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(30)

    local lbl = C.CreateLabel(row, labelText)
    row.label = lbl

    local toggle = CreateFrame("Frame", nil, row, "BackdropTemplate")
    toggle:SetSize(TOGGLE_W, TOGGLE_H)
    toggle:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -14)
    SetBackdrop(toggle, theme.bg.med, theme.border.color)

    local knob = CreateFrame("Frame", nil, toggle, "BackdropTemplate")
    knob:SetSize(KNOB, KNOB)
    knob:SetPoint("LEFT", toggle, "LEFT", OFF_X, 0)
    knob:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets   = { left = -1, right = -1, top = 0, bottom = 0 },
    })
    knob:SetBackdropColor(0, 0, 0, 1)
    knob:SetBackdropBorderColor(0, 0, 0, 1)

    local knobTex = knob:CreateTexture(nil, "ARTWORK")
    knobTex:SetAllPoints()
    knobTex:SetColorTexture(theme.accent.r, theme.accent.g, theme.accent.b, 0.8)

    local function SetKnobBorderColor(r, g, b)
        knob:SetBackdropBorderColor(r, g, b, 1)
    end

    local slideGroup = knob:CreateAnimationGroup()
    local slideAnim  = slideGroup:CreateAnimation("Translation")
    slideAnim:SetDuration(ANIM_DUR)
    slideAnim:SetSmoothing("OUT")

    local colorGroup = toggle:CreateAnimationGroup()
    colorGroup:SetLooping("NONE")
    local colorAnim  = colorGroup:CreateAnimation("Animation")
    colorAnim:SetDuration(ANIM_DUR)
    local cFrom = {}
    local cTo   = {}
    local knobR, knobG, knobB, knobA = theme.accent.r, theme.accent.g, theme.accent.b, 0.6

    colorGroup:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        toggle:SetBackdropColor(
            cFrom.bgR + (cTo.bgR - cFrom.bgR) * p,
            cFrom.bgG + (cTo.bgG - cFrom.bgG) * p,
            cFrom.bgB + (cTo.bgB - cFrom.bgB) * p, 1)
        local kr = cFrom.kr + (cTo.kr - cFrom.kr) * p
        local kg = cFrom.kg + (cTo.kg - cFrom.kg) * p
        local kb = cFrom.kb + (cTo.kb - cFrom.kb) * p
        local ka = cFrom.ka + (cTo.ka - cFrom.ka) * p
        knobTex:SetColorTexture(kr, kg, kb, ka)
        knobR, knobG, knobB, knobA = kr, kg, kb, ka
    end)
    colorGroup:SetScript("OnFinished", function()
        toggle:SetBackdropColor(cTo.bgR, cTo.bgG, cTo.bgB, 1)
        knobTex:SetColorTexture(cTo.kr, cTo.kg, cTo.kb, cTo.ka)
        knobR, knobG, knobB, knobA = cTo.kr, cTo.kg, cTo.kb, cTo.ka
    end)

    local state     = initialState or false
    local animating = false

    local function UpdateColors(toState, instant)
        local ac  = T().accent
        local bgD = T().bg.med
        local bgA = CreateColor(ac.r * 0.5, ac.g * 0.5, ac.b * 0.5, 1)
        if instant then
            if toState then
                toggle:SetBackdropColor(bgA.r, bgA.g, bgA.b, 1)
                knobTex:SetColorTexture(ac.r, ac.g, ac.b, 0.8)
                knobR, knobG, knobB, knobA = ac.r, ac.g, ac.b, 0.8
            else
                toggle:SetBackdropColor(bgD.r, bgD.g, bgD.b, 1)
                knobTex:SetColorTexture(ac.r, ac.g, ac.b, 0.6)
                knobR, knobG, knobB, knobA = ac.r, ac.g, ac.b, 0.6
            end
            return
        end
        colorGroup:Stop()
        cFrom.bgR, cFrom.bgG, cFrom.bgB = toggle:GetBackdropColor()
        cFrom.kr, cFrom.kg, cFrom.kb, cFrom.ka = knobR, knobG, knobB, knobA
        cTo.bgR, cTo.bgG, cTo.bgB = toState and bgA.r or bgD.r, toState and bgA.g or bgD.g, toState and bgA.b or bgD.b
        cTo.kr, cTo.kg, cTo.kb = ac.r, ac.g, ac.b
        cTo.ka = toState and 0.8 or 0.6
        colorGroup:Play()
    end

    local function AnimateTo(toState, instant)
        if animating and not instant then return end
        animating = true
        state = toState
        local targetX  = toState and ON_X or OFF_X
        local currentX = select(4, knob:GetPoint()) or OFF_X
        local delta    = targetX - currentX
        UpdateColors(toState, instant)
        if instant or math.abs(delta) < 1 then
            knob:ClearAllPoints()
            knob:SetPoint("LEFT", toggle, "LEFT", targetX, 0)
            animating = false
        else
            slideGroup:Stop()
            knob:ClearAllPoints()
            knob:SetPoint("LEFT", toggle, "LEFT", currentX, 0)
            slideAnim:SetOffset(delta, 0)
            slideGroup:SetScript("OnFinished", function()
                knob:ClearAllPoints()
                knob:SetPoint("LEFT", toggle, "LEFT", targetX, 0)
                animating = false
            end)
            slideGroup:Play()
        end
    end

    AnimateTo(state, true)

    local clickBtn = CreateFrame("Button", nil, toggle)
    clickBtn:SetAllPoints()
    clickBtn:SetFrameLevel(toggle:GetFrameLevel() + 10)
    clickBtn:RegisterForClicks("LeftButtonUp")
    clickBtn:SetScript("OnClick", function()
        if slideGroup:IsPlaying() or colorGroup:IsPlaying() then return end
        local newState = not state
        AnimateTo(newState, false)
        if onChange then
            C_Timer.After(ANIM_DUR, function() onChange(newState) end)
        end
    end)

    local kbAG   = knob:CreateAnimationGroup()
    kbAG:SetLooping("NONE")
    local kbAnim = kbAG:CreateAnimation("Animation")
    kbAnim:SetDuration(0.15)
    local kbFrom = {}
    local kbTo   = {}
    local kbR, kbG, kbB = theme.border.color.r, theme.border.color.g, theme.border.color.b

    kbAG:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        local r = kbFrom.r + (kbTo.r - kbFrom.r) * p
        local g = kbFrom.g + (kbTo.g - kbFrom.g) * p
        local b = kbFrom.b + (kbTo.b - kbFrom.b) * p
        SetKnobBorderColor(r, g, b)
        kbR, kbG, kbB = r, g, b
    end)
    kbAG:SetScript("OnFinished", function()
        SetKnobBorderColor(kbTo.r, kbTo.g, kbTo.b)
        kbR, kbG, kbB = kbTo.r, kbTo.g, kbTo.b
    end)

    local function AnimateKnobBorder(toAccent)
        kbAG:Stop()
        kbFrom.r, kbFrom.g, kbFrom.b = kbR, kbG, kbB
        local c = toAccent and T().accent or T().border.color
        kbTo.r, kbTo.g, kbTo.b = c.r, c.g, c.b
        kbAG:Play()
    end

    clickBtn:SetScript("OnEnter", function()
        local ac = T().accent
        local a = state and 0.8 or 0.6
        knobTex:SetColorTexture(ac.r * 1.2, ac.g * 1.2, ac.b * 1.2, a)
        knobR, knobG, knobB, knobA = ac.r * 1.2, ac.g * 1.2, ac.b * 1.2, a
        AnimateKnobBorder(true)
    end)
    clickBtn:SetScript("OnLeave", function()
        local ac = T().accent
        local a = state and 0.8 or 0.4
        knobTex:SetColorTexture(ac.r, ac.g, ac.b, a)
        knobR, knobG, knobB, knobA = ac.r, ac.g, ac.b, a
        AnimateKnobBorder(false)
    end)

    function row:SetValue(value, instant)
        if value ~= state then AnimateTo(value, instant) end
    end
    function row:GetValue() return state end
    function row:SetEnabled(enabled)
        toggle:SetAlpha(enabled and 1 or 0.4)
        clickBtn:EnableMouse(enabled)
    end

    return row
end
