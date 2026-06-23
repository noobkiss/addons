-- ==========================================================================
-- SoundBoard: ESO Developer Sound Browser
-- Browse, search and play all in-game SOUNDS entries.
-- ==========================================================================
local SB = {}
SB.name    = "SoundBoard"
SB.version = "1.1.0"

---------------------------------------------------------------------------
-- Saved Variables
---------------------------------------------------------------------------
local defaults = {
    posX   = 200,
    posY   = 100,
    width  = 520,
    height = 600,
}

---------------------------------------------------------------------------
-- Layout Constants
---------------------------------------------------------------------------
local HEADER_H      = 36
local SEARCH_H      = 28
local ROW_H         = 22
local ROW_GAP       = 1
local PAD           = 10
local BTN_W         = 50
local FONT_HEADER   = "$(BOLD_FONT)|18|soft-shadow-thick"
local FONT_ROW      = "$(BOLD_FONT)|14|soft-shadow-thin"
local FONT_SEARCH   = "$(BOLD_FONT)|15|soft-shadow-thin"
local FONT_SMALL    = "ZoFontGameSmall"
local MAX_VISIBLE   = 200   -- max rows rendered at once (performance guard)

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------
local mainWindow    = nil
local scrollChild   = nil
local searchBox     = nil
local countLabel    = nil
local allSounds     = {}    -- sorted list of { key, soundId }
local visibleRows   = {}    -- currently created row controls
local currentFilter = ""
local sv            = nil
local originalVolume = nil  -- saved UI volume, restored on window close
local originalOtherVolumes = nil  -- saved other audio volumes, restored on close
local isMuted = false
local muteBtnRef = nil  -- reference for updating mute button appearance
local filteredSounds = {}    -- current filtered list of { key, soundId }
local currentPlayIndex = 0   -- last played index in filteredSounds
local nowPlayingLabel = nil  -- reference to "now playing" label in UI

