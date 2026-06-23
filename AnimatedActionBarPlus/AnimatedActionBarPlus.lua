-----------------------------------------------------
-- Grrr
-- Mobitor forced me to do this..
-- Creds to @Geldis and @Mobitor
-----------------------------------------------------
local ADDON_NAME = "AnimatedActionBarPlus"
local EM         = EVENT_MANAGER
local WM         = WINDOW_MANAGER

local ULT_SLOT_INDEX  = 8
local QUICKSLOT_INDEX = 9

local ULT_FRAME_CHILDREN   = { "Frame", "FillAnimationLeft", "FillAnimationRight" }
local ULT_SHIMMER_CHILDREN = { "Glow", "Burst", "ReadyLoop" }

local thinFrameApplied = false

local sv

local EDGE_TEXTURES = {
    classic = "AnimatedActionBarPlus/CustomEdge.dds",
    v2      = "AnimatedActionBarPlus/CustomEdge2.dds",
    purple  = "AnimatedActionBarPlus/CustomEdgePurple.dds",
    red     = "AnimatedActionBarPlus/CustomEdgeRed.dds",
    blue    = "AnimatedActionBarPlus/CustomEdgeBlue.dds",
    aqua    = "AnimatedActionBarPlus/CustomEdgeAqua.dds",
    darkred    = "AnimatedActionBarPlus/CustomEdgeDarkRed.dds",
    darkpurple = "AnimatedActionBarPlus/CustomEdgeDarkPurple.dds",
}

local function GetEdgeTemplate()
    -- classic nutzt das standard-template, alle anderen die v2-struktur
    if sv and sv.edgeStyle and sv.edgeStyle ~= "classic" then
        return "ALT_ActionButton_V2"
    end
    return "ALT_ActionButton"
end

local function SetSlotEdge(slot)
    if not slot then return end
    local backdrop = slot:GetNamedChild("Backdrop")
    if backdrop and backdrop.SetEdgeTexture then
        local file = EDGE_TEXTURES[sv and sv.edgeStyle] or EDGE_TEXTURES.classic
        backdrop:SetEdgeTexture(file, 128, 16)
    end
end

local SuppressVanillaUltGlow

local function ApplyThinFrameTemplate()
    if thinFrameApplied then return end

    if ZO_ActionBar1 then
        ApplyTemplateToControl(ZO_ActionBar1, "ALT_ActionBar1")
    end

    SecurePostHook(ActionButton, "ApplyStyle", function(self)
        if self and self.slot then
            ApplyTemplateToControl(self.slot, GetEdgeTemplate())
            SetSlotEdge(self.slot)

            if self.slot.slotNum == ULT_SLOT_INDEX then
                -- Den dicken Vanilla-Ulti-Rahmen plus die Fill-Animationen plattmachen,
                -- sonst beißt sich das mit unserem dünnen Rahmen.
                for _, name in ipairs(ULT_FRAME_CHILDREN) do
                    local c = self.slot:GetNamedChild(name)
                    if c then
                        if c.SetTexture then c:SetTexture("") end
                        c:SetAlpha(0)
                        if c.SetHidden then c:SetHidden(true) end
                    end
                end
                -- Glow/Burst/ReadyLoop sind das originale Ulti-Schimmern von ESO.
                -- Nur ausblenden, wenn der Spieler es explizit abgeschaltet hat
                -- sonst macht Vanilla das Schimmern wie gewohnt.
                if sv and not sv.vanillaUltShimmer then
                    for _, name in ipairs(ULT_SHIMMER_CHILDREN) do
                        local c = self.slot:GetNamedChild(name)
                        if c then
                            if c.SetTexture then c:SetTexture("") end
                            c:SetAlpha(0)
                            if c.SetHidden then c:SetHidden(true) end
                        end
                    end
                end
            end
        end
    end)

    for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ULT_SLOT_INDEX do
        local btn = ZO_ActionBar_GetButton(slotNum)
        if btn and btn.slot then
            ApplyTemplateToControl(btn.slot, GetEdgeTemplate())
            SetSlotEdge(btn.slot)
        end
    end
    SuppressVanillaUltGlow()

    thinFrameApplied = true
end

SuppressVanillaUltGlow = function()
    local btn = ZO_ActionBar_GetButton(ULT_SLOT_INDEX)
    if not btn or not btn.slot then return end
    for _, name in ipairs(ULT_FRAME_CHILDREN) do
        local c = btn.slot:GetNamedChild(name)
        if c then
            if c.SetTexture then c:SetTexture("") end
            c:SetAlpha(0)
            if c.SetHidden then c:SetHidden(true) end
        end
    end
    -- Schimmern nur wegnehmen, wenn der Spieler es will
    if sv and not sv.vanillaUltShimmer then
        for _, name in ipairs(ULT_SHIMMER_CHILDREN) do
            local c = btn.slot:GetNamedChild(name)
            if c then
                if c.SetTexture then c:SetTexture("") end
                c:SetAlpha(0)
                if c.SetHidden then c:SetHidden(true) end
            end
        end
    end
end

-- Holt das Vanilla-Ulti-Schimmern zurück, falls es vorher unterdrückt wurde
local function RestoreVanillaUltShimmer()
    local btn = ZO_ActionBar_GetButton(ULT_SLOT_INDEX)
    if not btn or not btn.slot then return end
    for _, name in ipairs(ULT_SHIMMER_CHILDREN) do
        local c = btn.slot:GetNamedChild(name)
        if c and c.SetHidden then c:SetHidden(false) end
    end
    if btn.ApplyStyle then btn:ApplyStyle() end
end

local defaults = {

    bounceEnabled        = true,
    bounceOnProc         = true,
    animationStyle       = "bounce",  
    shrinkScale          = 0.9,
    growScale            = 1.1,
    frameResetTimeMS     = 167,

    glowEnabled          = true,
    glowColor            = { 1.0, 0.85, 0.2, 1.0 },
    glowDurationMS       = 600,
    glowPadding          = 12,
    glowIntensity        = 1.0,

    pulseEnabled         = true,
    pulseDurationMS      = 800,
    pulseMinAlpha        = 0.25,
    pulseMaxAlpha        = 1.0,

    ultBounceEnabled     = true,
    vanillaUltShimmer    = true,

    -- Press-Glow speziell für den Ulti-Slot (unabhängig vom normalen Glow)
    ultGlowEnabled       = true,
    ultGlowColor         = { 1.0, 0.55, 0.1, 1.0 },  -- warmes Orange, passt zum Ulti-Moment
    ultGlowDurationMS    = 900,                       -- bewusst länger als bei normalen Skills
    ultGlowPadding       = 16,                        -- größer
    ultGlowIntensity     = 1.2,

    ultReadyEnabled      = true,
    ultReadyColor        = { 1.0, 0.2, 0.0, 1.0 },
    ultReadyPulse        = true,
    ultReadyMode         = "smooth", -- "smooth" = sanfter Pulse, "blink" = hartes An/Aus
    ultReadyBlinkIntMS   = 250,      -- Blink-Intervall (An/Aus-Wechsel)
    ultReadyPadding      = 8,
    ultReadyPulseDurMS   = 900,   -- Pulsier-Dauer (niedrig = schnell)
    ultReadyMinAlpha     = 0.35,  -- Min-Alpha im Pulse
    ultReadyIntensity    = 1.0,   -- Helligkeits-Multiplikator Max (1.0-2.0)

    -- Sekundärfarbe für den Ulti-Rahmen im Blink-Modus
    ultColorCycleEnabled   = false,
    ultColorCycleSecondary = { 1.0, 0.85, 0.2, 1.0 },

    -- rainbow modus einstellungen
    ultRainbowSaturation   = 1.0,  -- 0.0-1.0: wie gesättigt die farben sind
    ultRainbowLightness    = 0.5,  -- 0.0-1.0: wie hell/dunkel die farben sind

    -- Den engine-seitigen Proc-Glow von ESO abschalten,
    -- analog zum vanillaUltShimmer beim Ulti.
    vanillaProcGlow      = true,

    thinFrameEnabled     = true,
    frameAlpha           = 1.0,
    edgeStyle            = "classic",  -- "classic" = CustomEdge.dds, "v2" = CustomEdge2.dds

    pulseMode            = "smooth",
    blinkIntervalMS      = 250,
    strobeIntervalMS     = 80,

    colorCycleEnabled    = false,
    colorCycleSecondary  = { 1.0, 0.1, 0.1, 1.0 },

    stopGlowOnPress      = true,
}

local function GetActionSlotControl(slotNum, hotbarCategory)
    return ZO_ActionBar_GetButton(slotNum, hotbarCategory)
end

local function GetFlipCard(btn)
    if not btn then return nil end
    return btn.FlipCard or (btn.slot and btn.slot:GetNamedChild("FlipCard"))
end

