local NAME = 'AltAttributes'
local SV_VER = 1

local SETTINGS

local function getWidth()
    return zo_clamp(GuiRoot:GetWidth() * .25, 300, 600)
end
-------------------------------------
--Base bar--
-------------------------------------
local StandardBar = ZO_Object:Subclass()
function StandardBar:New(...)
    local bar = ZO_Object.New(self)
    bar:Initialize(...)
    return bar
end

function StandardBar:Initialize(unitTag, powerType, topLevelCtrl)
    self.unitTag = unitTag
    self.powerType = powerType
    self.control = CreateControlFromVirtual("ALTATTR_Frame"..unitTag..powerType, topLevelCtrl, "ALTATTR_Bar")
    self.control:SetHidden(true)
    self.attrText = GetControl(self.control, "Text")
    self.attrTextPercent = GetControl(self.control, "Percent")
    self.attrBar = GetControl(self.control, "Bar")

    ZO_StatusBar_SetGradientColor(self.attrBar, ZO_POWER_BAR_GRADIENT_COLORS[powerType])

    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        self:OnPowerUpdate(powerPool, powerPoolMax, false)
    end
    local powerUpdateEventHandler = ZO_MostRecentPowerUpdateHandler:New("ALTATTR_Bar"..unitTag..powerType, PowerUpdateHandlerFunction)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_POWER_TYPE, powerType)
    powerUpdateEventHandler:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, unitTag)
    --self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:UpdateWidth() end)
    --self.control:RegisterForEvent(EVENT_SCREEN_RESIZED, function() self:UpdateWidth() end)
    self.control:RegisterForEvent(EVENT_PLAYER_ALIVE, function() self:Refresh() end)

    self:Refresh(true)
end

function StandardBar:Refresh(force)
    if force then
        self:ApplyStyle()
    end

    local power, maxPower = GetUnitPower(self.unitTag, self.powerType)
    self:OnPowerUpdate(power, maxPower, force)
end

function StandardBar:FormatPercent(health, maxHealth)
    local percent = 0
    local percentText
    if maxHealth ~= 0 then
        percent = (health / maxHealth) * 100
    end
    if percent < 10 then
        percentText = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
        percentText = ZO_FastFormatDecimalNumber(percentText)
    else
        percentText = zo_round(percent)
    end

    return percentText..'%'
end

function StandardBar:OnPowerUpdate(health, maxHealth, force)
    ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)

    self:UpdateResourceNumbers(health, maxHealth)
end

function StandardBar:UpdateResourceNumbers(health, maxHealth)
    self.attrText:SetText(ZO_AbbreviateAndLocalizeNumber(health, NUMBER_ABBREVIATION_PRECISION_TENTHS, false))
    self.attrTextPercent:SetText(self:FormatPercent(health, maxHealth))
end

