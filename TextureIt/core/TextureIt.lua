-- *******************************************************
-- Circonian's TextureIt
-- Originally by Circonian
-- Previous 2018-01 by Baertram
-- Updates  2019-08; 2020-01; 2020-08 by IceHeart0108
-- 2020-11 (0.9.2020.1103) by Baertram (fix TextureIt -> ZO_Object instead of {})


-- === TO-DOs =============================================

-- *******************************************************
-- LIBRARIES & local references
local libLAM  = LibAddonMenu2

-- *******************************************************
-- *****  GLOBAL namespace elements
--TextureIt = {}
TextureIt = ZO_Object:New()
TextureIt.UI = {}
TextureIt.SaveVars = {}
TextureIt.DefaultVars = {
    version = 20200106,  -- Do NOT change unless the structure of the Vars does change too. This is NOT the same number as the overall addon version
    InfoMessages = false,
    UseTextureFileDimensions = true,
    ShowToolTips = true,
    StartHidden = false,
    MaxSearchResults = 250,
}
TextureIt.Textures = {}
TextureIt.Backgrounds = {
[1]= {"Hidden", true, ""},
[2]= {"Black", false, "/art/fx/texture/blacksquare.dds"},
[3]= {"White", false, "/art/fx/texture/whitesquare.dds"},
[4]= {"Gray", false, "/art/fx/texture/graysquare.dds"},
[5]= {"Red", false, "/art/fx/texture/modelfxtextures/redsquarefullalpha.dds"},
}
TextureIt.SettingsMenu = {
    lamPanel = {},
    lamTable = {}
}

-- *******************************************************
-- Important Local References
local ADDON_NAME        = "TextureIt"
local API_VERSION       = "101050"                              --Last changed texture paths for this API version
local VERSION_CODE      = "2026041300" .. "-" .. API_VERSION      --Last changed texture paths at this date

-- Some constants
local colorRed          = "|cFF0000"    -- Red
--local colorDrkOrange    = "|cFFA500"    -- Dark Orange
local colorTeal         = "|c00FFFF"    -- Addon Name color
--local colorYellow       = "|cFFFF00"    -- yellow
local colorWhite        = "|cFFFFFF"

-- *******************************************************
-- Other variables
local SearchCounter     = 0   --Current number of search matches; Defined at module level as it's used across 2 different functions


-- *******************************************************
-- Utilities, Menu Settings & SaveVars

-- Simple overload of function d to take into account messages var.
local function dd(msg)
	if not TextureIt.SaveVars.InfoMessages then return end
	d("[TextureIt]: "..msg)
end

-- Setup Settings Menu
local function SettingsInit()
    local lamPanel = {
        type = "panel",
        name = "TextureIt",
        displayName = string.format("|cFF0000%s|r %s", "Circonian's ", "TextureIt")  ,
        author = colorTeal.."Circonian, Baertram, IceHeart0108"..colorWhite ,
        version = colorTeal..VERSION_CODE ,
        slashCommand = "/texit-menu",
        registerForRefresh = true,
        registerForDefaults = true,
      }
    local lamOptions = {
        -- Option: Debug messages
        [1] = {
            type = "checkbox",
            name    = TEXTUREIT_SETT_DEBUG_MSGS,
            tooltip = TEXTUREIT_SETT_DEBUG_MSGS_TTIP,
            default = TextureIt.DefaultVars.InfoMessages ,
            getFunc = function() return TextureIt.SaveVars.InfoMessages  end,
            setFunc = function(value) TextureIt.SaveVars.InfoMessages = value end,
            width = "full",
        },
        -- Option: Tooltips
        [2] = {
            type = "checkbox",
            name    = TEXTUREIT_SETT_TOOLTIPS,
            tooltip = TEXTUREIT_SETT_TOOLTIPS_TTIP,
            default = TextureIt.DefaultVars.ShowToolTips ,
            getFunc = function() return TextureIt.SaveVars.ShowToolTips  end,
            setFunc = function(value)TextureIt.SaveVars.ShowToolTips = value end,
            width = "full",
        },
        -- Option: Show/Hide Window on Load
        [3] = {
            type = "checkbox",
            name    = TEXTUREIT_SETT_START_HIDDEN,
            tooltip = TEXTUREIT_SETT_START_HIDDEN_TTIP,
            default = TextureIt.DefaultVars.StartHidden ,
            getFunc = function() return TextureIt.SaveVars.StartHidden  end,
            setFunc = function(value)TextureIt.SaveVars.StartHidden = value end,
            width = "full",
            warning = "Activated only after UI first load / reload.",
        },
        [4] = {
            type = "slider",
            name = TEXTUREIT_SETT_MAX_SEARCH_RESULTS,
            tooltip = TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP,
            min = 10,
            max = 500,  -- This should really not be set higher than 500, otherwise it will start affecting performance
            step = 1,
            getFunc = function() return TextureIt.SaveVars.MaxSearchResults  end,
            setFunc = function(value)TextureIt.SaveVars.MaxSearchResults = value end,
            width = "full",
            default = TextureIt.DefaultVars.MaxSearchResults
        },
        [5] = {
            type = "header",
            name = TEXTUREIT_SETT_SLASHCOMM_TITLE,
            width = "full",	--or "half" (optional)
        },
        [6] = {
            type = "description",
            text = TEXTUREIT_SETT_SLASHCOMM_DESC,
            width = "full",	--or "half" (optional)
        },
    }
    TextureIt.SettingsMenu.lamPanel = libLAM:RegisterAddonPanel("TextureIt_Settings", lamPanel)
    TextureIt.SettingsMenu.lamTable = libLAM:RegisterOptionControls("TextureIt_Settings", lamOptions)