local function IsUltSlot(slotNum) return slotNum == ULT_SLOT_INDEX end

local HideUltBorder
local CheckUltimateReady
local PauseUltBorderPulse
local PlayQuickslotGlow

local function BounceEnabledFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultBounceEnabled end
    return sv.bounceEnabled
end

local function GlowEnabledFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultGlowEnabled end
    return sv.glowEnabled
end

local function GlowColorFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultGlowColor end
    return sv.glowColor
end

local function GlowDurationFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultGlowDurationMS end
    return sv.glowDurationMS
end

local function GlowPaddingFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultGlowPadding end
    return sv.glowPadding
end

local function GlowIntensityFor(slotNum)
    if IsUltSlot(slotNum) then return sv.ultGlowIntensity or 1.0 end
    return sv.glowIntensity or 1.0
end

-- bounce

local function InstallBounceHook()
    local timelines = setmetatable({}, { __mode = "k" })

    local function GetIcon(button)

        if not button or not button.slot then return nil end
        return button.icon or button.slot:GetNamedChild("Icon")
    end

    local function GetBackdrop(button)
        if not button or not button.slot then return nil end
        return button.slot:GetNamedChild("Backdrop")
    end

    -- Damit sauber von der Mitte aus skaliert/gedreht wird statt aus der Ecke
    local function SetCenterOrigin(c)
        if c and c.SetTransformNormalizedOriginPoint then
            c:SetTransformNormalizedOriginPoint(0.5, 0.5, 0)
        end
    end

    local function BuildBounce(flip, tl, button)
        SetCenterOrigin(flip)

        local s = tl:InsertAnimation(ANIMATION_SCALE, flip)
        s:SetScaleValues(1.0, sv.shrinkScale); s:SetDuration(60)
        s:SetEasingFunction(ZO_EaseOutQuadratic)

        local g = tl:InsertAnimation(ANIMATION_SCALE, flip, 60)
        g:SetScaleValues(sv.shrinkScale, sv.growScale); g:SetDuration(80)
        g:SetEasingFunction(ZO_EaseOutQuadratic)

        local r = tl:InsertAnimation(ANIMATION_SCALE, flip, 140)
        r:SetScaleValues(sv.growScale, 1.0); r:SetDuration(sv.frameResetTimeMS)
        r:SetEasingFunction(ZO_EaseInQuadratic)

        local backdrop = GetBackdrop(button)
        if backdrop then
            SetCenterOrigin(backdrop)

            local bs = tl:InsertAnimation(ANIMATION_SCALE, backdrop)
            bs:SetScaleValues(1.0, sv.shrinkScale); bs:SetDuration(60)
            bs:SetEasingFunction(ZO_EaseOutQuadratic)

            local bg = tl:InsertAnimation(ANIMATION_SCALE, backdrop, 60)
            bg:SetScaleValues(sv.shrinkScale, sv.growScale); bg:SetDuration(80)
            bg:SetEasingFunction(ZO_EaseOutQuadratic)

            local br = tl:InsertAnimation(ANIMATION_SCALE, backdrop, 140)
            br:SetScaleValues(sv.growScale, 1.0); br:SetDuration(sv.frameResetTimeMS)
            br:SetEasingFunction(ZO_EaseInQuadratic)
        end
    end

    local function BuildFlash(flip, tl, button)

        local target = GetIcon(button) or flip
        local dur = math.max(60, math.floor((sv.frameResetTimeMS or 167) * 0.4))
        local up = tl:InsertAnimation(ANIMATION_ALPHA, target)
        up:SetAlphaValues(1.0, 0.25); up:SetDuration(dur)
        up:SetEasingFunction(ZO_EaseOutQuadratic)
        local down = tl:InsertAnimation(ANIMATION_ALPHA, target, dur)
        down:SetAlphaValues(0.25, 1.0); down:SetDuration(dur)
        down:SetEasingFunction(ZO_EaseInQuadratic)
    end

    local function BuildShake(flip, tl, button)
        local step = 40
        local off  = math.floor(8 * ((sv.growScale or 1.1) - 1.0) * 10) + 4
        local a1 = tl:InsertAnimation(ANIMATION_TRANSLATE, flip)
        a1:SetTranslateOffsets(0, 0, -off, 0); a1:SetDuration(step)
        a1:SetEasingFunction(ZO_EaseOutQuadratic)
        local a2 = tl:InsertAnimation(ANIMATION_TRANSLATE, flip, step)
        a2:SetTranslateOffsets(-off, 0, off, 0); a2:SetDuration(step * 2)
        a2:SetEasingFunction(ZO_EaseInOutQuadratic)
        local a3 = tl:InsertAnimation(ANIMATION_TRANSLATE, flip, step * 3)
        a3:SetTranslateOffsets(off, 0, -off, 0); a3:SetDuration(step * 2)
        a3:SetEasingFunction(ZO_EaseInOutQuadratic)
        local a4 = tl:InsertAnimation(ANIMATION_TRANSLATE, flip, step * 5)
        a4:SetTranslateOffsets(-off, 0, 0, 0); a4:SetDuration(step)
        a4:SetEasingFunction(ZO_EaseInQuadratic)

        -- Rahmen wackeln
        local backdrop = GetBackdrop(button)
        if backdrop then
            local b1 = tl:InsertAnimation(ANIMATION_TRANSLATE, backdrop)
            b1:SetTranslateOffsets(0, 0, -off, 0); b1:SetDuration(step)
            b1:SetEasingFunction(ZO_EaseOutQuadratic)
            local b2 = tl:InsertAnimation(ANIMATION_TRANSLATE, backdrop, step)
            b2:SetTranslateOffsets(-off, 0, off, 0); b2:SetDuration(step * 2)
            b2:SetEasingFunction(ZO_EaseInOutQuadratic)
            local b3 = tl:InsertAnimation(ANIMATION_TRANSLATE, backdrop, step * 3)
            b3:SetTranslateOffsets(off, 0, -off, 0); b3:SetDuration(step * 2)
            b3:SetEasingFunction(ZO_EaseInOutQuadratic)
            local b4 = tl:InsertAnimation(ANIMATION_TRANSLATE, backdrop, step * 5)
            b4:SetTranslateOffsets(-off, 0, 0, 0); b4:SetDuration(step)
            b4:SetEasingFunction(ZO_EaseInQuadratic)
        end
    end

    local function BuildTilt(flip, tl, button)

        SetCenterOrigin(flip)
        local maxRad = 0.30 * ((sv.growScale or 1.1) - 0.9) / 0.2
        local totalMs = math.max(180, (sv.frameResetTimeMS or 167) + 100)
        local backdrop = GetBackdrop(button)
        SetCenterOrigin(backdrop)
        local custom = tl:InsertAnimation(ANIMATION_CUSTOM, flip)
        custom:SetDuration(totalMs)
        custom:SetEasingFunction(ZO_LinearEase)
        custom:SetUpdateFunction(function(_, progress)

            local angle = math.sin(progress * math.pi * 2) * maxRad
            if flip.SetTransformRotationZ then
                flip:SetTransformRotationZ(angle)
            end
            -- Rahmen drehen
            if backdrop and backdrop.SetTransformRotationZ then
                backdrop:SetTransformRotationZ(angle)
            end
        end)
    end

    local STYLE_BUILDERS = {
        bounce = BuildBounce,
        flash  = BuildFlash,
        shake  = BuildShake,
        tilt   = BuildTilt,
    }

    local function BuildTimeline(button)
        local flip = GetFlipCard(button)
        if not flip then return nil end
        local style = sv.animationStyle or "bounce"
        local builder = STYLE_BUILDERS[style] or BuildBounce
        local tl = ANIMATION_MANAGER:CreateTimeline()
        builder(flip, tl, button)
        return tl, style
    end

    local function GetOrBuildTimeline(button)
        local entry = timelines[button]
        local curStyle = sv.animationStyle or "bounce"
        if entry and entry.style == curStyle then return entry.tl end

        if entry and entry.tl then entry.tl:Stop() end
        local tl, style = BuildTimeline(button)
        if not tl then return nil end
        timelines[button] = { tl = tl, style = style }
        return tl
    end

    ActionButton.PlayAbilityUsedBounce = function(self)
        local slotNum = self and self.slot and self.slot.slotNum
        if not BounceEnabledFor(slotNum) then return end
        local tl = GetOrBuildTimeline(self)
        if not tl then return end
        tl:PlayFromStart()
    end

    ActionButton.SetBounceAnimationParameters = function(self) end
end

-- glow

local glowControls    = {}
local pulseTimelines  = {}
local activeProcs     = {}
local fadeTimelines   = {}