function StandardBar:ApplyStyle()
    ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameLeft"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameRightArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter"))

    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgLeft"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgRightArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))

    ApplyTemplateToControl(self.attrBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ALTATTR_Bar"))
end

function StandardBar:SetWidth(value)
    self.control:SetWidth(value)
end

function StandardBar:SetHeight(value)
    local prevHeight = self.attrBar:GetHeight()
    if prevHeight ~= value then
        local mod = value / prevHeight
        local frameLeft = GetControl(self.control, "FrameLeft")
        local frameRight = GetControl(self.control, "FrameRight")
        local bgLeft = GetControl(self.control, "BgContainerBgLeft")
        local bgRight = GetControl(self.control, "BgContainerBgRight")
        frameLeft:SetWidth(zo_round(frameLeft:GetWidth() * mod) - 3)
        frameRight:SetWidth(zo_round(frameRight:GetWidth() * mod) - 3)
        bgLeft:SetWidth(zo_round(bgLeft:GetWidth() * mod) - 3)
        bgRight:SetWidth(zo_round(bgRight:GetWidth() * mod) - 3)

        self.control:SetHeight(value)
        self.attrBar:SetHeight(value)

        frameLeft:SetHeight(value)
        frameRight:SetHeight(value)
        bgLeft:SetHeight(value)
        bgRight:SetHeight(value)
        GetControl(self.control, "FrameCenter"):SetHeight(value)
        GetControl(self.control, "BgContainerBgCenter"):SetHeight(value)

        local fontMod = IsInGamepadPreferredMode() and 1 / 3 or 2 / 3
        local font = '$(GAMEPAD_LIGHT_FONT)|' .. zo_round(value * fontMod) .. '|soft-shadow-thick'
        self.attrText:SetFont(font)
        self.attrTextPercent:SetFont(font)
    end
end

function StandardBar:Show()
    self.control:SetHidden(false)
end

function StandardBar:Hide()
    self.control:SetHidden(true)
end
-------------------------------------
--Reversed bar--
-------------------------------------
local ReversedBar = StandardBar:Subclass()
function ReversedBar:New(...)
    return StandardBar.New(self, ...)
end

function ReversedBar:ApplyStyle()
    ApplyTemplateToControl(self.control:GetNamedChild("FrameLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameLeftArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameRight"))
    ApplyTemplateToControl(self.control:GetNamedChild("FrameCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter"))

    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgLeft"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgLeftArrow"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgRight"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgRight"))
    ApplyTemplateToControl(self.control:GetNamedChild("BgContainerBgCenter"), ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter"))

    ApplyTemplateToControl(self.attrBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
    ApplyTemplateToControl(self.control, ZO_GetPlatformTemplate("ALTATTR_BarReversed"))
end
-------------------------------------
--HP shielded bar --
-------------------------------------
-- local ShieldedBar = StandardBar:Subclass()
-- function ShieldedBar:New(...)
--     return StandardBar.New(self, ...)
-- end

-- function ShieldedBar:Initialize(unitTag, powerType, topLevelCtrl)
--     self.curShield = 0
--     self.curHP = 0
--     self.maxHP = 0
--     self.hasTrauma = false  -- Trauma 状态标记

--     StandardBar.Initialize(self, unitTag, powerType, topLevelCtrl)

--     -- 保存原始渐变色 (红色)
--     self.originalGradientColors = {
--         ZO_ColorDef:New(ZO_POWER_BAR_GRADIENT_COLORS[powerType][1]:UnpackRGB()),
--         ZO_ColorDef:New(ZO_POWER_BAR_GRADIENT_COLORS[powerType][2]:UnpackRGB())
--     }
    
--     -- Trauma 时的渐变色 RGB(51, 171, 173) 青色
--     local traumaColor1 = ZO_ColorDef:New(51/255, 171/255, 173/255)
--     local traumaColor2 = ZO_ColorDef:New(51/255, 171/255, 173/255)
--     self.traumaGradientColors = { traumaColor1, traumaColor2 }

--     self.shieldBar = CreateControlFromVirtual("ALTATTR_Shield"..unitTag..powerType, self.attrBar, "ALTATTR_ShieldBar")
--     local SHIELD_COLOR = ZO_ColorDef:New(1, 0.49, 0.13, 0.50)
--     self.shieldBar:SetColor(SHIELD_COLOR:UnpackRGBA())
--     self.shieldBar:SetHeight(self.control:GetHeight())
--     self:OnUpdateShield(0, true)

--     -- Trauma Bar
--     self.curTrauma = 0

--     self.traumaBar = CreateControlFromVirtual("ALTATTR_Trauma"..unitTag..powerType, self.attrBar, "ALTATTR_ShieldBar")

--     local TRAUMA_COLOR = ZO_ColorDef:New(0.8, 0.8, 0.8, 1)
--     self.traumaBar:SetColor(TRAUMA_COLOR:UnpackRGBA())
--     self.traumaBar:SetHeight(self.control:GetHeight())

--     -- 层级：在 shield 上面
--     self.traumaBar:SetHidden(true)

--     self:OnUpdateTrauma(0, true)

--     local function onVisualPower(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
--         local value = oldMaxValue == nil and oldValue or newValue

--         if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
--             self:OnUpdateShield(value, false)

--         elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
--             self:OnUpdateTrauma(value, false)
--         end
--     end

--     local function onVisualPowerRemoved(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
--         if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
--             self:OnUpdateShield(0, false)

--         elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
--             self:OnUpdateTrauma(0, false)
--         end
--     end

--     topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, onVisualPower)
--     topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTag)
--     topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, onVisualPower)
--     topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTag)
--     topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, onVisualPowerRemoved)
--     topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTag)
-- end