end

-- *******************************************************
-- ***** Texture Tables Init and handling - 'Core' functions
-- *******************************************************

-- Iterate a path  and add the subtable or path items
local function AddPathToStructureTable(tableNode, parsePath, fullPath, useName)
    local subNodeKey = ''
    local miniName = ''
    local i,j = string.find(parsePath ,"[/_]")  --'main' Header (H) defined by '/'  ; 'sub' (S) header defined by '_' :for Icons and other items with large lists
    if i then  -- found a subPath  (path defined by '/' : the 'regular' paths
        local typeFound = string.sub(parsePath,i,j)
        if    (typeFound == "/")
            then  subNodeKey = "H."..string.sub(parsePath,1,i-1)  -- regular path, using '/' 
            elseif typeFound == "_" then                                        -- a 'miniPath' within the filename itself. using '_'
                subNodeKey = "M."..string.sub(parsePath,1,i-1)
                if  (useName == nil or useName == '') then miniName = parsePath else miniName = useName end -- 1st time we find '_', keep the full miniName
        end
        local subPath = string.sub(parsePath,j+1,-1)
        if tableNode[subNodeKey] then  -- this subNode already exists, add it there
            AddPathToStructureTable(tableNode[subNodeKey], subPath, fullPath, miniName )
        else  -- create a new Header subNode
            tableNode[subNodeKey] = {}
            AddPathToStructureTable(tableNode[subNodeKey], subPath, fullPath, miniName )
        end
    else
        local name
        if (useName == nil or useName == '') then name = parsePath else name = useName end
        local x,_ = string.find(name,"%.dds")
        name = string.sub(name,1,x-1)
        tableNode[name] = fullPath
    end
end
--Generate the Structured Textures Table from the simple paths
local function BuildStructureTable()
    local loadPathsT = TextureIt.LoadPaths
    local structT = TextureIt.Textures
    local c =0
    local startTime =  GetGameTimeMilliseconds()
    for _,v in pairs(loadPathsT) do
        c = c+1
        AddPathToStructureTable(structT,string.sub(v,2,-1),v) -- strip the root "/" for the subPath (2nd parm)
    end
    local endTime =  GetGameTimeMilliseconds()
    dd(string.format("BuildStructuredTable: Completed [ %s ] Textures in [ %s ] ms.", c, (endTime - startTime)) )
end

-- Copies and sorts the textures into a numerical sub table ; ('H' and 'M' still sort ok)
local function SortTreeTable(tTable)
    local sortedTable = {}
    local sortedHeaders ={}
    local sortedEntries ={}
-- sort Headers
    for key, value in pairs(tTable) do
        if type(tTable[key]) == "table" then table.insert(sortedHeaders, {key, value}) end
    end
    table.sort(sortedHeaders,function(val1, val2) return val1[1] < val2[1] end)
-- sort Entries
    for key, value in pairs(tTable) do
        if type(tTable[key]) == "string" then table.insert(sortedEntries, {key,value}) end
    end
    table.sort(sortedEntries,function(val1, val2) return val1[1] < val2[1] end)
--Add Headers
    for k=1, #sortedHeaders do
        table.insert(sortedTable, {sortedHeaders[k][1],sortedHeaders[k][2]})
    end
--Add Entries
    for k=1, #sortedEntries do
        table.insert(sortedTable, {sortedEntries[k][1],sortedEntries[k][2]})
    end
    return sortedTable
end
-- Traverse and count total textures in tree, including subtables
local function CountChildren(textureTable)
    local totalCount = 0
    
    for _,v in pairs(textureTable) do
        if type(v) == "table" then
            totalCount = totalCount + CountChildren(v)
        else
            totalCount = totalCount + 1
        end
    end
    return totalCount
end
-- Execute the actual search and return the results
local function GetSearchResults(sourceTable, destTable, text)
    local savedTextures = sourceTable
    local Max = TextureIt.SaveVars.MaxSearchResults
	
    for key,value in pairs(savedTextures) do
       if  SearchCounter >= Max  then break end
       if type(value) == "table" then
            GetSearchResults(value, destTable, text)
        elseif type(value) == "string" then
            if string.lower(key):find(text) then
                table.insert(destTable, {["text"] = key, ["texturePath"] = value})
                SearchCounter = SearchCounter + 1
            end
       end
    end
end
-- Setup the Search elements and post the retrieved results
function TextureIt.TableSearch(text)
    local startTime =  GetGameTimeMilliseconds()
    local sourceTable = TextureIt.Textures   --TEXTUREIT_TEXTURES
    SearchCounter = 0
    local searchResults = {}
    
    GetSearchResults(sourceTable, searchResults, text)
    TEXTUREIT.navigationTree:Reset()
    if SearchCounter ~= 0 then
        local function tableSort(tableA, tableB)
            return tableA.text < tableB.text
        end
        table.sort(searchResults, tableSort)
        for _,value in pairs(searchResults) do
            TEXTUREIT.navigationTree:AddNode("TextureIt_treeNavEntry", {["text"]=value.text, ["texturePath"]=value.texturePath}, nil, SOUNDS.SKILL_LINE_SELECT)
        end
        TEXTUREIT.navigationTree:Commit()
        if SearchCounter == TextureIt.SaveVars.MaxSearchResults
        --TODO fix text
            then TEXTUREIT.UI.lblResults:SetText(SearchCounter.." Textures found. (Max. reached)")
            else TEXTUREIT.UI.lblResults:SetText(SearchCounter.." Textures found.")
        end
    else
        TEXTUREIT.UI.lblResults:SetText("Not Found (0 Results)")
    end
    local endTime =  GetGameTimeMilliseconds()
    dd("TableSearch: Complete in ["..(endTime - startTime).."] ms.")
end

-- *******************************************************
-- ***** TextureIt 'Object' functions *****

-- Create the meta TEXTUREIT Object
function TextureIt:New()
    self.origWidth  = 0      -- Original Height of the currently loaded texture
    self.origHeight = 0     -- Original Height of the currently loaded texture
    -- The 'Tree' window widget
    self.UI.wdgTree         = TextureIt_wdgTree
    self.UI.eboxSearch      = TextureIt_wdgTree_eboxSearch
    self.UI.lblResults      = TextureIt_wdgTree_lblResults
    --The 'texture view' window widget
    self.UI.wdgView          = TextureIt_wdgView
    self.UI.wdgViewHdr       = TextureIt_wdgView_wdgHeader
    self.UI.lblOrigSize      = TextureIt_wdgView_wdgHeader_lblOrigSize
    self.UI.lblCurrSize      = TextureIt_wdgView_wdgHeader_lblCurrSize
    self.UI.lblVPortSize     = TextureIt_wdgView_wdgHeader_lblViewPortSize
    self.UI.cmboxVPBkgrounds = TextureIt_wdgView_wdgHeader_cmboxVPortBackgrounds
    -- and the actual 'viewport' inside the 'view'
    self.UI.ViewPort      = TextureIt_wdgView_wdgViewPort
    self.UI.TextureItem   = TextureIt_wdgView_wdgViewPort_txuTextureItem
    -- The 'animate' popup window
    self.UI.wdgAnimate    = TextureIt_wdgAnimate
    return self
end
-- Initialize everything else within the meta TEXTUREIT Object
function TextureIt:Initialize()
    SettingsInit()
    BuildStructureTable()
    self.UI.cmboxVPortBackgrounds_Setup()
    self.UI.eboxSearch.data = { tooltipText = GetString(TEXTUREIT_TREE_EBOX_SEARCH_TTIP) }
    --20200107 Baertram: Removed GetString texts as they were set directly into the XML controls attribute text="TEXTUREIT_TREE_BTN_TOOLTIP_TOGGLE"
    self.UI.wdgTree:SetHidden(self.SaveVars.StartHidden)
    self.UI.wdgView:SetHidden(self.SaveVars.StartHidden)

end
-- Create the Tree based on the input lists and add them to the TEXTUREIT Object
function TextureIt:CreateTree()
    self.navigationTree = ZO_Tree:New(TextureIt_wdgTree_scrTreeBaseScrollChild, 25, 0, 1000)
    -- Textures for Larger Path Header
    local txuTreeHdr_Open       = "EsoUI/Art/Buttons/tree_open_up.dds"
    local txuTreeHdr_Closed     = "EsoUI/Art/Buttons/tree_closed_up.dds"
    local txuTreeHdr_OverOpen   = "EsoUI/Art/Buttons/tree_open_over.dds"
    local txuTreeHdr_OverClosed = "EsoUI/Art/Buttons/tree_closed_over.dds"
    -- Textures for 'mini' path Header
    local txuTreeSubHdr_Open       = "esoui/art/buttons/minus_up.dds"
    local txuTreeSubHdr_Closed     = "esoui/art/buttons/plus_up.dds"
    local txuTreeSubHdr_OverOpen   = "esoui/art/buttons/minus_over.dds"
    local txuTreeSubHdr_OverClosed = "esoui/art/buttons/plus_over.dds"
    
    -- Setup the template and call for the 'major' Header branches (split at path slash)
    local function TreeHeaderSetup(_, control, data, open)
        control.text:SetText(data.text)
        control.icon:SetTexture(open and txuTreeHdr_Open or txuTreeHdr_Closed)
        control.iconHighlight:SetTexture(open and txuTreeHdr_OverOpen or txuTreeHdr_OverClosed)
        control.text:SetSelected(open)
    end
    self.navigationTree:AddTemplate("TextureIt_treeNavHeader", TreeHeaderSetup, nil, nil, nil, 0)

    -- Setup the template and call for the 'minor' SubHeader branches (split at filename underscore)
    local function TreeSubHeaderSetup(_, control, data, open)
        control.text:SetText(data.text)
        control.icon:SetTexture(open and txuTreeSubHdr_Open or txuTreeSubHdr_Closed)
        control.iconHighlight:SetTexture(open and txuTreeSubHdr_OverOpen or txuTreeSubHdr_OverClosed)
        control.text:SetSelected(open)
    end
    self.navigationTree:AddTemplate("TextureIt_treeNavSubHeader", TreeSubHeaderSetup, nil, nil, nil, 0)
    
    local function TreeEntrySetup(_, control, data, _)
        control:SetText(data.text)
        control:SetSelected(false)
    end

    local function TreeEntryOnSelected(control, data, selected)
        -- full params: TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        TextureIt.UI.wdgAnimate_Stop()
        control:SetSelected(selected)

        local entryIcon = GetControl(control, "_txuTaggedIcon")
        entryIcon.selected = selected
        if selected then
            -- set the marker for the currently selected item
            entryIcon:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
            entryIcon:SetAlpha(1.00)
            entryIcon:SetHidden(false)
            TEXTUREIT.UI.eboxSearch:SetText(data.texturePath)
            TEXTUREIT.UI.eboxSearch:TakeFocus()
            TEXTUREIT.UI.eboxSearch:SelectAll()
            TEXTUREIT.UI.TextureItem:SetTexture(data.texturePath)  -- Set the selected texture to the Viewport
            -- The texture gets changed too slow for the Reanchor function to get the correct file dimensions, so must delay the call to it
            -- changing this to ONTextureLoaded so we ensure its truly loaded?
            --zo_callLater(function() TextureIt.UI.wdgView_Reanchor() end, 100)
        else
            entryIcon:SetHidden(true)
            TEXTUREIT.UI.TextureItem:SetTexture(nil)
        end
    end
    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end
    self.navigationTree:AddTemplate("TextureIt_treeNavEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)
    
    -- true means only one can be open at a time AND you can't click to close it.
    -- You have to open another to get it to close
    --self.navigationTree:SetExclusive(true)
    self.navigationTree:SetExclusive(false)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end
-- Process a set or subset/subtable of nodes add them to the TEXTUREIT Object  Table
function TextureIt:AddTableNodes(textureTable, parentNode)
    --local startTime =  GetGameTimeMilliseconds()
    local sortedTable = SortTreeTable(textureTable)
    -- Count of textures for THIS table we're on
    local totalTextureCount = 0
    local localCount = 0

    for tableIndex=1, #sortedTable do
        --if totalTextureCount > 1500 then return localCount end
       if type(sortedTable[tableIndex][2]) == "table" then
            local childCount = CountChildren(sortedTable[tableIndex][2])
            local hdrType = string.sub(sortedTable[tableIndex][1],1,1)
            if  hdrType == "H"
                then
                    self.navigationTree:AddNode("TextureIt_treeNavHeader", {["text"]=string.sub(sortedTable[tableIndex][1],3).." ("..childCount..")", ["nodeTable"]=sortedTable[tableIndex][2]}, parentNode)
                elseif hdrType =="M" then
                    self.navigationTree:AddNode("TextureIt_treeNavSubHeader", {["text"]=string.sub(sortedTable[tableIndex][1],3).." ("..childCount..")", ["nodeTable"]=sortedTable[tableIndex][2]}, parentNode)
                else dd("Header type does not match ["..hdrType.."]")
            end
        else
            self.navigationTree:AddNode("TextureIt_treeNavEntry", {["text"]=sortedTable[tableIndex][1], ["texturePath"]=sortedTable[tableIndex][2]}, parentNode, SOUNDS.SKILL_LINE_SELECT)
            -- One texture found, add it to the counts
            localCount = localCount + 1
            totalTextureCount = totalTextureCount + 1
       end
    end
    --local endTime =  GetGameTimeMilliseconds()
    return localCount
end
-- Prepare the overall tree and call and populate the add nodes subsets
function TextureIt:PopulateTree()
    local startTime =  GetGameTimeMilliseconds()
    
    TEXTUREIT.navigationTree:Reset()
    local textures = TextureIt.Textures
    
    self:AddTableNodes(textures, nil)
    self.navigationTree:Commit()
    --self.navigationTree:RefreshVisible()
    
    local endTime =  GetGameTimeMilliseconds()
    dd("PopulateTree: Completed adding Nodes in ["..(endTime - startTime).."] ms.")
    
    -- Update the windows heading label with the texture count:
    local resultsLabel = self.UI.wdgTree:GetNamedChild("_lblResults")
    local totalTextureCount = CountChildren(TextureIt.Textures)
    if totalTextureCount > 0 then resultsLabel:SetText(totalTextureCount.." " ..GetString(TEXTUREIT_TREE_LBL_FOUND))
        else resultsLabel:SetText(".. Not found ..")
    end
end
-- Reset tree list and reinitialize elements
function TextureIt:ResetTree()
    TextureIt.UI.wdgAnimate_Stop()
    self.UI.eboxSearch:SetText(GetString(TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE))
    self.UI.TextureItem:SetTexture("/TextureIt/assets/Disclaimer.dds")
    self:PopulateTree()
    self.UI.wdgView_Reanchor()
end

-- *******************************************************
-- ***** XML/UI Functions: User Interface (UI) functions: Control handlers and UI refresh
-- *******************************************************

-- Change/setup the Backgrounds : Combo box handler
function TextureIt.UI.cmboxVPortBackgrounds_Setup()
    local cmbox = ZO_ComboBox_ObjectFromContainer(TextureIt.UI.cmboxVPBkgrounds)

    local function OnBkComboChanged(_)
        local sel = cmbox:GetSelectedItemData()
        local VPortBg = TEXTUREIT.UI.ViewPort:GetNamedChild("_bckViewPort")
        VPortBg:SetHidden(TextureIt.Backgrounds[sel.index][2])
        VPortBg:SetCenterTexture(TextureIt.Backgrounds[sel.index][3])
    end

    local initentry
    for i,_ in ipairs(TextureIt.Backgrounds) do
        local entry = ZO_ComboBox:CreateItemEntry(GetString("TEXTUREIT_VIEW_CMBX_BKGROUND_", i), OnBkComboChanged)
        entry.index = i
        if i ==2 then initentry = entry end
        cmbox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
    cmbox:UpdateItems()
    cmbox:SelectItem(initentry)
    
end
-- *** Tree entry handlers

-- Expand / compress the nodes for a particular Header selected on Mouse Up from an/each Header: This function is 'reference-cloned' for each 'Header' element in the tree
function TextureIt.UI.treeNavHeaderAndSubHeader_OnInitialized(self)
    self.icon = self:GetNamedChild("_txuIcon")
    self.iconHighlight = self.icon:GetNamedChild("_txuHighlight")
    self.text = self:GetNamedChild("_lblText")

    self.OnMouseEnter = TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseEnter
    self.OnMouseExit = TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseExit
    self.OnMouseUp = TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseUp
end
-- Set the spinner arrow icon highlighted on mouse enter to an/each header: This function is 'reference-cloned' for each 'Header' element in the tree
function TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseEnter(control)
    ZO_SelectableLabel_OnMouseEnter(control.text)
    control.iconHighlight:SetHidden(false)
end
-- Set the spinner arrow icon back to normal on mouse exit from an/each Header: This function is 'reference-cloned' for each 'Header' element in the tree
function TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseExit(control)
    ZO_SelectableLabel_OnMouseExit(control.text)
    control.iconHighlight:SetHidden(true)
end
-- Expand / compress the nodes for a particular Header selected on Mouse Up from an/each Header: This function is 'reference-cloned' for each 'Header' element in the tree
function TextureIt.UI.treeNavHeaderAndSubHeader_OnMouseUp(control, upInside)
    if not upInside then return end
    local node = control.node
    if not node.open and not node.children then
        TEXTUREIT:AddTableNodes(node.data.nodeTable, node)
    end
    ZO_TreeHeader_OnMouseUp(control, upInside)
end
-- On click of a navigation (child) being selected: play sound and change texture
function TextureIt.UI.treeNavEntry_OnMouseUp(label, button, upInside)
    if not upInside then return end
    if button == 1 then
        if(upInside and label.node.tree.enabled) then
            -- Play the selected sound if not already selected
            if(not label.node.selected and label.node.selectSound) then
                PlaySound(label.node.selectSound)
            end
            --ZO_TreeEntry_OnMouseUp(label, upInside)
            label.node:GetTree():ToggleNode(label.node)
            label.node:GetTree():SelectNode(label.node)
        end
    end
end

-- Show the tooltip if hovering over one entry
function TextureIt.UI.treeNavEntry_OnMouseEnter(control)
   if not TextureIt.SaveVars.ShowToolTips then return end
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
    -- the Tree node info is hosted inside the control (control.node) then we can get ot the 'data' we provided before when it was created
    SetTooltipText(InformationTooltip, control.node.data["texturePath"])
end

-- *** UI Tree Main Window widget

-- Show tooltips (if enabled) when entering SearchBox
function TextureIt.UI.eboxSearch_OnMouseEnter(control)
    if not TextureIt.SaveVars.ShowToolTips then return end
    InitializeTooltip(InformationTooltip, control, LEFT, 0, -2, RIGHT)
    SetTooltipText(InformationTooltip, control.data.tooltipText)
end
-- Search a texture mask from the Search box OnEnter
function TextureIt.UI.eboxSearch_OnEnter(editBox)
    TextureIt.UI.wdgAnimate_Stop()
    local text = string.lower(editBox:GetText())
    if not (text and type(text)=="string" and text ~= "") then return end
    if string.match(text, ".dds$") then
        TEXTUREIT.UI.TextureItem:SetTexture(text)
        TextureIt.UI.wdgView_Reanchor()
    else
        TextureIt.TableSearch(text)
    end
end
--Reset the tree to full list
function TextureIt.UI.btnResetTree_OnMouseDown()
    TEXTUREIT:ResetTree()
end

-- Togggle hide/unhide the main tree view, the viewport and the Animate popup  (if toggling to hide)
function TextureIt.UI.wdgTree_Toggle()
    TEXTUREIT.UI.wdgTree:SetHidden(not TEXTUREIT.UI.wdgTree:IsHidden())
    TEXTUREIT.UI.wdgView:SetHidden(not TEXTUREIT.UI.wdgView:IsHidden())
    if (TEXTUREIT.UI.wdgView:IsHidden()) then
        TEXTUREIT.UI.wdgAnimate:SetHidden(true)
    end
end
-- show the Title tooltip (yeah, yeah.. separate tooltip always on.. gotta have a little self-promotion and all that ;)
function TextureIt.UI.lblTitle_OnMouseEnter(self)
    local text = "By ".. colorRed.."Circonian".."|r, " .. colorTeal.. "Baertram" .. "|r and " .. colorTeal .."IceHeart0108|r\nVersion: "  .. VERSION_CODE
    InitializeTooltip(InformationTooltip, self, BOTTOM,0,0,TOP)
    SetTooltipText(InformationTooltip, text)
end
-- *** UI Viewport Widget

-- Reanchors the texture when changed
function TextureIt.UI.txuTextureItem_OnTextureLoaded(control)
    --20200107 Baertram: Added nil check to suupress error upon loading textureIt UI
    --TODO Ice:  This solves the issue, but why would we  get this far without the TEXTUREIT Obj? feels like we may be loading twice: Check if we can trap this earlier or reroute the txu load on init
    if not TEXTUREIT then return end
    local x,y
    x,y = control:GetTextureFileDimensions()
    TEXTUREIT.origWidth = x
    TEXTUREIT.origHeight = y
    TextureIt.UI.wdgView_Reanchor()
end

-- Registers for updates on start of resize of Viewport widget, and updates the viewport size label
function TextureIt.UI.wdgView_OnResizeStart(_)
    EVENT_MANAGER:RegisterForUpdate("TextureIt_wdgView_Resize", 50,
        function()
            local txuWidth, txuHeight = TEXTUREIT.UI.TextureItem:GetDimensions()
            TEXTUREIT.UI.lblCurrSize:SetText("Current Size: "..zo_round(txuWidth).." x "..zo_round(txuHeight))
            local vpWidth, vpHeight = TEXTUREIT.UI.ViewPort:GetDimensions()
            TEXTUREIT.UI.lblVPortSize:SetText("Viewport Size: "..zo_round(vpWidth).." x "..zo_round(vpHeight))
        end)
 end
-- Unregister updates on stop of resize of Viewport widget
function TextureIt.UI.wdgView_OnResizeStop(_)
    EVENT_MANAGER:UnregisterForUpdate("TextureIt_wdgView_Resize")
 end
-- Toggles the actual size of the current texture, updates the curr size label and sets the texture
function TextureIt.UI.btnActualSize_Toggle()
    TextureIt.SaveVars.UseTextureFileDimensions = not TextureIt.SaveVars.UseTextureFileDimensions
    local chkboxOn = TEXTUREIT.UI.wdgViewHdr:GetNamedChild("_txuActualSizeChkboxOn")
    local chkboxOff = TEXTUREIT.UI.wdgViewHdr:GetNamedChild("_txuActualSizeChkboxOff")
    chkboxOn:ToggleHidden()
    chkboxOff:ToggleHidden()
    TextureIt.UI.wdgView_Reanchor()
end
-- Show tooltips for button 'A' (animate) in viewport
function TextureIt.UI.btnAnimate_OnMouseEnter(self)
    if not TextureIt.SaveVars.ShowToolTips then return end
    
    InitializeTooltip(InformationTooltip, self, LEFT, 25, 0, RIGHT)
    SetTooltipText(InformationTooltip, GetString(TEXTUREIT_VIEW_BTN_ANIMATE_TTIP))
end
-- Recalculates the texture size vs the viewport size and resets positionings as needed
function TextureIt.UI.wdgView_Reanchor()
    local txtItem = TEXTUREIT.UI.TextureItem
    local View    = TEXTUREIT.UI.wdgView
    local VPort   = TEXTUREIT.UI.ViewPort

    txtItem:ClearAnchors()
    if TextureIt.SaveVars.UseTextureFileDimensions then
        -- Some textures are extremely large. By re-anchoring this ensures the position & size of the window; the ViewHeader is Y=100
        View:ClearAnchors()
        View:SetAnchor(TOPLEFT, TEXTUREIT.UI.wdgTree, TOPRIGHT, 0, 0)
        View:SetDimensions(           (TEXTUREIT.origWidth > 600) and (TEXTUREIT.origWidth+20) or 600, (TEXTUREIT.origHeight > 400) and (TEXTUREIT.origHeight+120) or 400)
        View:SetDimensionConstraints( (TEXTUREIT.origWidth > 600) and (TEXTUREIT.origWidth+20) or 600, (TEXTUREIT.origHeight > 400) and (TEXTUREIT.origHeight+120) or 400)
        VPort:SetDimensions(          (TEXTUREIT.origWidth > 600) and (TEXTUREIT.origWidth+20) or 600, (TEXTUREIT.origHeight > 300) and (TEXTUREIT.origHeight+20) or 300)
        VPort:SetDimensionConstraints((TEXTUREIT.origWidth > 600) and (TEXTUREIT.origWidth+20) or 600, (TEXTUREIT.origHeight > 300) and (TEXTUREIT.origHeight+20) or 300)
        txtItem:SetAnchor(CENTER, bckVPort, CENTER, 0, 0)
        txtItem:SetDimensions(TEXTUREIT.origWidth, TEXTUREIT.origHeight)
    else
        View:SetDimensionConstraints(600, 400)
        VPort:SetDimensionConstraints(600,300)
        txtItem:SetAnchor(TOPLEFT, bckVPort, TOPLEFT, 25, 25)
        txtItem:SetAnchor(BOTTOMRIGHT, bckVPort, BOTTOMRIGHT, -25, -25)
    end
    local curWidth, curHeight = txtItem:GetDimensions()
    local vpWidth, vpHeight = VPort:GetDimensions()
    TEXTUREIT.UI.lblOrigSize:SetText(GetString(TEXTUREIT_VIEW_LBL_ORIG_SIZE) ..zo_round(TEXTUREIT.origWidth).." x "..zo_round(TEXTUREIT.origHeight))
    TEXTUREIT.UI.lblCurrSize:SetText(GetString(TEXTUREIT_VIEW_LBL_CURRENT_SIZE) ..zo_round(curWidth).. " x "..zo_round(curHeight))
    TEXTUREIT.UI.lblVPortSize:SetText(GetString(TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE)..zo_round(vpWidth)..  " x "..zo_round(vpHeight))
end

-- *** UI Animation Popup Widget
-- Toggle visibility for the Animation popup window widget
function TextureIt.UI.wdgAnimate_Toggle()
    TEXTUREIT.UI.wdgAnimate:SetHidden(not TEXTUREIT.UI.wdgAnimate:IsHidden())
end
-- Stop the current animation
function TextureIt.UI.wdgAnimate_Stop()
    local animation = TEXTUREIT.UI.TextureItem.animation
    local timeline  = TEXTUREIT.UI.TextureItem.timeline
    
    if not timeline or not animation then return end
    timeline:Stop()
    animation:SetImageData(1, 1)
    TextureIt_wdgAnimate_btnAnimateToggle:SetText("Animate")
end
-- Toggle the button ctl in the Animate popup and Start/Stop an animation
function TextureIt.UI.btnAnimate_Toggle(self)
    local numCellWide = self:GetParent():GetNamedChild("CellsWideEditBox"):GetText()
    local numCellHigh = self:GetParent():GetNamedChild("CellsHighEditBox"):GetText()
    local frameRate = self:GetParent():GetNamedChild("FrameRateEditBox"):GetText()
	
    numCellWide = tonumber(numCellWide)
    numCellHigh = tonumber(numCellHigh)
    frameRate = tonumber(frameRate)
    
    if type(numCellWide) ~= "number" or type(numCellHigh) ~= "number"
    or type(frameRate) ~= "number" then return end
    
    local animation = TEXTUREIT.UI.TextureItem.animation
    local timeline  = TEXTUREIT.UI.TextureItem.timeline
    
    if not animation then
        animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, TEXTUREIT.UI.TextureItem)
        TEXTUREIT.UI.TextureItem.animation = animation
        TEXTUREIT.UI.TextureItem.timeline = timeline
    end
    
    if timeline:IsPlaying() then
        TextureIt.UI.wdgAnimate_Stop()
    else
        animation:SetImageData(numCellWide, numCellHigh)
        animation:SetFramerate(frameRate)
        timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
        timeline:PlayFromStart()
        
         TextureIt_wdgAnimate_btnAnimateToggle:SetText("Stop")
    end
end

-- *** UI Common calls

-- Clear tooltip on mouse exit
function TextureIt.UI.Common_TooltipOff_OnMouseExit()
    ClearTooltip(InformationTooltip)
end

-- *******************************************************
-- ***** Add-On Setup

-- On Addon Loaded : Creates the TEXTUREIT object, initializes and populates tree 1st  level
local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    TEXTUREIT = TextureIt:New()
    TextureIt.SaveVars = ZO_SavedVars:NewAccountWide("TextureItSaveVars", TextureIt.DefaultVars.version, nil, TextureIt.DefaultVars)
    TEXTUREIT:Initialize()
    TEXTUREIT:CreateTree()
    TEXTUREIT:ResetTree()
    dd("Loaded and ready.")
end


-- *******************************************************
--  *** Register Events --
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- *** Slash Commands --
SLASH_COMMANDS["/textureit"]        = TextureIt.UI.wdgTree_Toggle
SLASH_COMMANDS["/texit"]            = TextureIt.UI.wdgTree_Toggle