local function GetOrCreateGlow(slotNum)
    local existing = glowControls[slotNum]
    if existing then

        local btn = GetActionSlotControl(slotNum)
        local flip = GetFlipCard(btn)
        if flip and existing:GetParent() ~= flip then
            existing:SetParent(flip)
        end
        return existing
    end

    local btn = GetActionSlotControl(slotNum)
    if not btn or not btn.slot then return nil end

    local flip = GetFlipCard(btn)
    if not flip then return nil end

    local glow = WM:CreateControlFromVirtual(
        "AABPlus_Glow_" .. slotNum, flip, "AABPlus_GlowTemplate"
    )
    glowControls[slotNum] = glow
    return glow
end

local function AnchorGlow(glow, flipCard, padding)
    if not glow or not flipCard then return end
    glow:ClearAnchors()
    glow:SetAnchor(TOPLEFT,     flipCard, TOPLEFT,     -padding, -padding)
    glow:SetAnchor(BOTTOMRIGHT, flipCard, BOTTOMRIGHT,  padding,  padding)
end

local function ApplyGlowColor(glow, color)
    glow:SetColor(color[1], color[2], color[3], color[4] or 1)
end

local function PlayGlow(slotNum)
    if not GlowEnabledFor(slotNum) then return end
    local btn = GetActionSlotControl(slotNum)
    if not btn or not btn.slot then return end

    local flipCard = GetFlipCard(btn)
    local glow     = GetOrCreateGlow(slotNum)
    if not glow or not flipCard then return end

    local color    = GlowColorFor(slotNum)
    local duration = GlowDurationFor(slotNum)
    local intensity = GlowIntensityFor(slotNum)
    local maxA      = math.min(1.0, (color[4] or 1) * intensity)

    AnchorGlow(glow, flipCard, GlowPaddingFor(slotNum))
    glow:SetColor(color[1], color[2], color[3], maxA)
    glow:SetAlpha(maxA)

    local fade = fadeTimelines[slotNum]
    if not fade then
        fade = ANIMATION_MANAGER:CreateTimeline()
        fade:InsertAnimation(ANIMATION_ALPHA, glow)
        fadeTimelines[slotNum] = fade
    end
    local a = fade:GetAnimation(1)
    a:SetAnimatedControl(glow)
    a:SetAlphaValues(maxA, 0)
    a:SetDuration(duration)
    a:SetEasingFunction(ZO_EaseInQuadratic)
    fade:PlayFromStart()
end

-- quickslot

local quickslotGlow         = nil
local quickslotFadeTimeline = nil

PlayQuickslotGlow = function()
    if not sv.glowEnabled then return end

    local qsButton = _G["QuickslotButton"]
    local qsFlip   = _G["QuickslotButtonFlipCard"] or qsButton
    if not qsButton or not qsFlip then return end

    if not quickslotGlow then
        quickslotGlow = WM:CreateControlFromVirtual(
            "AABPlus_QuickslotGlow", qsFlip, "AABPlus_GlowTemplate"
        )
    elseif quickslotGlow:GetParent() ~= qsFlip then
        quickslotGlow:SetParent(qsFlip)
    end

    local color    = sv.glowColor
    local duration = sv.glowDurationMS
    local intensity = sv.glowIntensity or 1.0
    local maxA      = math.min(1.0, (color[4] or 1) * intensity)

    AnchorGlow(quickslotGlow, qsFlip, sv.glowPadding)
    quickslotGlow:SetColor(color[1], color[2], color[3], maxA)
    quickslotGlow:SetAlpha(maxA)

    if not quickslotFadeTimeline then
        quickslotFadeTimeline = ANIMATION_MANAGER:CreateTimeline()
        quickslotFadeTimeline:InsertAnimation(ANIMATION_ALPHA, quickslotGlow)
    end
    local a = quickslotFadeTimeline:GetAnimation(1)
    a:SetAnimatedControl(quickslotGlow)
    a:SetAlphaValues(maxA, 0)
    a:SetDuration(duration)
    a:SetEasingFunction(ZO_EaseInQuadratic)
    quickslotFadeTimeline:PlayFromStart()
end

local function StartPulse(slotNum)
    if not GlowEnabledFor(slotNum) or not sv.pulseEnabled then return end
    if activeProcs[slotNum] then return end
    activeProcs[slotNum] = true

    local btn = GetActionSlotControl(slotNum)
    if not btn or not btn.slot then return end
    local flipCard = GetFlipCard(btn)
    local glow     = GetOrCreateGlow(slotNum)
    if not glow or not flipCard then return end

    local color = GlowColorFor(slotNum)
    local intensity = sv.glowIntensity or 1.0
    local maxA = math.min(1.0, (sv.pulseMaxAlpha or 1.0) * intensity)
    AnchorGlow(glow, flipCard, GlowPaddingFor(slotNum))
    glow:SetColor(color[1], color[2], color[3], maxA)

    local mode = sv.pulseMode or "smooth"

    if mode == "smooth" then
        local tl = ANIMATION_MANAGER:CreateTimeline()
        local a  = tl:InsertAnimation(ANIMATION_ALPHA, glow)
        a:SetAlphaValues(maxA, sv.pulseMinAlpha)
        a:SetDuration(sv.pulseDurationMS)
        a:SetEasingFunction(ZO_EaseOutQuadratic)
        tl:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
        tl:PlayFromStart()
        pulseTimelines[slotNum] = tl
    else
        local interval  = (mode == "strobe") and sv.strobeIntervalMS or sv.blinkIntervalMS
        local updateId  = "AABPlusPulse_" .. slotNum
        local state     = false
        local c1        = color
        local c2        = sv.colorCycleSecondary
        local cycleColor = sv.colorCycleEnabled

        EM:RegisterForUpdate(updateId, interval, function()
            state = not state
            if state then
                glow:SetAlpha(maxA)
                if cycleColor then
                    glow:SetColor(c2[1], c2[2], c2[3], math.min(1.0, (c2[4] or 1) * intensity))
                else
                    glow:SetColor(c1[1], c1[2], c1[3], math.min(1.0, (c1[4] or 1) * intensity))
                end
            else
                if cycleColor then
                    glow:SetAlpha(maxA)
                    glow:SetColor(c1[1], c1[2], c1[3], math.min(1.0, (c1[4] or 1) * intensity))
                else
                    glow:SetAlpha(sv.pulseMinAlpha)
                end
            end
        end)
        pulseTimelines[slotNum] = { updateId = updateId }
    end
end

local function StopPulse(slotNum)
    local entry = pulseTimelines[slotNum]
    if entry then
        if entry.Stop then
            entry:Stop()
        elseif entry.updateId then
            EM:UnregisterForUpdate(entry.updateId)
        end
        pulseTimelines[slotNum] = nil
    end
    activeProcs[slotNum] = nil
    local glow = glowControls[slotNum]
    if glow then glow:SetAlpha(0) end
end