-- -- 更新 Trauma 颜色效果（只改血量条，护盾不变）
-- function ShieldedBar:UpdateTraumaColor()
--     if self.hasTrauma then
--         ZO_StatusBar_SetGradientColor(self.attrBar, self.traumaGradientColors)
--     else
--         ZO_StatusBar_SetGradientColor(self.attrBar, self.originalGradientColors)
--     end
-- end

-- function ShieldedBar:OnUpdateTrauma(value, force)
--     local previousHasTrauma = self.hasTrauma
--     self.curTrauma = value or 0
--     self.hasTrauma = self.curTrauma > 0
    
--     -- Trauma 状态变化时更新血量条颜色
--     if previousHasTrauma ~= self.hasTrauma then
--         self:UpdateTraumaColor()
--     end
    
--     ZO_StatusBar_SmoothTransition(self.traumaBar, self.curTrauma, self.maxHP, force)
--     self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
-- end

-- function ShieldedBar:OnPowerUpdate(health, maxHealth, force)
--     self.curHP = health
--     self.maxHP = maxHealth
--     ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)
--     self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
-- end

-- function ShieldedBar:OnUpdateShield(shield, force)
--     self.curShield = shield
--     ZO_StatusBar_SmoothTransition(self.shieldBar, shield, self.maxHP, force)
--     self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
-- end

-- function ShieldedBar:UpdateResourceNumbers(health, maxHealth, shield, trauma)
--     if (shield and shield > 0) or (trauma and trauma > 0) then
--         local text = ZO_AbbreviateAndLocalizeNumber(health, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false) .. "["
        
--         if shield and shield > 0 then
--             text = text .. ZO_AbbreviateAndLocalizeNumber(shield, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false)
--         end
        
--         if trauma and trauma > 0 then
--             text = text .. "-" .. ZO_AbbreviateAndLocalizeNumber(trauma, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false)
--         end
        
--         text = text .. "]"
        
--         self.attrText:SetText(text)
--         self.attrTextPercent:SetText(self:FormatPercent(health, maxHealth))
--     else
--         StandardBar.UpdateResourceNumbers(self, health, maxHealth)
--     end
-- end

-- function ShieldedBar:ApplyStyle()
--     StandardBar.ApplyStyle(self)
--     ApplyTemplateToControl(self.shieldBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
-- end

-- function ShieldedBar:SetHeight(value)
--     StandardBar.SetHeight(self, value)
--     if self.shieldBar then
--         if self.shieldBar:GetHeight() ~= value then
--             self.shieldBar:SetHeight(value)
--         end
--     end
--     if self.traumaBar then
--         if self.traumaBar:GetHeight() ~= value then
--             self.traumaBar:SetHeight(value)
--         end
--     end
-- end

-------------------------------------
--HP shielded bar --
-------------------------------------
local ShieldedBar = StandardBar:Subclass()
function ShieldedBar:New(...)
    return StandardBar.New(self, ...)
end

function ShieldedBar:Initialize(unitTag, powerType, topLevelCtrl)
    self.curShield = 0
    self.curHP = 0
    self.maxHP = 0

    StandardBar.Initialize(self, unitTag, powerType, topLevelCtrl)

    -- Trauma Bar - 和护盾一样独立显示
    self.curTrauma = 0
    self.traumaBar = CreateControlFromVirtual("ALTATTR_Trauma"..unitTag..powerType, self.attrBar, "ALTATTR_ShieldBar")
    local TRAUMA_COLOR = ZO_ColorDef:New(51/255, 171/255, 173/255)
    self.traumaBar:SetColor(TRAUMA_COLOR:UnpackRGBA())
    self.traumaBar:SetHeight(self.control:GetHeight())
    self:OnUpdateTrauma(0, true)

    self.shieldBar = CreateControlFromVirtual("ALTATTR_Shield"..unitTag..powerType, self.attrBar, "ALTATTR_ShieldBar")
    local SHIELD_COLOR = ZO_ColorDef:New(1, 0.49, 0.13, 1)
    self.shieldBar:SetColor(SHIELD_COLOR:UnpackRGBA())
    self.shieldBar:SetHeight(self.control:GetHeight())
    self:OnUpdateShield(0, true)

    self.shieldBar:SetDrawLevel(self.traumaBar:GetDrawLevel() + 1)

    local function onVisualPower(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
        local value = oldMaxValue == nil and oldValue or newValue

        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(value, false)

        elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(value, false)
        end
    end

    local function onVisualPowerRemoved(_, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
        if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
            self:OnUpdateShield(0, false)

        elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
            self:OnUpdateTrauma(0, false)
        end
    end

    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, onVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTag)
    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, onVisualPower)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTag)
    topLevelCtrl:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, onVisualPowerRemoved)
    topLevelCtrl:AddFilterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTag)

     -- 关键：每次加载完成后，强制同步一下游戏数据
    topLevelCtrl:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function()
        -- 重新获取当前的血量、护盾、Trauma 的真实值
        local health, maxHealth = GetUnitPower(self.unitTag, self.powerType)
        self.curHP = health
        self.maxHP = maxHealth
        ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, true)
        
        -- 注意：这里不能直接清零，而是要从游戏获取真实值
        -- 但 Trauma 和护盾没有直接的 API 获取，所以只能清零
        -- 因为离开副本后这些值应该都是 0
        self:OnUpdateTrauma(value, true)
        -- self:OnUpdateShield(value, true)
        
        self:UpdateResourceNumbers(health, maxHealth, self.curShield, self.curTrauma)
    end)
