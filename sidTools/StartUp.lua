local ADDON_NAME = "sidTools"
sidTools = {}

local nextEventHandleIndex = 1

local function RegisterForEvent(event, callback)
    local eventHandleName = ADDON_NAME .. nextEventHandleIndex
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    nextEventHandleIndex = nextEventHandleIndex + 1
    return eventHandleName
end
sidTools.RegisterForEvent = RegisterForEvent

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end
sidTools.UnregisterForEvent = UnregisterForEvent

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        callback()
        UnregisterForEvent(event, name)
    end)
end

OnAddonLoaded(function()
    local defaultData = {}

    local characterName = GetUnitName("player")
    sidTools_SaveData = sidTools_SaveData or {}
    local saveData = sidTools_SaveData[characterName] or ZO_DeepTableCopy(defaultData)
    sidTools_SaveData[characterName] = saveData

    ZO_CreateStringId("SI_BINDING_NAME_ST_RELOADUI", "Reload UI")
    ZO_CreateStringId("SI_BINDING_NAME_ST_LANG_EN", "Switch to English")
    ZO_CreateStringId("SI_BINDING_NAME_ST_LANG_DE", "Switch to German")
    ZO_CreateStringId("SI_BINDING_NAME_ST_LANG_FR", "Switch to French")
    ZO_CreateStringId("SI_BINDING_NAME_ST_TOGGLE_DEV_UI", "Toggle Idle Countdown")

    local mainWindow = sidToolBar
    local LSC = LibSlashCommander

    local command = LSC:Register({"/sidtools", "/st"}, function()
        mainWindow:SetHidden(not mainWindow:IsHidden())
    end, "sidTools")
    sidTools.mainCmd = command

    LSC:Register("/wme", function(text)
        StartChatInput(text, CHAT_CHANNEL_WHISPER, GetDisplayName("player"))
    end, "Set chat channel to whisper yourself")

    sidToolsAddonIsolator:InitializeSlashCommands(command)

    local eventsCmd = command:RegisterSubCommand()
    eventsCmd:AddAlias("events")
    eventsCmd:SetCallback(function(addonName)
        sidTools.InitializeEventViewer(saveData)
    end)
    eventsCmd:SetDescription("Toggle the sidTools event viewer")
    sidTools.eventsCmd = eventsCmd

    local unitsCmd = command:RegisterSubCommand()
    unitsCmd:AddAlias("units")
    unitsCmd:SetCallback(function(addonName)
        sidTools.InitializeUnitViewer(saveData)
    end)
    unitsCmd:SetDescription("Toggle the sidTools unit viewer")
    sidTools.unitsCmd = unitsCmd

    local itemsCmd = command:RegisterSubCommand()
    itemsCmd:AddAlias("items")
    itemsCmd:SetCallback(function(addonName)
        sidTools.InitializeItemViewer(saveData)
    end)
    itemsCmd:SetDescription("Toggle the sidTools item viewer")
    sidTools.itemsCmd = itemsCmd

    local abilitiesCmd = command:RegisterSubCommand()
    abilitiesCmd:AddAlias("abilities")
    abilitiesCmd:SetCallback(function(addonName)
        sidTools.InitializeAbilityViewer(saveData)
    end)
    abilitiesCmd:SetDescription("Toggle the sidTools ability viewer")
    sidTools.abilitiesCmd = abilitiesCmd

    local fontsCmd = command:RegisterSubCommand()
    fontsCmd:AddAlias("fonts")
    fontsCmd:SetCallback(function(addonName)
        sidTools.InitializeFontViewer(saveData)
    end)
    fontsCmd:SetDescription("Toggle the sidTools font viewer")
    sidTools.fontsCmd = fontsCmd

    local langCmd = LSC:Register("/lang", function(args)
        SetCVar("language.2", zo_strtrim(args))
    end, "Switch to the specified client language")
    sidTools.langCmd = langCmd

    local timer = sidTools.IdleTimer:New(mainWindow, saveData)
    mainWindow:SetHandler("OnShow", function()
        timer:Activate()
    end)
    mainWindow:SetHandler("OnHide", function()
        timer:Deactivate()
    end)

    sidTools.Toggle = function()
        mainWindow:SetHidden(not mainWindow:IsHidden())
    end

    local lastButton
    local function AddButton(label, callback)
        local button = CreateControlFromVirtual(("$(parent)%s"):format(label), mainWindow, "sidToolBarButtonTemplate")
        button:SetText(label)
        if(lastButton) then
            button:SetAnchor(LEFT, lastButton, RIGHT, 10, 0)
        else
            button:SetAnchor(LEFT, nil, LEFT, 200, 0)
        end
        button:SetHandler("OnClicked", callback)
        lastButton = button
        return button
    end

    AddButton("Events", eventsCmd.callback)
    AddButton("Units", unitsCmd.callback)
    AddButton("Items", itemsCmd.callback)
    AddButton("Abilities", abilitiesCmd.callback)
    AddButton("Fonts", fontsCmd.callback)
    AddButton("ReloadUI", function()
        ReloadUI()
    end)
    AddButton("English UI", function()
        langCmd("en")
    end)
    AddButton("German UI", function()
        langCmd("de")
    end)
    AddButton("French UI", function()
        langCmd("fr")
    end)
end)