---------------------------------------------------------------------------
-- Collect and sort all SOUNDS entries
---------------------------------------------------------------------------
local function CollectSounds()
    allSounds = {}
    if not SOUNDS then return end
    for key, soundId in pairs(SOUNDS) do
        if type(key) == "string" and type(soundId) == "string" then
            allSounds[#allSounds + 1] = { key = key, soundId = soundId }
        end
    end
    table.sort(allSounds, function(a, b) return a.key < b.key end)
end

---------------------------------------------------------------------------
-- Categorize a sound key (best-effort from naming convention)
---------------------------------------------------------------------------
local function GetCategory(key)
    local k = key:upper()
    if k:find("^GAMEPAD")       then return "Gamepad"      end
    if k:find("^DIALOG")        then return "Dialog"       end
    if k:find("WINDOW")         then return "Window"       end
    if k:find("CRAFTING") or k:find("SMITHING") or k:find("ALCHEMY")
        or k:find("ENCHANT") or k:find("PROVISION") or k:find("WOODWORK")
        or k:find("JEWELRY") then return "Crafting"      end
    if k:find("CHAMPION")       then return "Champion"     end
    if k:find("QUEST")          then return "Quest"        end
    if k:find("ABILITY") or k:find("COMBAT") or k:find("WEAPON")
        or k:find("SYNERGY") or k:find("ULTIMATE") then return "Combat" end
    if k:find("INVENTORY") or k:find("BACKPACK") or k:find("ITEM")
        or k:find("LOOT") then return "Inventory"    end
    if k:find("DUEL") or k:find("BATTLEGROUND") or k:find("ALLIANCE")
        or k:find("KEEP") or k:find("AVA") then return "PvP" end
    if k:find("MARKET") or k:find("CROWN") or k:find("STORE")
        or k:find("GIFT") then return "Store"        end
    if k:find("HOUSING") or k:find("FURNITURE") then return "Housing" end
    if k:find("TRIBUTE")        then return "Tribute"      end
    if k:find("ANTIQUIT") or k:find("SCRYING") then return "Antiquities" end
    if k:find("MAIL")           then return "Mail"         end
    if k:find("GUILD")          then return "Guild"        end
    if k:find("NOTIFICATION") or k:find("ALERT") then return "Notification" end
    if k:find("ACHIEVEMENT") or k:find("LEVEL") or k:find("SKILL_POINT")
        or k:find("SKILL_LINE") then return "Progression" end
    if k:find("CLICK") or k:find("SPINNER") or k:find("SLIDER")
        or k:find("CHECKBOX") or k:find("TAB") or k:find("TOGGLE")
        or k:find("COMBO") or k:find("EDIT") then return "UI Control" end
    return "Other"
end

---------------------------------------------------------------------------
-- Create a single sound row
---------------------------------------------------------------------------
local function CreateRow(parent, index, entry)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(parent:GetWidth(), ROW_H)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (index - 1) * (ROW_H + ROW_GAP))

    -- Alternating row background
    local bg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    if index % 2 == 0 then
        bg:SetCenterColor(0.15, 0.15, 0.15, 0.5)
    else
        bg:SetCenterColor(0.10, 0.10, 0.10, 0.3)
    end
    bg:SetEdgeColor(0, 0, 0, 0)

    -- Category tag
    local cat = GetCategory(entry.key)
    local catLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    catLabel:SetFont(FONT_SMALL)
    catLabel:SetDimensions(80, ROW_H)
    catLabel:SetAnchor(LEFT, row, LEFT, 4, 0)
    catLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    catLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    catLabel:SetColor(0.6, 0.6, 0.6, 1)
    catLabel:SetText(cat)

    -- Sound key name
    local nameLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    nameLabel:SetFont(FONT_ROW)
    nameLabel:SetDimensions(parent:GetWidth() - BTN_W - 90, ROW_H)
    nameLabel:SetAnchor(LEFT, catLabel, RIGHT, 4, 0)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(1, 0.84, 0, 1)
    nameLabel:SetText(entry.key)

    -- Play button (speaker icon)
    local playBtn = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    playBtn:SetFont(FONT_ROW)
    playBtn:SetDimensions(BTN_W, ROW_H)
    playBtn:SetAnchor(RIGHT, row, RIGHT, -4, 0)
    playBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    playBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    playBtn:SetColor(0.2, 0.8, 0.2, 1)
    playBtn:SetText("\226\150\182")  -- ▶ play triangle
    playBtn:SetMouseEnabled(true)

    playBtn:SetHandler("OnMouseEnter", function(self)
        self:SetColor(0.4, 1, 0.4, 1)
    end)
    playBtn:SetHandler("OnMouseExit", function(self)
        self:SetColor(0.2, 0.8, 0.2, 1)
    end)
    playBtn:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            currentPlayIndex = index
            PlaySound(entry.soundId)
            d("|cFFD700[SoundBoard]|r \226\150\182 |c00BFFF" .. entry.key .. "|r  =  \"" .. entry.soundId .. "\"")
            if nowPlayingLabel then nowPlayingLabel:SetText(entry.key) end
        end
    end)

    -- Click on name: play sound AND show usage in chat
    nameLabel:SetMouseEnabled(true)
    nameLabel:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            currentPlayIndex = index
            PlaySound(entry.soundId)
            d("|cFFD700[SoundBoard]|r \226\150\182 |c00BFFF" .. entry.key .. "|r  =  \"" .. entry.soundId .. "\"")
            d("|c999999  Usage:|r PlaySound(SOUNDS." .. entry.key .. ")")
            if nowPlayingLabel then nowPlayingLabel:SetText(entry.key) end
        end
    end)
    nameLabel:SetHandler("OnMouseEnter", function(self)
        self:SetColor(1, 1, 1, 1)
    end)
    nameLabel:SetHandler("OnMouseExit", function(self)
        self:SetColor(1, 0.84, 0, 1)
    end)

    return row
end