end

function ShieldedBar:OnUpdateTrauma(value, force)
    self.curTrauma = value
    ZO_StatusBar_SmoothTransition(self.traumaBar, self.curTrauma, self.maxHP, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:OnPowerUpdate(health, maxHealth, force)
    self.curHP = health
    self.maxHP = maxHealth
    ZO_StatusBar_SmoothTransition(self.attrBar, health, maxHealth, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:OnUpdateShield(shield, force)
    self.curShield = shield
    ZO_StatusBar_SmoothTransition(self.shieldBar, shield, self.maxHP, force)
    self:UpdateResourceNumbers(self.curHP, self.maxHP, self.curShield, self.curTrauma)
end

function ShieldedBar:UpdateResourceNumbers(health, maxHealth, shield, trauma)
    if (shield and shield > 0) or (trauma and trauma > 0) then
        local text = ZO_AbbreviateAndLocalizeNumber(health, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false) .. "["
        
        if shield and shield > 0 then
            text = text .. ZO_AbbreviateAndLocalizeNumber(shield, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false)
        end
        
        if trauma and trauma > 0 then
            text = text .. "-" .. ZO_AbbreviateAndLocalizeNumber(trauma, NUMBER_ABBREVIATION_PRECISION_LARGEST_UNIT, false)
        end
        
        text = text .. "]"
        
        self.attrText:SetText(text)
        self.attrTextPercent:SetText(self:FormatPercent(health, maxHealth))
    else
        StandardBar.UpdateResourceNumbers(self, health, maxHealth)
    end
end

function ShieldedBar:ApplyStyle()
    StandardBar.ApplyStyle(self)
    ApplyTemplateToControl(self.shieldBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
    ApplyTemplateToControl(self.traumaBar, ZO_GetPlatformTemplate("ZO_PlayerAttributeStatusBar"))
end

function ShieldedBar:SetHeight(value)
    StandardBar.SetHeight(self, value)
    if self.shieldBar then
        if self.shieldBar:GetHeight() ~= value then
            self.shieldBar:SetHeight(value)
        end
    end
    if self.traumaBar then
        if self.traumaBar:GetHeight() ~= value then
            self.traumaBar:SetHeight(value)
        end
    end
end
-------------------------------------
-- --
-------------------------------------

ALTATTR_FakeGloss = ZO_Object:Subclass()
function ALTATTR_FakeGloss:New()
    return ZO_Object.New(self)
end
function ALTATTR_FakeGloss:SetMinMax() end
function ALTATTR_FakeGloss:SetValue() end

function AltAttributes_Initialize(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            ZO_PlayerAttributeHealth:SetHidden(true)
            ZO_PlayerAttributeMagicka:SetHidden(true)
            ZO_PlayerAttributeStamina:SetHidden(true)

            altBarHP = ShieldedBar:New("player", POWERTYPE_HEALTH, topLevelCtrl)
            altBarHP:Show()

            altBarMP = ReversedBar:New("player", POWERTYPE_MAGICKA, topLevelCtrl)
            altBarMP:Show()

            altBarSP = StandardBar:New("player", POWERTYPE_STAMINA, topLevelCtrl)
            altBarSP:Show()

            local function rePosition()
                if IsInGamepadPreferredMode() then
                    topLevelCtrl:SetAnchor(BOTTOM, ZO_ActionBar1, TOP, 0, -80)
                else
                    topLevelCtrl:SetAnchor(BOTTOM, ZO_ActionBar1, TOP, 0, -50)
                end
            end

            local function rePositionDefaultBars()
                ZO_PlayerAttributeSiegeHealth:ClearAnchors()
                ZO_PlayerAttributeWerewolf:ClearAnchors()
                ZO_PlayerAttributeMountStamina:ClearAnchors()
                if IsInGamepadPreferredMode() then
                    ZO_PlayerAttributeSiegeHealth:SetAnchor(TOPLEFT, altBarHP.control, BOTTOMLEFT, 0, -25)
                    ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, altBarMP.control, BOTTOMRIGHT, 0, -25)
                    ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, altBarSP.control, BOTTOMLEFT, 0, -25)
                else
                    ZO_PlayerAttributeSiegeHealth:SetAnchor(TOPLEFT, altBarHP.control, BOTTOMLEFT, 0, -1)
                    ZO_PlayerAttributeWerewolf:SetAnchor(TOPRIGHT, altBarMP.control, BOTTOMRIGHT, 0, -1)
                    ZO_PlayerAttributeMountStamina:SetAnchor(TOPLEFT, altBarSP.control, BOTTOMLEFT, 0, -1)
                end

            end

            local function applyStyles()
                local bars = {altBarHP, altBarMP, altBarSP}
                for _, bar in pairs(bars) do
                    bar:ApplyStyle()
                    bar:SetWidth(360)
                    bar:SetHeight(IsInGamepadPreferredMode() and 96 or 32)
                end
                if IsInGamepadPreferredMode() then
                    altBarHP.control:SetAnchor(TOP, topLevelCtrl, TOP, 0, -36)
                    altBarMP.control:SetAnchor(TOPRIGHT, altBarHP.control, BOTTOM, -5, -44)
                    altBarSP.control:SetAnchor(TOPLEFT, altBarHP.control, BOTTOM, 5, -44)
                else
                    altBarHP.control:SetAnchor(TOP, topLevelCtrl, TOP, 0, -10)
                    altBarMP.control:SetAnchor(TOPRIGHT, altBarHP.control, BOTTOM, -5, 16)
                    altBarSP.control:SetAnchor(TOPLEFT, altBarHP.control, BOTTOM, 5, 16)
                end
                if not Azurah then
                    rePosition()
                end
                rePositionDefaultBars()
            end

            topLevelCtrl:RegisterForEvent(EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, applyStyles)
            applyStyles()
            rePosition()

            local fragment = ZO_SimpleSceneFragment:New(topLevelCtrl)
            HUD_SCENE:AddFragment(fragment)
            HUD_UI_SCENE:AddFragment(fragment)
            SIEGE_BAR_SCENE:AddFragment(fragment)
            SIEGE_BAR_UI_SCENE:AddFragment(fragment)

            if Azurah then
                Azurah.uiFrames.keyboard['ALTATTR_Container'] = {1, 'Alternative Attributes Bars'}
                Azurah.uiFrames.gamepad['ALTATTR_Container'] = {1, 'Alternative Attributes Bars'}
            end

             -- 玩家死亡时隐藏所有属性条
            local function onPlayerDeath()
                altBarHP:Hide()
                altBarMP:Hide()
                altBarSP:Hide()
            end

            -- 玩家复活时重新显示
            local function onPlayerResurrect()
                altBarHP:Show()
                altBarMP:Show()
                altBarSP:Show()
                -- 刷新一下数值
                altBarHP:Refresh(true)
                altBarMP:Refresh(true)
                altBarSP:Refresh(true)
                applyStyles()
            end

            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_DEAD, onPlayerDeath)
            EVENT_MANAGER:RegisterForEvent(NAME, EVENT_PLAYER_ALIVE, onPlayerResurrect)

            EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end