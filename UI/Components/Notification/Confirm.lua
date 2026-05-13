local _, SUI = ...
local N = SUI.Components.Notification

local CONFIRM_W = 220
local CONFIRM_H = 72
local BTN_W = 70
local BTN_H = 20

local confirm = nil

local function BuildConfirm()
    confirm = N.BuildPanel("SUI_ConfirmPopup", CONFIRM_W, CONFIRM_H, "DIALOG")

    local msg = confirm:CreateFontString(nil, "OVERLAY")
    msg:SetPoint("TOPLEFT", confirm, "TOPLEFT", 14, -12)
    msg:SetPoint("TOPRIGHT", confirm, "TOPRIGHT", -10, -12)
    msg:SetJustifyH("LEFT")
    N.ApplyFont(msg, "small")
    confirm.msg = msg

    local okBtn = CreateFrame("Button", nil, confirm, "BackdropTemplate")
    local cancelBtn = CreateFrame("Button", nil, confirm, "BackdropTemplate")
    okBtn:SetSize(BTN_W, BTN_H)
    cancelBtn:SetSize(BTN_W, BTN_H)
    okBtn:SetPoint("BOTTOMRIGHT", confirm, "BOTTOM", -4, 10)
    cancelBtn:SetPoint("BOTTOMLEFT", confirm, "BOTTOM", 4, 10)

    local okLabel = okBtn:CreateFontString(nil, "OVERLAY")
    local cancelLabel = cancelBtn:CreateFontString(nil, "OVERLAY")
    okLabel:SetPoint("CENTER", okBtn, "CENTER")
    cancelLabel:SetPoint("CENTER", cancelBtn, "CENTER")
    N.ApplyFont(okLabel, "small")
    N.ApplyFont(cancelLabel, "small")
    okLabel:SetText("Confirm")
    cancelLabel:SetText("Cancel")
    confirm.okBtn = okBtn
    confirm.cancelBtn = cancelBtn
    confirm.okLabel = okLabel
    confirm.cancelLabel = cancelLabel

    okBtn:SetScript("OnEnter", function()
        local s = N.T().success
        okBtn:SetBackdropBorderColor(s.r, s.g, s.b, 1)
    end)
    okBtn:SetScript("OnLeave", function() okBtn:SetBackdropBorderColor(0, 0, 0, 1) end)
    cancelBtn:SetScript("OnEnter", function()
        local e = N.T().error
        cancelBtn:SetBackdropBorderColor(e.r, e.g, e.b, 1)
    end)
    cancelBtn:SetScript("OnLeave", function() cancelBtn:SetBackdropBorderColor(0, 0, 0, 1) end)
end

function SUI.Components.ShowConfirm(text, onConfirm, onCancel)
    if not confirm then BuildConfirm() end

    local theme = N.T()
    N.SetBackdrop(confirm, theme.bg.dark, theme.border)
    N.SetBackdrop(confirm.okBtn, theme.bg.medium, theme.border)
    N.SetBackdrop(confirm.cancelBtn, theme.bg.medium, theme.border)
    N.ApplyAccent(confirm)
    local s = theme.success
    confirm.okLabel:SetTextColor(s.r, s.g, s.b, 1)
    local e = theme.error
    confirm.cancelLabel:SetTextColor(e.r, e.g, e.b, 1)
    confirm.msg:SetText(text)

    confirm.okBtn:SetScript("OnClick", function()
        N.FadeOut(confirm, nil)
        if onConfirm then onConfirm() end
    end)
    confirm.cancelBtn:SetScript("OnClick", function()
        N.FadeOut(confirm, nil)
        if onCancel then onCancel() end
    end)

    N.FadeIn(confirm)
end