---------------------------------------------------------------------------
-- Rebuild visible rows based on search filter
---------------------------------------------------------------------------
local function RebuildRows()
    -- Hide and detach existing rows
    for i = #visibleRows, 1, -1 do
        visibleRows[i]:SetHidden(true)
        visibleRows[i]:ClearAnchors()
        visibleRows[i]:SetDimensions(0, 0)
        visibleRows[i] = nil
    end
    visibleRows = {}
    filteredSounds = {}
    currentPlayIndex = 0

    if not scrollChild then return end

    local filter = currentFilter:upper()
    local index = 0

    for _, entry in ipairs(allSounds) do
        if filter == "" or entry.key:upper():find(filter, 1, true) or
           entry.soundId:upper():find(filter, 1, true) or
           GetCategory(entry.key):upper():find(filter, 1, true) then
            index = index + 1
            filteredSounds[#filteredSounds + 1] = entry
            if index <= MAX_VISIBLE then
                local row = CreateRow(scrollChild, index, entry)
                visibleRows[#visibleRows + 1] = row
            end
        end
    end

    -- Resize scroll child to fit content
    local totalH = index * (ROW_H + ROW_GAP)
    if index > MAX_VISIBLE then
        totalH = MAX_VISIBLE * (ROW_H + ROW_GAP)
    end
    scrollChild:SetHeight(math.max(totalH, 10))

    -- Update counter
    if countLabel then
        local shown = math.min(index, MAX_VISIBLE)
        local suffix = index > MAX_VISIBLE
            and string.format("  (showing %d/%d - refine search)", MAX_VISIBLE, index)
            or ""
        countLabel:SetText(string.format("%d / %d sounds%s", shown, #allSounds, suffix))
    end
end

---------------------------------------------------------------------------
-- Audio channels to mute/restore (everything except UI sounds)
---------------------------------------------------------------------------
local OTHER_AUDIO_SETTINGS = {
    AUDIO_SETTING_MUSIC_VOLUME,
    AUDIO_SETTING_AMBIENT_VOLUME,
    AUDIO_SETTING_SFX_VOLUME,
    AUDIO_SETTING_VO_VOLUME,
    AUDIO_SETTING_FOOTSTEPS_VOLUME,
}

---------------------------------------------------------------------------
-- Volume restore helper
---------------------------------------------------------------------------
local function RestoreVolume()
    if originalVolume then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, tostring(originalVolume))
        originalVolume = nil
    end
    -- Also restore muted channels
    if originalOtherVolumes then
        for setting, vol in pairs(originalOtherVolumes) do
            SetSetting(SETTING_TYPE_AUDIO, setting, tostring(vol))
        end
        originalOtherVolumes = nil
    end
    isMuted = false
    if muteBtnRef then
        muteBtnRef:SetText("MUTE")
        muteBtnRef:SetColor(0.7, 0.7, 0.7, 1)
    end
end

---------------------------------------------------------------------------
-- Play Again / Play Next (global for keybindings)
---------------------------------------------------------------------------
function SoundBoard_PlayAgain()
    if currentPlayIndex <= 0 or currentPlayIndex > #filteredSounds then
        d("|cFFD700[SoundBoard]|r No sound selected. Click a sound first.")
        return
    end
    local entry = filteredSounds[currentPlayIndex]
    PlaySound(entry.soundId)
    d("|cFFD700[SoundBoard]|r \226\150\182 |c00BFFF" .. entry.key .. "|r  (again)")
end

function SoundBoard_PlayNext()
    if #filteredSounds == 0 then
        d("|cFFD700[SoundBoard]|r No sounds in list.")
        return
    end
    currentPlayIndex = currentPlayIndex + 1
    if currentPlayIndex > #filteredSounds then currentPlayIndex = 1 end
    local entry = filteredSounds[currentPlayIndex]
    PlaySound(entry.soundId)
    d("|cFFD700[SoundBoard]|r \226\150\182 |c00BFFF" .. entry.key .. "|r  [" .. currentPlayIndex .. "/" .. #filteredSounds .. "]")
    if nowPlayingLabel then nowPlayingLabel:SetText(entry.key) end
end

---------------------------------------------------------------------------
-- Create the main window
---------------------------------------------------------------------------
local function CreateWindow()
    if mainWindow then return end

    local w = sv.width  or defaults.width
    local h = sv.height or defaults.height

    -- Main window
    mainWindow = WINDOW_MANAGER:CreateTopLevelWindow("SoundBoardWindow")
    mainWindow:SetDimensions(w, h)
    mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.posX, sv.posY)
    mainWindow:SetMovable(true)
    mainWindow:SetMouseEnabled(true)
    mainWindow:SetClampedToScreen(true)
    mainWindow:SetDimensionConstraints(400, 300, 800, 900)
    mainWindow:SetDrawLayer(DL_OVERLAY)
    mainWindow:SetDrawTier(DT_HIGH)
    mainWindow:SetHidden(true)

    mainWindow:SetHandler("OnMoveStop", function(self)
        sv.posX = self:GetLeft()
        sv.posY = self:GetTop()
    end)

    mainWindow:SetHandler("OnResizeStop", function(self)
        sv.width  = self:GetWidth()
        sv.height = self:GetHeight()
        RebuildRows()
    end)

    -- Background
    local bg = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_BACKDROP)
    bg:SetAnchorFill(mainWindow)
    bg:SetCenterColor(0.06, 0.06, 0.08, 0.92)
    bg:SetEdgeColor(0.4, 0.35, 0.1, 0.8)
    bg:SetEdgeTexture("", 2, 2, 2, 0)

    -- Header bar
    local header = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_CONTROL)
    header:SetDimensions(w, HEADER_H)
    header:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 0, 0)

    local headerBg = WINDOW_MANAGER:CreateControl(nil, header, CT_BACKDROP)
    headerBg:SetAnchorFill(header)
    headerBg:SetCenterColor(0.12, 0.10, 0.02, 0.9)
    headerBg:SetEdgeColor(0, 0, 0, 0)

    local title = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
    title:SetFont(FONT_HEADER)
    title:SetAnchor(LEFT, header, LEFT, PAD, 0)
    title:SetColor(1, 0.84, 0, 1)
    title:SetText("|cFFD700SoundBoard|r |c999999v" .. SB.version .. "|r")

    -- Close button
    local closeBtn = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
    closeBtn:SetFont(FONT_HEADER)
    closeBtn:SetDimensions(30, HEADER_H)
    closeBtn:SetAnchor(RIGHT, header, RIGHT, -PAD, 0)
    closeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    closeBtn:SetColor(1, 0.3, 0.3, 1)
    closeBtn:SetText("X")
    closeBtn:SetMouseEnabled(true)
    closeBtn:SetHandler("OnMouseUp", function(_, btn, upInside)
        if upInside and btn == MOUSE_BUTTON_INDEX_LEFT then
            mainWindow:SetHidden(true)
            RestoreVolume()
        end
    end)
    closeBtn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 0.5, 0.5, 1) end)
    closeBtn:SetHandler("OnMouseExit",  function(self) self:SetColor(1, 0.3, 0.3, 1) end)

    -- Sound count
    countLabel = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
    countLabel:SetFont(FONT_SMALL)
    countLabel:SetAnchor(RIGHT, closeBtn, LEFT, -PAD, 0)
    countLabel:SetColor(0.7, 0.7, 0.7, 1)
    countLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    countLabel:SetText("")

    -- Search box area
    local searchRow = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_CONTROL)
    searchRow:SetDimensions(w - PAD * 2, SEARCH_H + 4)
    searchRow:SetAnchor(TOPLEFT, header, BOTTOMLEFT, PAD, 6)

    local searchBg = WINDOW_MANAGER:CreateControl(nil, searchRow, CT_BACKDROP)
    searchBg:SetAnchorFill(searchRow)
    searchBg:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    searchBg:SetEdgeColor(0.3, 0.3, 0.3, 0.5)
    searchBg:SetEdgeTexture("", 1, 1, 1, 0)

    searchBox = WINDOW_MANAGER:CreateControlFromVirtual(
        "SoundBoardSearchBox", searchRow, "ZO_DefaultEditForBackdrop")
    searchBox:SetAnchor(TOPLEFT, searchRow, TOPLEFT, 6, 2)
    searchBox:SetAnchor(BOTTOMRIGHT, searchRow, BOTTOMRIGHT, -6, -2)
    searchBox:SetFont(FONT_SEARCH)
    searchBox:SetColor(1, 1, 1, 1)
    searchBox:SetMaxInputChars(100)

    -- Placeholder text
    local placeholder = WINDOW_MANAGER:CreateControl(nil, searchRow, CT_LABEL)
    placeholder:SetFont(FONT_SEARCH)
    placeholder:SetAnchor(LEFT, searchRow, LEFT, 10, 0)
    placeholder:SetColor(0.4, 0.4, 0.4, 1)
    placeholder:SetText("Search sounds... (name, category)")
    placeholder:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    searchBox:SetHandler("OnTextChanged", function(self)
        local text = self:GetText() or ""
        currentFilter = text
        placeholder:SetHidden(text ~= "")
        RebuildRows()
    end)

    searchBox:SetHandler("OnFocusGained", function()
        placeholder:SetHidden(true)
    end)
    searchBox:SetHandler("OnFocusLost", function(self)
        if (self:GetText() or "") == "" then
            placeholder:SetHidden(false)
        end
    end)

    -- Volume slider row
    local VOLUME_ROW_H = 24
    local MUTE_W = 60
    local volRow = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_CONTROL)
    volRow:SetDimensions(w - PAD * 2, VOLUME_ROW_H)
    volRow:SetAnchor(TOPLEFT, searchRow, BOTTOMLEFT, 0, 4)

    local volLabel = WINDOW_MANAGER:CreateControl(nil, volRow, CT_LABEL)
    volLabel:SetFont(FONT_SMALL)
    volLabel:SetDimensions(50, VOLUME_ROW_H)
    volLabel:SetAnchor(LEFT, volRow, LEFT, 0, 0)
    volLabel:SetColor(0.7, 0.7, 0.7, 1)
    volLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    volLabel:SetText("Vol:")

    -- Mute Others button (rightmost)
    local muteBtn = WINDOW_MANAGER:CreateControl(nil, volRow, CT_LABEL)
    muteBtn:SetFont(FONT_SMALL)
    muteBtn:SetDimensions(MUTE_W, VOLUME_ROW_H)
    muteBtn:SetAnchor(RIGHT, volRow, RIGHT, 0, 0)
    muteBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    muteBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    muteBtn:SetColor(0.7, 0.7, 0.7, 1)
    muteBtn:SetText("MUTE")
    muteBtn:SetMouseEnabled(true)
    muteBtnRef = muteBtn

    muteBtn:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if upInside and mouseButton == MOUSE_BUTTON_INDEX_LEFT then
            if isMuted then
                -- Unmute: restore other channels
                if originalOtherVolumes then
                    for setting, vol in pairs(originalOtherVolumes) do
                        SetSetting(SETTING_TYPE_AUDIO, setting, tostring(vol))
                    end
                    originalOtherVolumes = nil
                end
                isMuted = false
                self:SetText("MUTE")
                self:SetColor(0.7, 0.7, 0.7, 1)
                d("|cFFD700[SoundBoard]|r Audio restored.")
            else
                -- Mute: save current volumes, set to 0
                originalOtherVolumes = {}
                for _, setting in ipairs(OTHER_AUDIO_SETTINGS) do
                    originalOtherVolumes[setting] = tonumber(GetSetting(SETTING_TYPE_AUDIO, setting)) or 100
                    SetSetting(SETTING_TYPE_AUDIO, setting, "0")
                end
                isMuted = true
                self:SetText("MUTED")
                self:SetColor(1, 0.3, 0.3, 1)
                d("|cFFD700[SoundBoard]|r Other audio muted (Music, Ambient, SFX, VO, Footsteps).")
            end
        end
    end)
    muteBtn:SetHandler("OnMouseEnter", function(self)
        if isMuted then self:SetColor(1, 0.5, 0.5, 1)
        else self:SetColor(1, 1, 1, 1) end
    end)
    muteBtn:SetHandler("OnMouseExit", function(self)
        if isMuted then self:SetColor(1, 0.3, 0.3, 1)
        else self:SetColor(0.7, 0.7, 0.7, 1) end
    end)

    -- Volume value display (left of mute button)
    local volValue = WINDOW_MANAGER:CreateControl(nil, volRow, CT_LABEL)
    volValue:SetFont(FONT_SMALL)
    volValue:SetDimensions(40, VOLUME_ROW_H)
    volValue:SetAnchor(RIGHT, muteBtn, LEFT, -4, 0)
    volValue:SetColor(1, 0.84, 0, 1)
    volValue:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    volValue:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local volSlider = WINDOW_MANAGER:CreateControl("SoundBoardVolSlider", volRow, CT_SLIDER)
    volSlider:SetDimensions(volRow:GetWidth() - 100 - MUTE_W - 8, VOLUME_ROW_H)
    volSlider:SetAnchor(LEFT, volLabel, RIGHT, 4, 0)
    volSlider:SetMouseEnabled(true)
    volSlider:SetMinMax(0, 100)
    volSlider:SetOrientation(ORIENTATION_HORIZONTAL)
    volSlider:SetThumbTexture("EsoUI/Art/Miscellaneous/scrollbox_elevator.dds",
        "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds", nil, 16, 16)

    -- Slider background track
    local volSliderBg = WINDOW_MANAGER:CreateControl(nil, volSlider, CT_BACKDROP)
    volSliderBg:SetAnchor(TOPLEFT, volSlider, TOPLEFT, 0, 9)
    volSliderBg:SetAnchor(BOTTOMRIGHT, volSlider, BOTTOMRIGHT, 0, -9)
    volSliderBg:SetCenterColor(0.2, 0.2, 0.2, 0.8)
    volSliderBg:SetEdgeColor(0.4, 0.4, 0.4, 0.5)

    -- Read current UI volume
    local curVol = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)) or 75
    originalVolume = curVol
    volSlider:SetValue(curVol)
    volValue:SetText(tostring(math.floor(curVol)))

    volSlider:SetHandler("OnValueChanged", function(self, value)
        local vol = math.floor(value)
        volValue:SetText(tostring(vol))
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, tostring(vol))
    end)

    -- Navigation row (Play Again / Now Playing / Play Next)
    local NAV_ROW_H = 24
    local navRow = WINDOW_MANAGER:CreateControl(nil, mainWindow, CT_CONTROL)
    navRow:SetDimensions(w - PAD * 2, NAV_ROW_H)
    navRow:SetAnchor(TOPLEFT, volRow, BOTTOMLEFT, 0, 4)

    local navBg = WINDOW_MANAGER:CreateControl(nil, navRow, CT_BACKDROP)
    navBg:SetAnchorFill(navRow)
    navBg:SetCenterColor(0.08, 0.08, 0.08, 0.6)
    navBg:SetEdgeColor(0.3, 0.3, 0.3, 0.3)
    navBg:SetEdgeTexture("", 1, 1, 1, 0)

    local againBtn = WINDOW_MANAGER:CreateControl(nil, navRow, CT_LABEL)
    againBtn:SetFont(FONT_SMALL)
    againBtn:SetDimensions(70, NAV_ROW_H)
    againBtn:SetAnchor(LEFT, navRow, LEFT, 4, 0)
    againBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    againBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    againBtn:SetColor(0.7, 0.7, 0.7, 1)
    againBtn:SetText("\194\171 Again")
    againBtn:SetMouseEnabled(true)
    againBtn:SetHandler("OnMouseUp", function(_, btn, upInside)
        if upInside and btn == MOUSE_BUTTON_INDEX_LEFT then SoundBoard_PlayAgain() end
    end)
    againBtn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    againBtn:SetHandler("OnMouseExit", function(self) self:SetColor(0.7, 0.7, 0.7, 1) end)

    local nextBtn = WINDOW_MANAGER:CreateControl(nil, navRow, CT_LABEL)
    nextBtn:SetFont(FONT_SMALL)
    nextBtn:SetDimensions(70, NAV_ROW_H)
    nextBtn:SetAnchor(RIGHT, navRow, RIGHT, -4, 0)
    nextBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nextBtn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nextBtn:SetColor(0.7, 0.7, 0.7, 1)
    nextBtn:SetText("Next \194\187")
    nextBtn:SetMouseEnabled(true)
    nextBtn:SetHandler("OnMouseUp", function(_, btn, upInside)
        if upInside and btn == MOUSE_BUTTON_INDEX_LEFT then SoundBoard_PlayNext() end
    end)
    nextBtn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    nextBtn:SetHandler("OnMouseExit", function(self) self:SetColor(0.7, 0.7, 0.7, 1) end)

    nowPlayingLabel = WINDOW_MANAGER:CreateControl(nil, navRow, CT_LABEL)
    nowPlayingLabel:SetFont(FONT_SMALL)
    nowPlayingLabel:SetAnchor(LEFT, againBtn, RIGHT, 4, 0)
    nowPlayingLabel:SetAnchor(RIGHT, nextBtn, LEFT, -4, 0)
    nowPlayingLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nowPlayingLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nowPlayingLabel:SetColor(1, 0.84, 0, 1)
    nowPlayingLabel:SetText("")

    -- Scroll container (using ZO_ScrollContainer virtual template)
    local scrollOffset = HEADER_H + SEARCH_H + VOLUME_ROW_H + NAV_ROW_H + 28
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        "SoundBoardScroll", mainWindow, "ZO_ScrollContainer")
    scrollContainer:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, PAD, scrollOffset)
    scrollContainer:SetAnchor(BOTTOMRIGHT, mainWindow, BOTTOMRIGHT, -PAD, -PAD)

    scrollChild = scrollContainer:GetNamedChild("ScrollChild")
    scrollChild:SetWidth(scrollContainer:GetWidth() - 16)  -- leave space for scrollbar