local function StopAllPulses()
    local active = {}
    for s in pairs(activeProcs) do active[#active+1] = s end
    for _, s in ipairs(active) do StopPulse(s) end
    for _, glow in pairs(glowControls) do
        if glow then glow:SetAlpha(0) end
    end
end

local function IsSlotProcd(slotNum)
    return HasActivationHighlight(slotNum)
end


local suppressedProcGlows = {}

local function ApplyProcGlowSuppression(slotNum)
    local btn = GetActionSlotControl(slotNum)
    if not btn or not btn.slot then return end
    local engineGlow = btn.activationHighlight or btn.slot:GetNamedChild("Glow")
    if not engineGlow then return end

    if sv.vanillaProcGlow then
        -- Vollständig wiederherstellen geht ohne Reload nicht, weil die
        -- Originaltextur weg ist. State trotzdem freigeben.
        suppressedProcGlows[slotNum] = nil
    else
        if engineGlow.SetTexture then engineGlow:SetTexture("") end
        engineGlow:SetAlpha(0)
        if engineGlow.SetHidden then engineGlow:SetHidden(true) end
        suppressedProcGlows[slotNum] = true
    end
end

local function RefreshProcGlowSuppression()
    for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX do
        ApplyProcGlowSuppression(slotNum)
    end
end

local function RefreshAllProcs()
    RefreshProcGlowSuppression()
    if not sv.pulseEnabled then return end
    for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX do
        if IsSlotProcd(slotNum) then
            StartPulse(slotNum)
            if BounceEnabledFor(slotNum) and sv.bounceOnProc then
                local btn = GetActionSlotControl(slotNum)
                if btn and btn.PlayAbilityUsedBounce then btn:PlayAbilityUsedBounce() end
            end
        else
            StopPulse(slotNum)
        end
    end
end

local function OnAbilitySlotted(_, slotNum)
    if not slotNum then return end
    local btn = GetActionSlotControl(slotNum)
    if btn and btn.PlayAbilityUsedBounce and BounceEnabledFor(slotNum) then
        btn:PlayAbilityUsedBounce()
    end

    if IsUltSlot(slotNum) then
        PauseUltBorderPulse(600)
        zo_callLater(CheckUltimateReady, 150)
    end

    if sv.stopGlowOnPress and activeProcs[slotNum] then
        StopPulse(slotNum)
        return
    end

    PlayGlow(slotNum)
end

local function OnActivationHighlightChanged(_, slotNum, isShown)
    if not slotNum then return end

    -- Engine-Glow sofort unterdrücken bzw. wiederherstellen, sobald sich der
    -- Proc-Status ändert – nicht erst beim nächsten Bar-Wechsel.
    ApplyProcGlowSuppression(slotNum)

    -- Auf das von ESO gemeldete Flag NICHT blind vertrauen
    local procd = isShown
    if procd == nil then procd = IsSlotProcd(slotNum) end

    if procd then
        StartPulse(slotNum)
        if BounceEnabledFor(slotNum) and sv.bounceOnProc then
            local btn = GetActionSlotControl(slotNum)
            if btn and btn.PlayAbilityUsedBounce then btn:PlayAbilityUsedBounce() end
        end
    else
        StopPulse(slotNum)
    end
end

-- Direktes Slot-Update: update sobald ein Proc aktiv/inaktiv wird,
-- ohne dass ein Bar-Wechsel nötig ist.
local function OnSingleSlotUpdated(_, slotNum)
    if not slotNum then return end
    if slotNum < ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1 or slotNum > ACTION_BAR_ULTIMATE_SLOT_INDEX then
        return
    end
    ApplyProcGlowSuppression(slotNum)
    if not sv.pulseEnabled then return end
    if IsSlotProcd(slotNum) then
        if not activeProcs[slotNum] then
            StartPulse(slotNum)
            if BounceEnabledFor(slotNum) and sv.bounceOnProc then
                local btn = GetActionSlotControl(slotNum)
                if btn and btn.PlayAbilityUsedBounce then btn:PlayAbilityUsedBounce() end
            end
        end
    else
        StopPulse(slotNum)
    end
end

-- Der zuverlässigste Punkt um auf Proc-Änderungen zu reagieren ist die
local activationHighlightHookInstalled = false
local function InstallActivationHighlightHook()
    if activationHighlightHookInstalled then return end
    if not ActionButton or not ActionButton.UpdateActivationHighlight then return end
    activationHighlightHookInstalled = true

    SecurePostHook(ActionButton, "UpdateActivationHighlight", function(self)
        if not self or not self.slot then return end
        local slotNum = self.slot.slotNum
        if not slotNum then return end
        if slotNum < ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1 or slotNum > ACTION_BAR_ULTIMATE_SLOT_INDEX then return end
        if slotNum == ULT_SLOT_INDEX then return end -- Ulti hat eigene Logik

        -- 1) Vanilla-Glow killen, direkt nachdem ESO ihn gesetzt hat.
        if not sv.vanillaProcGlow then
            local glow = self.activationHighlight or self.slot:GetNamedChild("Glow")
            if glow then
                if glow.SetTexture then glow:SetTexture("") end
                glow:SetAlpha(0)
                if glow.SetHidden then glow:SetHidden(true) end
            end
        end

        -- 2) Proc-Pulse im selben Frame triggern. Kein Event-Roundtrip,
        --    kein Bar-Wechsel nötig.
        if sv.pulseEnabled then
            local procd = HasActivationHighlight(slotNum)
            if procd then
                if not activeProcs[slotNum] then
                    StartPulse(slotNum)
                    if BounceEnabledFor(slotNum) and sv.bounceOnProc and self.PlayAbilityUsedBounce then
                        self:PlayAbilityUsedBounce()
                    end
                end
            else
                if activeProcs[slotNum] then
                    StopPulse(slotNum)
                end
            end
        end
    end)
end

local function PlayQuickslotEffects()

    PlayQuickslotGlow()
end

local lastQuickslotCooldownRemain = 0

local function OnActionUpdateCooldowns()
    local remain = GetSlotCooldownInfo(QUICKSLOT_INDEX, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or 0
    if remain > 0 and lastQuickslotCooldownRemain == 0 then
        PlayQuickslotEffects()
    end
    lastQuickslotCooldownRemain = remain
end

local function InstallQuickslotHook()

end

-- ultimate

local ultBorderGlow     = nil
local ultBorderTimeline = nil
local ultBorderBlinkId  = nil
local ultBorderRainbowId = nil
local ultIsReady        = false

-- wandelt hsl in rgb um, brauchts für den rainbow modus
local function HSLToRGB(h, s, l)
    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1/6 then return p + (q - p) * 6 * t end
            if t < 1/2 then return q end
            if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
            return p
        end
        local q = l < 0.5 and (l * (1 + s)) or (l + s - l * s)
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end
    return r, g, b
end

local function CreateUltBorder()
    if ultBorderGlow then return ultBorderGlow end
    local btn = ZO_ActionBar_GetButton(ULT_SLOT_INDEX)
    if not btn or not btn.slot then return nil end
    local flip = GetFlipCard(btn) or btn.slot

    ultBorderGlow = WM:CreateControlFromVirtual(
        "AABPlus_UltReady", flip, "AABPlus_GlowTemplate"
    )
    return ultBorderGlow
end

HideUltBorder = function()
    ultIsReady = false
    if ultBorderTimeline then
        ultBorderTimeline:Stop()
        ultBorderTimeline = nil
    end
    if ultBorderBlinkId then
        EM:UnregisterForUpdate(ultBorderBlinkId)
        ultBorderBlinkId = nil
    end
    if ultBorderRainbowId then
        EM:UnregisterForUpdate(ultBorderRainbowId)
        ultBorderRainbowId = nil
    end
    if ultBorderGlow then ultBorderGlow:SetAlpha(0) end
end

local function ShowUltBorder()
    if not sv.ultReadyEnabled then return end
    local glow = CreateUltBorder()
    if not glow then return end

    local btn = ZO_ActionBar_GetButton(ULT_SLOT_INDEX)
    if not btn or not btn.slot then return end

    local flip = GetFlipCard(btn) or btn.slot

    if glow:GetParent() ~= flip then
        glow:SetParent(flip)
    end

    local padding = sv.ultReadyPadding
    if (sv.ultReadyMode or "smooth") == "smooth-rainbow" then
        padding = padding + 2  -- rainbow braucht bissl mehr platz
    end
    AnchorGlow(glow, flip, padding)

    local c         = sv.ultReadyColor
    local intensity = sv.ultReadyIntensity or 1.0
    local maxA      = math.min(1.0, (c[4] or 1) * intensity)
    glow:SetColor(c[1], c[2], c[3], maxA)
    glow:SetAlpha(maxA)

    if ultBorderTimeline then ultBorderTimeline:Stop(); ultBorderTimeline = nil end
    if ultBorderBlinkId then EM:UnregisterForUpdate(ultBorderBlinkId); ultBorderBlinkId = nil end
    if ultBorderRainbowId then EM:UnregisterForUpdate(ultBorderRainbowId); ultBorderRainbowId = nil end

    if sv.ultReadyPulse then
        local minA = sv.ultReadyMinAlpha or 0.35
        local mode = sv.ultReadyMode or "smooth"

        if mode == "blink" then
            -- Hartes An/Aus statt sanftem Fade.
            local interval = sv.ultReadyBlinkIntMS or 250
            local id       = "AABPlusUltBlink"
            local state    = true
            local c2       = sv.ultColorCycleSecondary
            local cycleColor = sv.ultColorCycleEnabled
            glow:SetColor(c[1], c[2], c[3], maxA)
            glow:SetAlpha(maxA)
            EM:RegisterForUpdate(id, interval, function()
                state = not state
                if cycleColor then
                    -- Statt An/Aus zwischen Primär- und Sekundärfarbe wechseln (beide voll sichtbar).
                    glow:SetAlpha(maxA)
                    if state then
                        glow:SetColor(c[1], c[2], c[3], maxA)
                    else
                        local a2 = math.min(1.0, (c2[4] or 1) * intensity)
                        glow:SetColor(c2[1], c2[2], c2[3], a2)
                    end
                else
                    glow:SetColor(c[1], c[2], c[3], maxA)
                    glow:SetAlpha(state and maxA or minA)
                end
            end)
            ultBorderBlinkId = id
        elseif mode == "smooth-rainbow" then
            -- sanfter farbverlauf der automatisch durch den regenbogen wandert
            local id = "AABPlusUltRainbow"
            local hue = 0
            local saturation = sv.ultRainbowSaturation or 1.0
            local lightness = sv.ultRainbowLightness or 0.5
            glow:SetAlpha(maxA)
            EM:RegisterForUpdate(id, 5, function()
                hue = (hue + 0.002) % 1.0
                local r, g, b = HSLToRGB(hue, saturation, lightness)
                glow:SetColor(r, g, b, maxA)
            end)
            ultBorderRainbowId = id
        else
            local dur  = sv.ultReadyPulseDurMS or 900
            local tl = ANIMATION_MANAGER:CreateTimeline()
            local a  = tl:InsertAnimation(ANIMATION_ALPHA, glow)
            a:SetAlphaValues(maxA, minA)
            a:SetDuration(dur)
            a:SetEasingFunction(ZO_EaseOutQuadratic)
            tl:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, LOOP_INDEFINITELY)
            tl:PlayFromStart()
            ultBorderTimeline = tl
        end
    end
