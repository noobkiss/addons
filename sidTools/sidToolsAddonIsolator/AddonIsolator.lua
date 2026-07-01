local AddOnManager = GetAddOnManager()
local AddonIsolator = ZO_Object:Subclass()
local ADDON_NAME = "sidToolsAddonIsolator"

function AddonIsolator:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

local function FindAddonIndexByName(addonName)
    for index = 1, AddOnManager:GetNumAddOns() do
        local name = AddOnManager:GetAddOnInfo(index)
        if(addonName == name) then return index end
    end
end

local function IsAddonEnabled(index)
    local name, _, _, _, enabled = AddOnManager:GetAddOnInfo(index)
    return enabled, name
end

local function GetEnabledAddons()
    local enabledAddons = {}
    for index = 1, AddOnManager:GetNumAddOns() do
        local enabled, name = IsAddonEnabled(index)
        if(enabled) then
            enabledAddons[name] = enabled
        end
    end
    return enabledAddons
end

local function DisableAllAddons()
    local enabledAddons = {}
    for index = 1, AddOnManager:GetNumAddOns() do
        AddOnManager:SetAddOnEnabled(index, false)
    end
end

local function ActivateAddonAndDependencies(addonIndex)
    if(not IsAddonEnabled(addonIndex)) then
        AddOnManager:SetAddOnEnabled(addonIndex, true)
        for index = 1, AddOnManager:GetAddOnNumDependencies(addonIndex) do
            local name = AddOnManager:GetAddOnDependencyInfo(addonIndex, index)
            ActivateAddonAndDependencies(FindAddonIndexByName(name))
        end
    end
end

function AddonIsolator:Initialize(saveData)
    self.saveData = saveData
    self.ownIndex = FindAddonIndexByName(ADDON_NAME)
end

function AddonIsolator:IsolateAddon(addonName)
    local addonIndex = FindAddonIndexByName(addonName)
    if(addonIndex == nil) then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, "addon '" .. addonName .. "' not found")
        return
    end

    local saveData = self.saveData
    if(not saveData.isolationActive) then
        -- save our active addons
        saveData.enabledAddons = GetEnabledAddons()
    end

    DisableAllAddons()
    ActivateAddonAndDependencies(self.ownIndex)
    ActivateAddonAndDependencies(addonIndex)
    saveData.isolationActive = true

    ReloadUI()
end

function AddonIsolator:RestoreAddons()
    local saveData = self.saveData
    if(not saveData.isolationActive) then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, "addon isolation not active")
        return
    end

    local enabledAddons = saveData.enabledAddons
    for index = 1, AddOnManager:GetNumAddOns() do
        local name = AddOnManager:GetAddOnInfo(index)
        AddOnManager:SetAddOnEnabled(index, enabledAddons[name] or false)
    end

    saveData.isolationActive = false

    ReloadUI()
end

function AddonIsolator:GetInstalledAddonNames()
    local addons = {}
    for index = 1, AddOnManager:GetNumAddOns() do
        local name = AddOnManager:GetAddOnInfo(index)
        addons[#addons + 1] = name
    end
    return addons
end

function AddonIsolator:CreateSlashCommand(name)
    SLASH_COMMANDS[name] = function(args)
        local command, addonName = zo_strsplit(" ", args)
        if(command == "isolate") then
            self:IsolateAddon(addonName)
        elseif(command == "restore") then
            self:RestoreAddons()
        else
            df("sidTools not active. Only '%s isolate' and '%s restore' are available", name, name)
        end
    end
end

function AddonIsolator:InitializeSlashCommands(command)
    if(command) then
        local isolateCmd = command:RegisterSubCommand()
        isolateCmd:AddAlias("isolate")
        isolateCmd:SetCallback(function(addonName)
            self:IsolateAddon(addonName)
        end)
        isolateCmd:SetDescription("Isolate the specified addons")
        isolateCmd:SetAutoComplete(self:GetInstalledAddonNames())

        local restoreCmd = command:RegisterSubCommand()
        restoreCmd:AddAlias("restore")
        restoreCmd:SetCallback(function()
            self:RestoreAddons()
        end)
        restoreCmd:SetDescription("Restore the previous set of addons")
    else
        self:CreateSlashCommand("/st")
        self:CreateSlashCommand("/sidtools")
    end
end

local function OnAddonLoaded(callback)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        callback()
    end)
end

OnAddonLoaded(function()
    local defaultData = {
        isolationActive = false,
        enabledAddons = {}
    }

    local saveDataVariableName = ADDON_NAME .. "_SaveData"
    _G[saveDataVariableName] = _G[saveDataVariableName] or {}
    local saveData = _G[saveDataVariableName]

    local characterId = GetCurrentCharacterId()
    local characterSaveData = saveData[characterId] or ZO_DeepTableCopy(defaultData)
    saveData[characterId] = characterSaveData

    local isolator = AddonIsolator:New(characterSaveData)
    _G[ADDON_NAME] = isolator

    if(not IsAddonEnabled(FindAddonIndexByName("sidTools"))) then
        isolator:InitializeSlashCommands()
    end
end)