end

---------------------------------------------------------------------------
-- Toggle window
---------------------------------------------------------------------------
local function ToggleWindow()
    if not mainWindow then
        CreateWindow()
        CollectSounds()
        RebuildRows()
    end

    local wasHidden = mainWindow:IsHidden()
    mainWindow:SetHidden(not wasHidden)

    if wasHidden then
        -- Opening: save current volume
        originalVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)) or 75
        if searchBox then searchBox:TakeFocus() end
    else
        -- Closing: restore original volume
        RestoreVolume()
    end
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/sb"] = function(args)
        local arg = string.lower(args or "")

        if arg == "play" then
            d("|cFFD700[SoundBoard]|r Usage: /sb play SOUND_KEY")
            d("|cFFD700[SoundBoard]|r Example: /sb play QUEST_COMPLETED")
        elseif arg:find("^play ") then
            local key = arg:match("^play%s+(.+)$")
            if key then
                key = key:upper()
                if SOUNDS[key] then
                    PlaySound(SOUNDS[key])
                    d("|cFFD700[SoundBoard]|r Playing: " .. key)
                else
                    d("|cFFD700[SoundBoard]|r Unknown sound: " .. key)
                    -- Fuzzy search
                    local matches = {}
                    for k, _ in pairs(SOUNDS) do
                        if k:upper():find(key, 1, true) then
                            matches[#matches + 1] = k
                        end
                    end
                    if #matches > 0 then
                        table.sort(matches)
                        d("|cFFD700[SoundBoard]|r Did you mean:")
                        for i = 1, math.min(5, #matches) do
                            d("  - " .. matches[i])
                        end
                    end
                end
            end
        elseif arg == "count" then
            local count = 0
            for _ in pairs(SOUNDS) do count = count + 1 end
            d("|cFFD700[SoundBoard]|r Total SOUNDS entries: " .. count)
        elseif arg == "list" then
            d("|cFFD700[SoundBoard]|r Use the GUI (/sb) to browse all sounds.")
            d("|cFFD700[SoundBoard]|r Or /sb play SOUND_KEY to play directly.")
        else
            ToggleWindow()
        end
    end
end

---------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------
local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= SB.name then return end
    EVENT_MANAGER:UnregisterForEvent(SB.name, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("SoundBoardSV", 1, GetWorldName(), defaults)

    -- Keybinding display names
    ZO_CreateStringId("SI_BINDING_NAME_SOUNDBOARD_PLAY_AGAIN", "Play Again")
    ZO_CreateStringId("SI_BINDING_NAME_SOUNDBOARD_PLAY_NEXT", "Play Next")

    RegisterSlash()

    d("|cFFD700[SoundBoard]|r v" .. SB.version .. " loaded. Type |cFFFF00/sb|r to open.")
end

EVENT_MANAGER:RegisterForEvent(SB.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