end

PauseUltBorderPulse = function(durationMS)
    if not ultBorderGlow or not ultIsReady then return end

    if ultBorderTimeline then
        ultBorderTimeline:Stop()
        ultBorderTimeline = nil
    end
    if ultBorderBlinkId then
        EM:UnregisterForUpdate(ultBorderBlinkId)
        ultBorderBlinkId = nil
    end
    if ultBorderRainbowId then
        EM:UnregisterForUpdate(ultBorderRainbowId)
        ultBorderRainbowId = nil
    end

    local c         = sv.ultReadyColor
    local intensity = sv.ultReadyIntensity or 1.0
    local maxA      = math.min(1.0, (c[4] or 1) * intensity)
    ultBorderGlow:SetColor(c[1], c[2], c[3], maxA)
    ultBorderGlow:SetAlpha(maxA)

    zo_callLater(function()

        if ultIsReady and sv.ultReadyEnabled and sv.ultReadyPulse then
            ShowUltBorder()
        end
    end, durationMS or 600)
end

CheckUltimateReady = function()
    if not sv.ultReadyEnabled then HideUltBorder(); return end

    local ultAbilityId = GetSlotBoundId(ULT_SLOT_INDEX)
    if not ultAbilityId or ultAbilityId == 0 then
        HideUltBorder()
        return
    end

    local currentUlt = GetUnitPower("player", POWERTYPE_ULTIMATE)
    local cost = GetSlotAbilityCost(ULT_SLOT_INDEX) or 0

    local ready = currentUlt >= cost and cost > 0

    if ready and not ultIsReady then
        ultIsReady = true
        ShowUltBorder()
    elseif not ready and ultIsReady then
        HideUltBorder()
    end
end

local function OnPowerUpdate(_, unitTag, powerIndex, powerType)
    if unitTag ~= "player" or powerType ~= POWERTYPE_ULTIMATE then return end
    SuppressVanillaUltGlow()
    CheckUltimateReady()
end

local function OnSlotsUpdated()
    HideUltBorder()
    CheckUltimateReady()
    SuppressVanillaUltGlow()

    StopAllPulses()
    zo_callLater(function() RefreshAllProcs() end, 50)
end

local function ApplyEdgeTexture()
    local template = GetEdgeTemplate()
    local cats = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }
    for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ULT_SLOT_INDEX do
        for _, cat in ipairs(cats) do
            local btn = ZO_ActionBar_GetButton(slotNum, cat)
            if btn and btn.slot then
                ApplyTemplateToControl(btn.slot, template)
                SetSlotEdge(btn.slot)
                if btn.ApplyStyle then btn:ApplyStyle() end
            end
        end
    end
end

local function ApplyFrameAlpha()
    local alpha = sv.frameAlpha or 1.0
    for slotNum = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ULT_SLOT_INDEX do
        local btn = ZO_ActionBar_GetButton(slotNum)
        if btn and btn.slot then
            local backdrop = btn.slot:GetNamedChild("Backdrop")
            if backdrop then backdrop:SetAlpha(alpha) end
        end
    end
end

-- events

local function RegisterEvents()
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_ABILITY_USED, OnAbilitySlotted)

    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_EFFECT_UPDATE, OnActivationHighlightChanged)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOT_UPDATED,        OnSingleSlotUpdated)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ABILITY_LIST_CHANGED,      RefreshAllProcs)
    EM:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED,          RefreshAllProcs)

    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_UPDATE_COOLDOWNS,   OnActionUpdateCooldowns)

    EM:RegisterForEvent(ADDON_NAME, EVENT_POWER_UPDATE,              OnPowerUpdate)
    EM:AddFilterForEvent(ADDON_NAME, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG,    "player",
        REGISTER_FILTER_POWER_TYPE,  POWERTYPE_ULTIMATE)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOTS_FULL_UPDATE,  OnSlotsUpdated)
    EM:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_HOTBAR_UPDATED,     OnSlotsUpdated)
end

local C_TITLE   = "|cFFB347"
local C_BOUNCE  = "|c66CCFF"
local C_GLOW    = "|cFFD700"
local C_PULSE   = "|cFF6688"
local C_ULT     = "|cFF4422"
local C_FRAME   = "|c88CC88"
local C_DONATE  = "|cFFD700"
local C_RESET   = "|r"

-- empfänger + betreff für die spenden-mail
local DONATE_RECIPIENT = "@haze068"
local DONATE_SUBJECT   = "AnimatedActionBar+ Addon Donation"

-- macht das mail-fenster auf und packt empfänger + betreff direkt rein
local function OpenDonationMail()
    -- notnagel falls ComposeMail mal nicht da ist: felder von hand setzen
    local function FillFields()
        if ZO_MailSendToField then ZO_MailSendToField:SetText(DONATE_RECIPIENT) end
        if ZO_MailSendSubjectField then ZO_MailSendSubjectField:SetText(DONATE_SUBJECT) end
    end

    -- ComposeMail ist das was eso selbst beim "an spieler senden" nutzt,
    -- öffnet das sende-fenster und füllt empfänger + betreff sauber. body bleibt leer
    if ComposeMail then
        ComposeMail(DONATE_RECIPIENT, DONATE_SUBJECT, "")
    else
        -- uralt-clients ohne ComposeMail: szene aufmachen und felder selbst setzen
        if SCENE_MANAGER then
            if IsInGamepadPreferredMode() then
                SCENE_MANAGER:Show("mailManagerGamepad")
                if MAIL_MANAGER_GAMEPAD and MAIL_MANAGER_GAMEPAD.ShowSend then
                    MAIL_MANAGER_GAMEPAD:ShowSend()
                end
            else
                SCENE_MANAGER:Show("mailSend")
            end
        end
        -- eso leert die felder beim öffnen, also zweimal kurz danach nachsetzen
        zo_callLater(FillFields, 50)
        zo_callLater(FillFields, 200)
    end
end

