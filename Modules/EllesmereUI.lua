local _, SUI = ...

local MODULE = "EllesmereUIUnitFrames"
local UNITS = { "target", "focus", "boss1", "boss2", "boss3", "boss4", "boss5", "boss6", "boss7", "boss8" }

local hooked = false
local tweaked = {}

local function Enabled()
    local settings = SwirlUIDB and SwirlUIDB.uiSettings and SwirlUIDB.uiSettings.ellesmere
    return settings and settings.powerTextAboveCastbar
end

local function ModuleNS()
    return EllesmereUI and EllesmereUI._ModuleNS and EllesmereUI._ModuleNS[MODULE]
end

local function ApplyFrame(frame, enabled)
    local power = frame.Power
    local ovr = power and power._ppTextOvr
    if not ovr then return end

    if enabled then
        local cbg = frame.Castbar and frame.Castbar:GetParent()
        if not cbg then return end
        ovr:SetFrameStrata(cbg:GetFrameStrata())
        ovr:SetFrameLevel(cbg:GetFrameLevel() + 10)
    else
        local ns = ModuleNS()
        local settings = frame.Castbar and frame.Castbar._eufSettings
        if ns and ns.UpdatePowerBorder and settings then
            ns.UpdatePowerBorder(power, settings)
        else
            ovr:SetFrameStrata(frame:GetFrameStrata())
            ovr:SetFrameLevel(frame:GetFrameLevel() + 15)
        end
    end
end

local function Apply()
    local ns = ModuleNS()
    local frames = ns and ns.frames
    if not frames then return false end

    local enabled = Enabled()

    wipe(tweaked)
    for _, unit in ipairs(UNITS) do
        local frame = frames[unit]
        if frame then
            tweaked[frame] = true
            ApplyFrame(frame, enabled)
        end
    end

    if not hooked and ns.UpdatePowerBorder then
        hooked = true
        -- eui resets strata and level here, sooo reapply
        hooksecurefunc(ns, "UpdatePowerBorder", function(power)
            if not Enabled() then return end
            local frame = power:GetParent()
            if frame and tweaked[frame] then
                ApplyFrame(frame, true)
            end
        end)
    end

    return true
end

-- ns.frames isn't ready at login, so retry
local function ApplyWhenReady(attempt)
    attempt = attempt or 1
    if Apply() or attempt > 20 then return end
    C_Timer.After(0.25, function() ApplyWhenReady(attempt + 1) end)
end

function SUI.ApplyEllesmereSettings()
    ApplyWhenReady()
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function()
    ApplyWhenReady()
end)
