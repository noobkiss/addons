local ADDON_NAME = "CyrodiilMapLabels"
local wm = WINDOW_MANAGER
local labels = {}

-- Load data file
CyrodiilMapLabelsData = CyrodiilMapLabelsData or {}

-- Check if player is on the main Cyrodiil map (not sub-maps like gate maps)
local function IsPlayerInCyrodiilMainMap()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    local mapTexture = GetMapTileTexture()  -- Get the current map texture

    if not mapTexture then return false end  -- Ensure it's valid

    -- Main Cyrodiil Map uses "ava_whole"
    local isMainMap = string.find(mapTexture:lower(), "ava_whole")

    return zoneId == 181 and isMainMap ~= nil
end

-- Create bilingual labels (English + Chinese)
local function CreateBilingualLabel(engText, cnText, x, y)
    -- 先创建阴影容器（底层，偏移1像素）
    local shadowContainer = wm:CreateControl(nil, ZO_WorldMapContainer, CT_CONTROL)
    shadowContainer:SetDimensions(180, 50)
    shadowContainer:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, x + 1, y + 1)
    
    -- 英文阴影
    local engShadow = wm:CreateControl(nil, shadowContainer, CT_LABEL)
    engShadow:SetFont("ZoFontGameBold")
    engShadow:SetText(engText)
    engShadow:SetColor(0, 0, 0, 1) -- 黑色
    engShadow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    engShadow:SetDimensions(180, 22)
    engShadow:SetAnchor(TOP, shadowContainer, TOP, 0, 0)
    
    -- 中文阴影
    local cnShadow = wm:CreateControl(nil, shadowContainer, CT_LABEL)
    cnShadow:SetFont("ZoFontGame")
    cnShadow:SetText(cnText)
    cnShadow:SetColor(0, 0, 0, 1) -- 黑色
    cnShadow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cnShadow:SetDimensions(180, 20)
    cnShadow:SetAnchor(TOP, engShadow, BOTTOM, 0, -2)
    
    -- 创建主容器（顶层，原始位置）
    local container = wm:CreateControl(nil, ZO_WorldMapContainer, CT_CONTROL)
    container:SetDimensions(180, 50)
    container:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, x, y)
    
    -- 英文标签（上方，加粗）
    local engLabel = wm:CreateControl(nil, container, CT_LABEL)
    engLabel:SetFont("ZoFontGameBold")
    engLabel:SetText(engText)
    engLabel:SetColor(0.2, 1, 0, 1) -- 绿色
    engLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    engLabel:SetDimensions(180, 22)
    engLabel:SetAnchor(TOP, container, TOP, 0, 0)
    
    -- 中文标签（下方，位于英文下方）
    local cnLabel = wm:CreateControl(nil, container, CT_LABEL)
    cnLabel:SetFont("ZoFontGame")
    cnLabel:SetText(cnText)
    cnLabel:SetColor(0.6, 0.9, 0.6, 1) -- 浅绿色
    cnLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    cnLabel:SetDimensions(180, 20)
    cnLabel:SetAnchor(TOP, engLabel, BOTTOM, 0, -2)
    
    -- 设置层级，确保主容器在阴影容器之上
    container:SetDrawLayer(DL_OVERLAY)
    shadowContainer:SetDrawLayer(DL_BACKGROUND)
    container:SetDrawLevel(2)
    shadowContainer:SetDrawLevel(1)
    
    return {
        container = container,
        shadowContainer = shadowContainer,
        engLabel = engLabel,
        cnLabel = cnLabel,
        engShadow = engShadow,
        cnShadow = cnShadow
    }
end

-- Function to update and reposition labels correctly
local function UpdateLabels()
    -- 隐藏现有标签
    for _, labelPair in pairs(labels) do
        if labelPair.container then
            labelPair.container:SetHidden(true)
        end
        if labelPair.shadowContainer then
            labelPair.shadowContainer:SetHidden(true)
        end
    end

    -- Show labels only if the player is on the main Cyrodiil map
    if not IsPlayerInCyrodiilMainMap() then return end

    -- Ensure the map container exists before getting its dimensions
    if not ZO_WorldMapContainer or not ZO_WorldMapContainer.GetDimensions then
        d("❌ ERROR: ZO_WorldMapContainer is not ready!")
        return
    end

    -- Get current map dimensions
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()

    -- Ensure map dimensions are valid
    if not mapWidth or not mapHeight or mapWidth == 0 or mapHeight == 0 then
        d("❌ ERROR: Map dimensions are invalid!")
        return
    end

    for _, keep in ipairs(CyrodiilMapLabelsData) do
        local xPos = keep.x * mapWidth
        local yPos = keep.y * mapHeight

        -- Create bilingual labels if they don't already exist
        if not labels[keep.name] then
            labels[keep.name] = CreateBilingualLabel(keep.name, keep.cnName or keep.name, xPos, yPos)
        else
            -- Update positions if labels already exist
            labels[keep.name].container:ClearAnchors()
            labels[keep.name].container:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos, yPos)
            
            labels[keep.name].shadowContainer:ClearAnchors()
            labels[keep.name].shadowContainer:SetAnchor(CENTER, ZO_WorldMapContainer, TOPLEFT, xPos + 1, yPos + 1)
        end

        -- Show the labels
        labels[keep.name].container:SetHidden(false)
        labels[keep.name].shadowContainer:SetHidden(false)
    end
end

ZO_WorldMapContainer:SetHandler("OnRectChanged", UpdateLabels)

-- Refresh labels when the player moves to a new zone
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED, UpdateLabels)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SCREEN_RESIZED, UpdateLabels)

-- Initialize the add-on
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == ADDON_NAME then
        zo_callLater(function()
            UpdateLabels()
        end, 500) -- Wait 0.5 seconds to ensure the map is ready
    end
end)