local function BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", {
        type                = "panel",
        name                = "AnimatedActionBarPlus",
        displayName         = C_TITLE .. "Animated" .. C_RESET .. "ActionBar" .. C_TITLE .. "+" .. C_RESET,
        author              = "haze068",
        version             = "1.0.0",
        slashCommand        = "/aabplus",
        registerForRefresh  = true,
        registerForDefaults = true,
    })

    local function RestartActivePulses()
        local active = {}
        for s in pairs(activeProcs) do active[#active+1] = s end
        for _, s in ipairs(active) do StopPulse(s); StartPulse(s) end
    end

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", {

        { type = "description", text = GetString(SI_AAB_PANEL_DESCRIPTION) },

        {
            type     = "submenu",
            name     = C_BOUNCE .. GetString(SI_AAB_SUB_BOUNCE) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_BOUNCE_TT),
            controls = {
                {
                    type    = "dropdown",
                    name    = GetString(SI_AAB_ANIM_STYLE),
                    tooltip = GetString(SI_AAB_ANIM_STYLE_TT),
                    choices       = {
                        GetString(SI_AAB_ANIM_BOUNCE),
                        GetString(SI_AAB_ANIM_FLASH),
                        GetString(SI_AAB_ANIM_SHAKE),
                        GetString(SI_AAB_ANIM_TILT),
                    },
                    choicesValues = { "bounce", "flash", "shake", "tilt" },
                    getFunc = function() return sv.animationStyle end,
                    setFunc = function(v) sv.animationStyle = v end,
                    default = defaults.animationStyle,
                    disabled = function() return not sv.bounceEnabled end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_BOUNCE_ENABLE),
                    tooltip = GetString(SI_AAB_BOUNCE_ENABLE_TT),
                    getFunc = function() return sv.bounceEnabled end,
                    setFunc = function(v) sv.bounceEnabled = v end,
                    default = defaults.bounceEnabled,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_BOUNCE_ON_PROC),
                    tooltip = GetString(SI_AAB_BOUNCE_ON_PROC_TT),
                    getFunc = function() return sv.bounceOnProc end,
                    setFunc = function(v) sv.bounceOnProc = v end,
                    default = defaults.bounceOnProc,
                    disabled = function() return not sv.bounceEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_BOUNCE_GROW),
                    tooltip = GetString(SI_AAB_BOUNCE_GROW_TT),
                    min = 1.0, max = 1.5, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.growScale end,
                    setFunc = function(v) sv.growScale = v end,
                    default = defaults.growScale,
                    disabled = function() return not sv.bounceEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_BOUNCE_SHRINK),
                    tooltip = GetString(SI_AAB_BOUNCE_SHRINK_TT),
                    min = 0.5, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.shrinkScale end,
                    setFunc = function(v) sv.shrinkScale = v end,
                    default = defaults.shrinkScale,
                    disabled = function() return not sv.bounceEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_BOUNCE_RESET),
                    tooltip = GetString(SI_AAB_BOUNCE_RESET_TT),
                    min = 50, max = 500, step = 10,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.frameResetTimeMS end,
                    setFunc = function(v) sv.frameResetTimeMS = v end,
                    default = defaults.frameResetTimeMS,
                    disabled = function() return not sv.bounceEnabled end,
                },
            },
        },

        {
            type     = "submenu",
            name     = C_GLOW .. GetString(SI_AAB_SUB_GLOW) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_GLOW_TT),
            controls = {
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_GLOW_ENABLE),
                    tooltip = GetString(SI_AAB_GLOW_ENABLE_TT),
                    getFunc = function() return sv.glowEnabled end,
                    setFunc = function(v) sv.glowEnabled = v end,
                    default = defaults.glowEnabled,
                },
                {
                    type    = "colorpicker",
                    name    = GetString(SI_AAB_GLOW_COLOR),
                    tooltip = GetString(SI_AAB_GLOW_COLOR_TT),
                    getFunc = function() local c = sv.glowColor; return c[1], c[2], c[3], c[4] end,
                    setFunc = function(r, g, b, a) sv.glowColor = { r, g, b, a or 1 } end,
                    default = {
                        r = defaults.glowColor[1], g = defaults.glowColor[2],
                        b = defaults.glowColor[3], a = defaults.glowColor[4],
                    },
                    disabled = function() return not sv.glowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_GLOW_DURATION),
                    tooltip = GetString(SI_AAB_GLOW_DURATION_TT),
                    min = 100, max = 2000, step = 50,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.glowDurationMS end,
                    setFunc = function(v) sv.glowDurationMS = v end,
                    default = defaults.glowDurationMS,
                    disabled = function() return not sv.glowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_GLOW_PADDING),
                    tooltip = GetString(SI_AAB_GLOW_PADDING_TT),
                    min = 0, max = 24, step = 1,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.glowPadding end,
                    setFunc = function(v) sv.glowPadding = v end,
                    default = defaults.glowPadding,
                    disabled = function() return not sv.glowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_GLOW_INTENSITY),
                    tooltip = GetString(SI_AAB_GLOW_INTENSITY_TT),
                    min = 1.0, max = 2.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.glowIntensity end,
                    setFunc = function(v) sv.glowIntensity = v end,
                    default = defaults.glowIntensity,
                    disabled = function() return not sv.glowEnabled end,
                },
            },
        },

        {
            type     = "submenu",
            name     = C_PULSE .. GetString(SI_AAB_SUB_PULSE) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_PULSE_TT),
            controls = {
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_PULSE_ENABLE),
                    tooltip = GetString(SI_AAB_PULSE_ENABLE_TT),
                    getFunc = function() return sv.pulseEnabled end,
                    setFunc = function(v)
                        sv.pulseEnabled = v
                        if not v then
                            for s in pairs(activeProcs) do StopPulse(s) end
                        end
                    end,
                    default = defaults.pulseEnabled,
                    disabled = function() return not sv.glowEnabled end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_PROC_VANILLA_GLOW),
                    tooltip = GetString(SI_AAB_PROC_VANILLA_GLOW_TT),
                    getFunc = function() return sv.vanillaProcGlow end,
                    setFunc = function(v)
                        sv.vanillaProcGlow = v
                        RefreshProcGlowSuppression()
                    end,
                    default = defaults.vanillaProcGlow,
                    warning = GetString(SI_AAB_RELOAD_NOTE),
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_PULSE_STOP_ON_PRESS),
                    tooltip = GetString(SI_AAB_PULSE_STOP_ON_PRESS_TT),
                    getFunc = function() return sv.stopGlowOnPress end,
                    setFunc = function(v) sv.stopGlowOnPress = v end,
                    default = defaults.stopGlowOnPress,
                    disabled = function() return not sv.pulseEnabled end,
                },
                {
                    type    = "dropdown",
                    name    = GetString(SI_AAB_PULSE_STYLE),
                    tooltip = GetString(SI_AAB_PULSE_STYLE_TT),
                    choices       = { GetString(SI_AAB_PULSE_STYLE_SMOOTH), GetString(SI_AAB_PULSE_STYLE_BLINK), GetString(SI_AAB_PULSE_STYLE_STROBE) },
                    choicesValues = { "smooth", "blink", "strobe" },
                    getFunc = function() return sv.pulseMode end,
                    setFunc = function(v) sv.pulseMode = v; RestartActivePulses() end,
                    default = defaults.pulseMode,
                    disabled = function() return not sv.pulseEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_PULSE_SMOOTH_DUR),
                    tooltip = GetString(SI_AAB_PULSE_SMOOTH_DUR_TT),
                    min = 200, max = 2000, step = 50,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.pulseDurationMS end,
                    setFunc = function(v) sv.pulseDurationMS = v end,
                    default = defaults.pulseDurationMS,
                    disabled = function() return not sv.pulseEnabled or sv.pulseMode ~= "smooth" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_PULSE_BLINK_INT),
                    tooltip = GetString(SI_AAB_PULSE_BLINK_INT_TT),
                    min = 80, max = 800, step = 10,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.blinkIntervalMS end,
                    setFunc = function(v) sv.blinkIntervalMS = v end,
                    default = defaults.blinkIntervalMS,
                    disabled = function() return not sv.pulseEnabled or sv.pulseMode ~= "blink" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_PULSE_STROBE_INT),
                    tooltip = GetString(SI_AAB_PULSE_STROBE_INT_TT),
                    min = 30, max = 200, step = 5,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.strobeIntervalMS end,
                    setFunc = function(v) sv.strobeIntervalMS = v end,
                    default = defaults.strobeIntervalMS,
                    disabled = function() return not sv.pulseEnabled or sv.pulseMode ~= "strobe" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_PULSE_MIN_ALPHA),
                    tooltip = GetString(SI_AAB_PULSE_MIN_ALPHA_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.pulseMinAlpha end,
                    setFunc = function(v) sv.pulseMinAlpha = v end,
                    default = defaults.pulseMinAlpha,
                    disabled = function() return not sv.pulseEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_PULSE_MAX_ALPHA),
                    tooltip = GetString(SI_AAB_PULSE_MAX_ALPHA_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.pulseMaxAlpha end,
                    setFunc = function(v) sv.pulseMaxAlpha = v end,
                    default = defaults.pulseMaxAlpha,
                    disabled = function() return not sv.pulseEnabled end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_PULSE_COLOR_CYCLE),
                    tooltip = GetString(SI_AAB_PULSE_COLOR_CYCLE_TT),
                    getFunc = function() return sv.colorCycleEnabled end,
                    setFunc = function(v) sv.colorCycleEnabled = v; RestartActivePulses() end,
                    default = defaults.colorCycleEnabled,
                    disabled = function() return not sv.pulseEnabled end,
                },
                {
                    type    = "colorpicker",
                    name    = GetString(SI_AAB_PULSE_COLOR_SECOND),
                    tooltip = GetString(SI_AAB_PULSE_COLOR_SECOND_TT),
                    getFunc = function() local c = sv.colorCycleSecondary; return c[1], c[2], c[3], c[4] end,
                    setFunc = function(r, g, b, a) sv.colorCycleSecondary = { r, g, b, a or 1 } end,
                    default = {
                        r = defaults.colorCycleSecondary[1], g = defaults.colorCycleSecondary[2],
                        b = defaults.colorCycleSecondary[3], a = defaults.colorCycleSecondary[4],
                    },
                    disabled = function() return not sv.pulseEnabled or not sv.colorCycleEnabled end,
                },
            },
        },

        {
            type     = "submenu",
            name     = C_ULT .. GetString(SI_AAB_SUB_ULT) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_ULT_TT),
            controls = {
                { type = "header", name = GetString(SI_AAB_ULT_HEADER_EFFECTS) },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_BOUNCE_ENABLE),
                    tooltip = GetString(SI_AAB_ULT_BOUNCE_ENABLE_TT),
                    getFunc = function() return sv.ultBounceEnabled end,
                    setFunc = function(v) sv.ultBounceEnabled = v end,
                    default = defaults.ultBounceEnabled,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_GLOW_ENABLE),
                    tooltip = GetString(SI_AAB_ULT_GLOW_ENABLE_TT),
                    getFunc = function() return sv.ultGlowEnabled end,
                    setFunc = function(v) sv.ultGlowEnabled = v end,
                    default = defaults.ultGlowEnabled,
                },
                {
                    type    = "colorpicker",
                    name    = GetString(SI_AAB_ULT_GLOW_COLOR),
                    tooltip = GetString(SI_AAB_ULT_GLOW_COLOR_TT),
                    getFunc = function() local c = sv.ultGlowColor; return c[1], c[2], c[3], c[4] end,
                    setFunc = function(r, g, b, a) sv.ultGlowColor = { r, g, b, a or 1 } end,
                    default = {
                        r = defaults.ultGlowColor[1], g = defaults.ultGlowColor[2],
                        b = defaults.ultGlowColor[3], a = defaults.ultGlowColor[4],
                    },
                    disabled = function() return not sv.ultGlowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_GLOW_DURATION),
                    tooltip = GetString(SI_AAB_ULT_GLOW_DURATION_TT),
                    min = 100, max = 3000, step = 50,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.ultGlowDurationMS end,
                    setFunc = function(v) sv.ultGlowDurationMS = v end,
                    default = defaults.ultGlowDurationMS,
                    disabled = function() return not sv.ultGlowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_GLOW_PADDING),
                    tooltip = GetString(SI_AAB_ULT_GLOW_PADDING_TT),
                    min = 0, max = 40, step = 1,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.ultGlowPadding end,
                    setFunc = function(v) sv.ultGlowPadding = v end,
                    default = defaults.ultGlowPadding,
                    disabled = function() return not sv.ultGlowEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_GLOW_INTENSITY),
                    tooltip = GetString(SI_AAB_ULT_GLOW_INTENSITY_TT),
                    min = 1.0, max = 2.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.ultGlowIntensity end,
                    setFunc = function(v) sv.ultGlowIntensity = v end,
                    default = defaults.ultGlowIntensity,
                    disabled = function() return not sv.ultGlowEnabled end,
                },

                { type = "header", name = GetString(SI_AAB_ULT_HEADER_READY) },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_VANILLA_SHIMMER),
                    tooltip = GetString(SI_AAB_ULT_VANILLA_SHIMMER_TT),
                    getFunc = function() return sv.vanillaUltShimmer end,
                    setFunc = function(v)
                        sv.vanillaUltShimmer = v
                        if v then
                            RestoreVanillaUltShimmer()
                        else
                            SuppressVanillaUltGlow()
                        end
                    end,
                    default = defaults.vanillaUltShimmer,
                    warning = GetString(SI_AAB_RELOAD_NOTE),
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_ENABLE),
                    tooltip = GetString(SI_AAB_ULT_ENABLE_TT),
                    getFunc = function() return sv.ultReadyEnabled end,
                    setFunc = function(v)
                        sv.ultReadyEnabled = v
                        if not v then HideUltBorder() else CheckUltimateReady() end
                    end,
                    default = defaults.ultReadyEnabled,
                },
                {
                    type    = "colorpicker",
                    name    = GetString(SI_AAB_ULT_COLOR),
                    tooltip = GetString(SI_AAB_ULT_COLOR_TT),
                    getFunc = function() local c = sv.ultReadyColor; return c[1], c[2], c[3], c[4] end,
                    setFunc = function(r, g, b, a)
                        sv.ultReadyColor = { r, g, b, a or 1 }
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = {
                        r = defaults.ultReadyColor[1], g = defaults.ultReadyColor[2],
                        b = defaults.ultReadyColor[3], a = defaults.ultReadyColor[4],
                    },
                    disabled = function() return not sv.ultReadyEnabled end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_PULSE),
                    tooltip = GetString(SI_AAB_ULT_PULSE_TT),
                    getFunc = function() return sv.ultReadyPulse end,
                    setFunc = function(v)
                        sv.ultReadyPulse = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyPulse,
                    disabled = function() return not sv.ultReadyEnabled end,
                },
                {
                    type    = "dropdown",
                    name    = GetString(SI_AAB_ULT_PULSE_MODE),
                    tooltip = GetString(SI_AAB_ULT_PULSE_MODE_TT),
                    choices       = { GetString(SI_AAB_PULSE_STYLE_SMOOTH), GetString(SI_AAB_PULSE_STYLE_BLINK), GetString(SI_AAB_PULSE_STYLE_RAINBOW) },
                    choicesValues = { "smooth", "blink", "smooth-rainbow" },
                    getFunc = function() return sv.ultReadyMode end,
                    setFunc = function(v)
                        sv.ultReadyMode = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyMode,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_BLINK_INT),
                    tooltip = GetString(SI_AAB_ULT_BLINK_INT_TT),
                    min = 80, max = 800, step = 10,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.ultReadyBlinkIntMS end,
                    setFunc = function(v)
                        sv.ultReadyBlinkIntMS = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyBlinkIntMS,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "blink" end,
                },
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_ULT_COLOR_CYCLE),
                    tooltip = GetString(SI_AAB_ULT_COLOR_CYCLE_TT),
                    getFunc = function() return sv.ultColorCycleEnabled end,
                    setFunc = function(v)
                        sv.ultColorCycleEnabled = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultColorCycleEnabled,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "blink" end,
                },
                {
                    type    = "colorpicker",
                    name    = GetString(SI_AAB_ULT_COLOR_SECOND),
                    tooltip = GetString(SI_AAB_ULT_COLOR_SECOND_TT),
                    getFunc = function() local c = sv.ultColorCycleSecondary; return c[1], c[2], c[3], c[4] end,
                    setFunc = function(r, g, b, a)
                        sv.ultColorCycleSecondary = { r, g, b, a or 1 }
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = {
                        r = defaults.ultColorCycleSecondary[1], g = defaults.ultColorCycleSecondary[2],
                        b = defaults.ultColorCycleSecondary[3], a = defaults.ultColorCycleSecondary[4],
                    },
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "blink" or not sv.ultColorCycleEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_RAINBOW_SAT),
                    tooltip = GetString(SI_AAB_ULT_RAINBOW_SAT_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.ultRainbowSaturation end,
                    setFunc = function(v)
                        sv.ultRainbowSaturation = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultRainbowSaturation,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "smooth-rainbow" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_RAINBOW_LIGHT),
                    tooltip = GetString(SI_AAB_ULT_RAINBOW_LIGHT_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.ultRainbowLightness end,
                    setFunc = function(v)
                        sv.ultRainbowLightness = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultRainbowLightness,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "smooth-rainbow" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_PULSE_DUR),
                    tooltip = GetString(SI_AAB_ULT_PULSE_DUR_TT),
                    min = 80, max = 2000, step = 20,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.ultReadyPulseDurMS end,
                    setFunc = function(v)
                        sv.ultReadyPulseDurMS = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyPulseDurMS,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse or sv.ultReadyMode ~= "smooth" end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_PULSE_MIN),
                    tooltip = GetString(SI_AAB_ULT_PULSE_MIN_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.ultReadyMinAlpha end,
                    setFunc = function(v)
                        sv.ultReadyMinAlpha = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyMinAlpha,
                    disabled = function() return not sv.ultReadyEnabled or not sv.ultReadyPulse end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_INTENSITY),
                    tooltip = GetString(SI_AAB_ULT_INTENSITY_TT),
                    min = 1.0, max = 2.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.ultReadyIntensity end,
                    setFunc = function(v)
                        sv.ultReadyIntensity = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyIntensity,
                    disabled = function() return not sv.ultReadyEnabled end,
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_ULT_PADDING),
                    tooltip = GetString(SI_AAB_ULT_PADDING_TT),
                    min = 0, max = 24, step = 1,
                    decimals = 0, clampInput = true,
                    getFunc = function() return sv.ultReadyPadding end,
                    setFunc = function(v)
                        sv.ultReadyPadding = v
                        if ultIsReady then ShowUltBorder() end
                    end,
                    default = defaults.ultReadyPadding,
                    disabled = function() return not sv.ultReadyEnabled end,
                },
            },
        },

        {
            type     = "submenu",
            name     = C_FRAME .. GetString(SI_AAB_SUB_FRAME) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_FRAME_TT),
            controls = {
                {
                    type    = "checkbox",
                    name    = GetString(SI_AAB_THIN_FRAME),
                    tooltip = GetString(SI_AAB_THIN_FRAME_TT),
                    getFunc = function() return sv.thinFrameEnabled end,
                    setFunc = function(v) sv.thinFrameEnabled = v end,
                    default = defaults.thinFrameEnabled,
                    warning = GetString(SI_AAB_RELOAD_NOTE),
                },
                {
                    type    = "slider",
                    name    = GetString(SI_AAB_FRAME_ALPHA),
                    tooltip = GetString(SI_AAB_FRAME_ALPHA_TT),
                    min = 0.0, max = 1.0, step = 0.05,
                    decimals = 2, clampInput = true,
                    getFunc = function() return sv.frameAlpha end,
                    setFunc = function(v) sv.frameAlpha = v; ApplyFrameAlpha() end,
                    default = defaults.frameAlpha,
                    disabled = function() return not sv.thinFrameEnabled end,
                },
                {
                    type    = "dropdown",
                    name    = GetString(SI_AAB_EDGE_STYLE),
                    tooltip = GetString(SI_AAB_EDGE_STYLE_TT),
                    choices = {
                        GetString(SI_AAB_EDGE_CLASSIC),
                        GetString(SI_AAB_EDGE_V2),
                        GetString(SI_AAB_EDGE_PURPLE),
                        GetString(SI_AAB_EDGE_RED),
                        GetString(SI_AAB_EDGE_BLUE),
                        GetString(SI_AAB_EDGE_AQUA),
                        GetString(SI_AAB_EDGE_DARKRED),
                        GetString(SI_AAB_EDGE_DARKPURPLE),
                    },
                    choicesValues = { "classic", "v2", "purple", "red", "blue", "aqua", "darkred", "darkpurple" },
                    getFunc = function() return sv.edgeStyle end,
                    setFunc = function(v) sv.edgeStyle = v; ApplyEdgeTexture() end,
                    default = defaults.edgeStyle,
                    warning = GetString(SI_AAB_RELOAD_NOTE),
                    requiresReload = true,
                    disabled = function() return not sv.thinFrameEnabled end,
                },
                {
                    type    = "button",
                    name    = GetString(SI_AAB_RELOAD_UI),
                    tooltip = GetString(SI_AAB_RELOAD_UI_TT),
                    func    = function() ReloadUI("ingame") end,
                    width   = "half",
                },
                { type = "divider" },
                { type = "description", text = GetString(SI_AAB_FRAME_THEME_NOTE) },
            },
        },
        {
            type     = "submenu",
            name     = C_DONATE .. GetString(SI_AAB_SUB_CONTACT) .. C_RESET,
            tooltip  = GetString(SI_AAB_SUB_CONTACT_TT),
            controls = {
                { type = "description", text = GetString(SI_AAB_CONTACT_DESC) },
                {
                    type    = "button",
                    name    = GetString(SI_AAB_CONTACT_DONATE_BTN),
                    tooltip = GetString(SI_AAB_CONTACT_DONATE_BTN_TT),
                    func    = function() OpenDonationMail() end,
                    width   = "full",
                },
            },
        },
    })
