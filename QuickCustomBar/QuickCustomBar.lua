-- QuickCustomBar.lua

local QCB = {}
QuickCustomBar = QCB

local NAME = "QuickCustomBar"
local SLOT_COUNT = 10
local SLOT_SIZE = 50
local SLOT_SPACE = 2

-- 存储按钮引用
local buttons = {}

-- 获取动作条按钮尺寸（参考BUI）
local function GetButtonSize()
    local ultimateButton = ZO_ActionBar_GetButton(8)
    if ultimateButton and ultimateButton.slot then
        return ultimateButton.slot:GetHeight()
    end
    return 50
end

-- 创建单个按钮格子
local function CreateSlotButton(parent, index, size, space)
    local slot = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index, parent, CT_CONTROL)
    slot:SetDimensions(size, size)
    
    -- 背景纹理
    local bg = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index .. "Bg", slot, CT_TEXTURE)
    bg:SetDimensions(size, size)
    bg:SetAnchor(TOPLEFT, slot, TOPLEFT, 0, 0)
    bg:SetTexture("/esoui/art/actionbar/abilityinset.dds")
    
    -- 边框（技能格子风格）
    local edge = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index .. "Edge", slot, CT_TEXTURE)
    edge:SetDimensions(size, size)
    edge:SetAnchor(TOPLEFT, slot, TOPLEFT, 0, 0)
    edge:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")
    
    -- 图标
    local icon = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index .. "Icon", slot, CT_TEXTURE)
    icon:SetDimensions(size - 6, size - 6)
    icon:SetAnchor(TOPLEFT, slot, TOPLEFT, 3, 3)
    icon:SetTexture("/esoui/art/icons/ability_warrior_010.dds")
    -- icon:SetHidden(true)
    
    -- 鼠标悬停效果
    local mouseOver = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index .. "MouseOver", slot, CT_TEXTURE)
    mouseOver:SetDimensions(size - 4, size - 4)
    mouseOver:SetAnchor(TOPLEFT, slot, TOPLEFT, 2, 2)
    mouseOver:SetTexture("/esoui/art/actionbar/actionbar_mouseover.dds")
    mouseOver:SetHidden(true)
    mouseOver:SetDrawLayer(2)
    
    -- 显示文字
    local text = WINDOW_MANAGER:CreateControl("QCB_Slot" .. index .. "Text", slot, CT_LABEL)
    text:SetFont("ZoFontGameBold")
    text:SetColor(1, 1, 1, 1)
    text:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    text:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    text:SetDimensions(size - 4, size - 4)
    text:SetAnchor(TOPLEFT, slot, TOPLEFT, 2, 2)
    text:SetHidden(true)
    
    -- 启用鼠标
    slot:SetMouseEnabled(true)
    
    -- 保存子控件引用
    slot.bg = bg
    slot.icon = icon
    slot.edge = edge
    slot.mouseOver = mouseOver
    slot.text = text
    slot.index = index
    
    return slot
end

function QCB.Initialize(event, addonName)
    if addonName ~= NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NAME .. "_INIT", EVENT_ADD_ON_LOADED)
    
    local size = GetButtonSize()
    local barWidth = (size + SLOT_SPACE) * SLOT_COUNT
    
    -- 创建主容器
    local bar = WINDOW_MANAGER:CreateControl("QCB_Bar", ZO_ActionBar1, CT_CONTROL)
    bar:SetDimensions(barWidth, size)
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, ZO_ActionBar1, TOPRIGHT, 20, 0)
    bar:SetMovable(true)
    bar:SetMouseEnabled(true)
    bar:SetClampedToScreen(true)
    
    -- 保存到全局
    _G["QCB_Bar"] = bar
    
    -- 创建10个按钮格子
    for i = 1, SLOT_COUNT do
        local col = (i - 1) * (size + SLOT_SPACE)
        local slot = CreateSlotButton(bar, i, size, SLOT_SPACE)
        slot:SetAnchor(TOPLEFT, bar, TOPLEFT, col, 0)
        buttons[i] = slot
        
        -- 左键点击
        slot:SetHandler("OnMouseDown", function(self, button)
            if button == 1 then
                SCENE_MANAGER:SetInUIMode()
                QCB.OnClicked(i)
            end
        end)
        
        -- 鼠标进入
        slot:SetHandler("OnMouseEnter", function(self)
            self.mouseOver:SetHidden(false)
        end)
        
        -- 鼠标离开
        slot:SetHandler("OnMouseExit", function(self)
            self.mouseOver:SetHidden(true)
        end)
    end
    
    -- 移动停止时保存位置
    bar:SetHandler("OnMoveStop", function()
        local left = bar:GetLeft()
        local top = bar:GetTop()
        d(string.format("[%s] Position: %d, %d", NAME, left, top))
    end)
    
    d("[" .. NAME .. "] Initialized! Size: " .. size)
end

function QCB.OnClicked(slot)
    d("Clicked Slot " .. slot)
    PlaySound("Click")
end

-- 设置指定槽位的图标
function QCB.SetSlotIcon(slot, iconPath)
    if slot < 1 or slot > SLOT_COUNT then return end
    local button = buttons[slot]
    if button then
        button.icon:SetTexture(iconPath)
        button.icon:SetHidden(false)
    end
end

-- 设置指定槽位的文字
function QCB.SetSlotText(slot, text)
    if slot < 1 or slot > SLOT_COUNT then return end
    local button = buttons[slot]
    if button then
        button.text:SetText(text)
        button.text:SetHidden(false)
    end
end

-- 获取指定槽位
function QCB.GetSlot(slot)
    return buttons[slot]
end

EVENT_MANAGER:RegisterForEvent(NAME .. "_INIT", EVENT_ADD_ON_LOADED, QCB.Initialize)