end

-- init

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- Neuer, server-abhaengiger Scope (EU/NA/PTS getrennt) via GetWorldName()
    local worldName = GetWorldName()
    sv = ZO_SavedVars:NewAccountWide("AnimatedActionBarPlusSV", 1, worldName, defaults)

    -- One-Time-Migration der alten, server-unabhaengigen Einstellungen in den neuen Scope
    if not sv.__serverMigrated then
        local old = ZO_SavedVars:NewAccountWide("AnimatedActionBarPlusSV", 1, nil, {})
        if old then
            for k, v in pairs(old) do
                -- interne ZO_SavedVars-Felder und schon vorhandene Werte nicht ueberschreiben
                if k ~= "version" and k ~= "_internal" and k ~= "__serverMigrated" and sv[k] == nil then
                    sv[k] = v
                end
            end
        end
        sv.__serverMigrated = true

        -- Alte Strukturen leeren, damit die SV-Datei nicht unnoetig waechst
        if old then
            for k in pairs(old) do
                if k ~= "version" and k ~= "_internal" then
                    old[k] = nil
                end
            end
        end
    end

    if sv.thinFrameEnabled then
        ApplyThinFrameTemplate()
    end

    SecurePostHook(ActionButton, "ApplyStyle", function(self)
        if self and self.slot and self.slot.slotNum == ULT_SLOT_INDEX then
            -- Vanilla-Rahmen und Fill-Animationen immer ausblenden
            for _, name in ipairs(ULT_FRAME_CHILDREN) do
                local c = self.slot:GetNamedChild(name)
                if c then
                    if c.SetTexture then c:SetTexture("") end
                    c:SetAlpha(0)
                    if c.SetHidden then c:SetHidden(true) end
                end
            end
            -- Schimmern nur wegnehmen, wenn der Nutzer das so will
            if not sv.vanillaUltShimmer then
                for _, name in ipairs(ULT_SHIMMER_CHILDREN) do
                    local c = self.slot:GetNamedChild(name)
                    if c then
                        if c.SetTexture then c:SetTexture("") end
                        c:SetAlpha(0)
                        if c.SetHidden then c:SetHidden(true) end
                    end
                end
            end
        end
    end)

    InstallBounceHook()
    InstallQuickslotHook()
    InstallActivationHighlightHook()
    BuildMenu()
    RegisterEvents()

    SLASH_COMMANDS["/animatedactionbarplus"] = function()
        if LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(_G[ADDON_NAME .. "Panel"])
        end
    end
    SLASH_COMMANDS["/aab"] = function()
        if LibAddonMenu2 and LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(_G[ADDON_NAME .. "Panel"])
        end
    end
    SLASH_COMMANDS["/aabdebug"] = function()
        local head = "|cffd700"
        local key  = "|caaaaaa"
        local on   = "|c44dd44"
        local off  = "|cdd4444"
        local val  = "|cffffff"
        local e    = "|r"

        local function yn(b)
            local txt = b and GetString(SI_AAB_DBG_ON) or GetString(SI_AAB_DBG_OFF)
            return (b and on or off) .. txt .. e
        end
        local function v(x) return val .. tostring(x) .. e end
        local function lbl(id) return key .. GetString(id) .. ": " .. e end

        d(head .. "=== " .. ADDON_NAME .. " ===" .. e)

        d(key .. GetString(SI_AAB_DBG_FRAME) .. e)
        d("  " .. lbl(SI_AAB_DBG_THINFRAME) .. yn(sv.thinFrameEnabled))
        d("  " .. lbl(SI_AAB_DBG_STYLE) .. v(sv.edgeStyle) .. "  " .. lbl(SI_AAB_DBG_TEMPLATE) .. v(GetEdgeTemplate()))
        d("  " .. lbl(SI_AAB_DBG_ALPHA) .. v(sv.frameAlpha))

        d(key .. GetString(SI_AAB_DBG_BOUNCE) .. e)
        d("  " .. lbl(SI_AAB_DBG_ACTIVE) .. yn(sv.bounceEnabled) .. "  " .. lbl(SI_AAB_DBG_STYLE) .. v(sv.animationStyle))
        d("  " .. lbl(SI_AAB_DBG_ONPROC) .. yn(sv.bounceOnProc) .. "  " .. lbl(SI_AAB_DBG_ULTI) .. yn(sv.ultBounceEnabled))

        d(key .. GetString(SI_AAB_DBG_GLOWPULSE) .. e)
        d("  " .. lbl(SI_AAB_DBG_GLOW) .. yn(sv.glowEnabled) .. "  " .. lbl(SI_AAB_DBG_PULSE) .. yn(sv.pulseEnabled))
        d("  " .. lbl(SI_AAB_DBG_PULSEMODE) .. v(sv.pulseMode) .. "  " .. lbl(SI_AAB_DBG_COLORCYCLE) .. yn(sv.colorCycleEnabled))
        d("  " .. lbl(SI_AAB_DBG_VANILLAPROC) .. yn(sv.vanillaProcGlow))

        d(key .. GetString(SI_AAB_DBG_ULTFRAME) .. e)
        d("  " .. lbl(SI_AAB_DBG_READY) .. yn(sv.ultReadyEnabled) .. "  " .. lbl(SI_AAB_DBG_PULSE) .. yn(sv.ultReadyPulse))
        d("  " .. lbl(SI_AAB_DBG_MODE) .. v(sv.ultReadyMode) .. "  " .. lbl(SI_AAB_DBG_COLORCYCLE) .. yn(sv.ultColorCycleEnabled))
        if sv.ultReadyMode == "smooth-rainbow" then
            d("  " .. lbl(SI_AAB_DBG_RAINBOW_SAT) .. v(sv.ultRainbowSaturation) .. "  " .. lbl(SI_AAB_DBG_RAINBOW_LIGHT) .. v(sv.ultRainbowLightness))
        end
        d("  " .. lbl(SI_AAB_DBG_VANILLASHIMMER) .. yn(sv.vanillaUltShimmer))

        d(lbl(SI_AAB_DBG_SERVER) .. v(GetWorldName()))
        d(head .. "=============================" .. e)
    end

    zo_callLater(function()
        RefreshAllProcs()
        RefreshProcGlowSuppression()
        ApplyFrameAlpha()
        ApplyEdgeTexture()
        CheckUltimateReady()
        SuppressVanillaUltGlow()
        lastQuickslotCooldownRemain =
            GetSlotCooldownInfo(QUICKSLOT_INDEX, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) or 0
    end, 500)
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
