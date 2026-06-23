local LCCC = LibCodesCommonCode

if (LibCharacterKnowledge) then return end
local Public = { }
LibCharacterKnowledge = Public


--------------------------------------------------------------------------------
-- Internal Components
--------------------------------------------------------------------------------

local Internal = {
	name = "LibCharacterKnowledge",

	CATEGORY_RECIPE = "recipes",
	CATEGORY_PLAN = "plans",
	CATEGORY_MOTIF = "motifs",
	CATEGORY_SCRIBING = "sc",
	CATEGORY_RESEARCH = "rt",
	CATEGORY_NONE = false,
	CATEGORY_INVALID = nil,

	SCRIBE_GRIMOIRE = "grimoires",
	SCRIBE_SCRIPT = "scripts",

	QUALITY_LOW = 1,
	QUALITY_MEDIUM = 2,
	QUALITY_HIGH = 3,

	KNOWLEDGE_INVALID = -1,
	KNOWLEDGE_NODATA = 0,
	KNOWLEDGE_KNOWN = 1,
	KNOWLEDGE_UNKNOWN = 2,

	PRIORITY_RANKS = 100,
	PRIORITY_RANK_DEFAULT = 50,

	-- Data format parameters
	FORMAT_VERSION = 1,
	ENCODE_BITS = 6, -- 6-bit encoding
	FIELD_BITS = 30, -- Encoding block size for character knowledge
	FIELD_BYTES = 5, -- FIELD_BITS / ENCODE_BITS

	scanThrottle = 200, -- 0.2s

	server = LCCC.GetServerName(),
	userId = GetDisplayName(),
	charId = GetCurrentCharacterId(),

	maxIds = { },
	ids = { },
	idsPublic = { },
	caches = { },
	cachedCharLists = { },
	initialized = false,

	-- Placeholders to allow pre-init calls to fail gracefully
	accounts = { },
	characters = { },

	diagnostics = { },
}
LibCharacterKnowledgeInternal = Internal

LCCC.RunAfterInitialLoadscreen(function( )
	zo_callLater(Internal.Initialize, Internal.scanThrottle)
end)


--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

local Diagnostics = Internal.diagnostics

function Diagnostics.Stopwatch( start )
	local tick = GetGameTimeMilliseconds()
	if (start) then
		Diagnostics.times = { }
	else
		table.insert(Diagnostics.times, tick - Diagnostics.tick)
	end
	Diagnostics.tick = tick
end

function Diagnostics.LogTime( name )
	Diagnostics.Stopwatch()

	if (not Diagnostics.vars[name]) then
		Diagnostics.vars[name] = { next = 1 }
	end
	local history = Diagnostics.vars[name]

	if (#Diagnostics.times == 1) then
		history[history.next] = string.format("%dms", Diagnostics.times[1])
	else
		local total = 0
		for _, time in ipairs(Diagnostics.times) do
			total = total + time
		end
		history[history.next] = string.format("%dms (%s)", total, table.concat(Diagnostics.times, "/"))
	end

	history.next = history.next % 4 + 1
end


--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

Internal.Categories = {
	Internal.CATEGORY_RECIPE,
	Internal.CATEGORY_PLAN,
	Internal.CATEGORY_MOTIF,
}

Internal.ScribingTypes = {
	[Internal.SCRIBE_GRIMOIRE] = {
		order = 1,
		know = IsCraftedAbilityUnlocked,
	},
	[Internal.SCRIBE_SCRIPT] = {
		order = 2,
		know = IsCraftedAbilityScriptUnlocked,
	},
}

Internal.ItemIdStores = {
	Internal.CATEGORY_RECIPE,
	Internal.CATEGORY_PLAN,
	Internal.CATEGORY_MOTIF,
	Internal.SCRIBE_GRIMOIRE,
	Internal.SCRIBE_SCRIPT,
}

Internal.DataStores = {
	Internal.CATEGORY_RECIPE,
	Internal.CATEGORY_PLAN,
	Internal.CATEGORY_MOTIF,
	Internal.CATEGORY_SCRIBING,
	Internal.CATEGORY_RESEARCH,
}

Internal.KnowFunctions = {
	[Internal.CATEGORY_RECIPE] = IsItemLinkRecipeKnown,
	[Internal.CATEGORY_PLAN] = IsItemLinkRecipeKnown,
	[Internal.CATEGORY_MOTIF] = IsItemLinkBookKnown,
}

Internal.CategoryLabels = {
	[Internal.CATEGORY_RECIPE] = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)),
	[Internal.CATEGORY_PLAN] = zo_strformat("<<1>>", GetString("SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY", PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING)),
	[Internal.CATEGORY_MOTIF] = zo_strformat("<<1>>", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)),
	[Internal.CATEGORY_SCRIBING] = GetString(SI_SCRIBING_TITLE),
	[Internal.CATEGORY_RESEARCH] = GetString(SI_SMITHING_TAB_RESEARCH),
}

Internal.ItemQualityTranslation = {
	[ITEM_FUNCTIONAL_QUALITY_TRASH]     = Internal.QUALITY_LOW,
	[ITEM_FUNCTIONAL_QUALITY_NORMAL]    = Internal.QUALITY_LOW,
	[ITEM_FUNCTIONAL_QUALITY_MAGIC]     = Internal.QUALITY_LOW,
	[ITEM_FUNCTIONAL_QUALITY_ARCANE]    = Internal.QUALITY_MEDIUM,
	[ITEM_FUNCTIONAL_QUALITY_ARTIFACT]  = Internal.QUALITY_HIGH,
	[ITEM_FUNCTIONAL_QUALITY_LEGENDARY] = Internal.QUALITY_HIGH,
}

function Internal.Msg( text )
	CHAT_ROUTER:AddSystemMessage(text)
end

function Internal.MsgTag( text )
	CHAT_ROUTER:AddSystemMessage(string.format("[%s] %s", Internal.name, text))
end

function Internal.GetItemLink( itemId, linkStyle )
	return string.format("|H%d:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", linkStyle or LINK_STYLE_DEFAULT, itemId)
end

function Internal.GetCharRawData( server, charId, category )
	return Internal.characters[server] and Internal.characters[server][charId] and Internal.characters[server][charId][category]
end

function Internal.TranslateItem( item )
	-- Return: itemId, itemLink, styleId
	local itemId, itemLink, styleId = 0, ""

	if (type(item) == "number") then
		itemId, itemLink = item, Internal.GetItemLink(item)
	elseif (type(item) == "string") then
		itemId, itemLink = GetItemLinkItemId(item), item
	elseif (type(item) == "table") then
		if (type(item.styleId) == "number") then
			styleId = item.styleId
			local data = Internal.GetStyleMotifItems(styleId)
			if (data) then
				if (type(item.chapterId) == "number" and item.chapterId ~= ITEM_STYLE_CHAPTER_ALL) then
					itemId = data.chapters[item.chapterId] or itemId
				else
					itemId = data.books[1] or itemId
				end
			end
		end
		if (type(item.itemId) == "number") then itemId = item.itemId end
		if (type(item.itemLink) == "string") then itemLink = item.itemLink end
		if (itemId == 0 and itemLink ~= "") then
			itemId = GetItemLinkItemId(itemLink)
		elseif (itemId ~= 0 and itemLink == "") then
			itemLink = Internal.GetItemLink(itemId)
		end
	end

	return itemId, itemLink, styleId
end

function Internal.GetItemCategoryAndQuality( item )
	local itemId, itemLink, styleId = Internal.TranslateItem(item)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)

	if (itemType == ITEMTYPE_NONE) then
		if (styleId) then
			return Internal.CATEGORY_MOTIF, Internal.GetStyleQuality(styleId)
		else
			return Internal.CATEGORY_INVALID
		end
	elseif (itemType == ITEMTYPE_RECIPE) then
		local quality = Internal.ItemQualityTranslation[GetItemLinkFunctionalQuality(itemLink)]
		if (specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK) then
			return Internal.CATEGORY_RECIPE, quality
		else
			return Internal.CATEGORY_PLAN, quality
		end
	elseif (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) then
		styleId = Internal.GetMotifStyleAndChapter(itemId)
		return Internal.CATEGORY_MOTIF, Internal.GetStyleQuality(styleId)
	elseif (itemType == ITEMTYPE_CRAFTED_ABILITY or itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT) then
		-- The "quality" of a scribing item is just where it fits in
		local refId = GetItemLinkItemUseReferenceId(itemLink)
		if (refId > 0) then
			if (itemType == ITEMTYPE_CRAFTED_ABILITY) then
				-- Grimoire
				return Internal.CATEGORY_SCRIBING, SCRIBING_SLOT_NONE, { itemLink, refId }
			else
				-- Script
				return Internal.CATEGORY_SCRIBING, GetCraftedAbilityScriptScribingSlot(refId), { itemLink, refId }
			end
		end
	end

	return Internal.CATEGORY_NONE
end

function Internal.GetMasterListParam( key )
	if (Internal.vars.masterList and type(Internal.vars.masterList[key]) == "number") then
		return Internal.vars.masterList[key]
	else
		return -1
	end
end

function Internal.CanSave( account )
	if (Internal.vars.noSave and Internal.vars.noSave[zo_strlower(account or Internal.userId)]) then
		return false
	else
		return true
	end
end

function Internal.GetCaches( server, charId )
	if (not Internal.caches[server]) then
		Internal.caches[server] = { }
	end
	if (not Internal.caches[server][charId]) then
		Internal.caches[server][charId] = { }
	end
	return Internal.caches[server][charId]
end

function Internal.GetKnowledge( server, charId, category )
	server = server or Internal.server

	-- Read the encoded bitfield data and expand it into a cached table suitable for active use
	local caches = Internal.GetCaches(server, charId)
	if (not caches[category]) then
		caches[category] = { }
		local data = Internal.GetCharRawData(server, charId, category)
		if (data) then
			local encoded = LCCC.Unchunk(data)
			local field = 0

			-- Since the cache is sparsely populated with only known items, this
			-- prevents the cache from being completely empty
			caches[category][Internal.ids[category][1]] = false

			for i, id in ipairs(Internal.ids[category]) do
				local j = (i - 1) % Internal.FIELD_BITS + 1
				if (j == 1) then
					-- Start of a new field
					local k = zo_ceil(i / Internal.ENCODE_BITS)
					field = LCCC.ReadAndDecode(encoded, k, Internal.FIELD_BYTES)
				end
				local bit = BitLShift(1, Internal.FIELD_BITS - j)
				if (BitAnd(field, bit) == bit) then
					caches[category][id] = true
				end
			end
		end
	end
	return caches[category]
end

function Internal.GetItemKnowledge( server, charId, category, itemId, itemLink, styleId )
	if (itemId == 0 and styleId) then
		local data = Internal.GetStyleMotifItems(styleId)
		if (data and #data.chapters > 0) then
			for _, chapter in ipairs(data.chapters) do
				local result = Internal.GetItemKnowledge(server, charId, category, Internal.TranslateItem(chapter))
				if (result ~= Internal.KNOWLEDGE_KNOWN) then
					return result
				end
			end
			return Internal.KNOWLEDGE_KNOWN
		else
			return Internal.KNOWLEDGE_INVALID
		end
	elseif (category == Internal.CATEGORY_SCRIBING) then
		return Internal.ScribingGetKnowledge(
			server,
			charId,
			Internal[(GetItemLinkItemType(itemLink) == ITEMTYPE_CRAFTED_ABILITY) and "SCRIBE_GRIMOIRE" or "SCRIBE_SCRIPT"],
			GetItemLinkItemUseReferenceId(itemLink)
		)
	elseif (category) then
		local fallback = Internal.KNOWLEDGE_NODATA

		-- Use direct determination if possible since there is a scan delay when
		-- learning new items
		if ((not server or server == Internal.server) and charId == Internal.charId) then
			if (Internal.KnowFunctions[category](itemLink)) then
				return Internal.KNOWLEDGE_KNOWN
			elseif (category ~= Internal.CATEGORY_MOTIF) then
				return Internal.KNOWLEDGE_UNKNOWN
			else
				-- The motif book bug makes the unknown status unreliable
				fallback = Internal.KNOWLEDGE_UNKNOWN
			end
		end

		-- Use internal data for all other scenarios
		local cache = Internal.GetKnowledge(server, charId, category)
		if (next(cache) == nil) then
			return fallback
		elseif (cache[itemId] == true) then
			return Internal.KNOWLEDGE_KNOWN
		else
			return Internal.KNOWLEDGE_UNKNOWN
		end
	else
		-- CATEGORY_NONE is false and CATEGORY_INVALID is nil
		return Internal.KNOWLEDGE_INVALID
	end
end

local function IsSet( value )
	return value ~= nil and value ~= 0
end

function Internal.IsCharacterEnabled( server, charId )
	local result
	local char = Internal.characters[server] and Internal.characters[server][charId]
	if (char) then
		result = char.settings and char.settings.enabled
		if (not IsSet(result)) then
			local account = Internal.accounts[server] and Internal.accounts[server][char.account]
			result = account and account.enabled
		end
	end
	return not (result == 2)
end

function Internal.GetEffectiveParameterValue( server, charId, param )
	local char = Internal.characters[server] and Internal.characters[server][charId]
	if (char) then
		if (char.settings and IsSet(char.settings[param])) then
			return char.settings[param]
		elseif (Internal.accounts[server]) then
			local account = Internal.accounts[server][char.account] or Internal.accounts[server].defaults
			if (account and IsSet(account[param])) then
				return account[param]
			end
		end
	end
	return Internal.vars.defaults[param]
end

function Internal.GetCharacterParams( server, charId )
	local results
	local char = Internal.characters[server] and Internal.characters[server][charId]
	if (char) then
		results = {
			enabled = Internal.IsCharacterEnabled(server, charId),
			priority = Internal.GetEffectiveParameterValue(server, charId, "priority"),
			tracking = { },
		}
		for _, category in ipairs(Internal.DataStores) do
			results.tracking[category] = Internal.GetEffectiveParameterValue(server, charId, category)
		end
	end
	return results
end

function Internal.Sort( server, charIds, usePriority )
	if (usePriority) then
		table.sort(charIds, function( a, b )
			local pa = Internal.GetEffectiveParameterValue(server, a, "priority")
			local pb = Internal.GetEffectiveParameterValue(server, b, "priority")
			if (pa == pb) then
				return LCCC.CompareCharIds(a, b)
			else
				return pa < pb
			end
		end)
	else
		table.sort(charIds, LCCC.CompareCharIds)
	end
end

function Internal.AccountFilter( accountFilter, character )
	if (not accountFilter) then
		return true
	elseif (type(accountFilter) == "string") then
		return accountFilter == character.account
	elseif (type(accountFilter) == "table") then
		return accountFilter[character.account]
	end
end

function Internal.NotifyRefresh( invalidateCharacterList )
	if (invalidateCharacterList) then
		Internal.cachedFilteredServerList = nil
		Internal.cachedCharLists = { }
	end
	Internal.FireCallbacks(Public.EVENT_UPDATE_REFRESH, invalidateCharacterList)
end


--------------------------------------------------------------------------------
-- Motif Associations
--------------------------------------------------------------------------------

function Internal.LoadMotifData( )
	Internal.motifAssociations = {
		motifs = { },
		styles = { },
		styleIds = { },
	}
	local data = Internal.motifAssociations
	local blacklist = Internal.InvalidIds

	-- Associate style and chapter IDs with motif item IDs
	local FIELD_ITEM_ID = 3 -- 18 bits: 0-17 = itemId
	local FIELD_PAYLOAD = 2 -- 12 bits: 0-3 = chapterId, 4-11 = styleId

	local encoded = LCCC.Unchunk(Internal.MotifData)
	local length = zo_strlen(encoded)
	local i = 1
	while (i < length) do
		local itemId, payload
		itemId, i = LCCC.ReadAndDecode(encoded, i, FIELD_ITEM_ID)
		payload, i = LCCC.ReadAndDecode(encoded, i, FIELD_PAYLOAD)

		local chapterId = BitAnd(payload, 0xF)
		local styleId = BitRShift(payload, 4)

		data.motifs[itemId] = { styleId, chapterId }

		if (not blacklist[itemId]) then
			if (not data.styles[styleId]) then
				data.styles[styleId] = {
					books = { },
					chapters = { },
				}
			end

			if (chapterId == ITEM_STYLE_CHAPTER_ALL) then
				table.insert(data.styles[styleId].books, itemId)
			else
				data.styles[styleId].chapters[chapterId] = itemId
			end
		end
	end

	-- Associate motif numbers, crown-exclusive status, and achievement IDs with style IDs
	local FIELD_METADATA = 5 -- 30 bits: 0-7 = styleId, 8-15 = number, 16 = crown, 17-29 = achievementId

	encoded = Internal.MotifData.metadata
	length = zo_strlen(encoded)
	i = 1
	while (i < length) do
		local payload
		payload, i = LCCC.ReadAndDecode(encoded, i, FIELD_METADATA)

		local style = data.styles[BitAnd(payload, 0xFF)]
		style.number = BitAnd(BitRShift(payload, 8), 0xFF)
		style.crown = BitRShift(payload, 16) == 1
		style.achievementId = BitAnd(BitRShift(payload, 17), 0x1FFF)
	end

	-- Build list of valid style IDs, omitting ones that were mined from a future patch and are not active in the current patch
	for styleId, style in pairs(data.styles) do
		if (Internal.GetItemCategoryAndQuality(style.books[1] or style.chapters[ITEM_STYLE_CHAPTER_CHESTS]) == Internal.CATEGORY_MOTIF) then
			table.insert(data.styleIds, styleId)
		end
	end
	table.sort(data.styleIds)
end

function Internal.GetMotifStyleAndChapter( itemId, _, styleId )
	-- Returns styleId, chapterId
	local data = Internal.motifAssociations
	if (data and data.motifs[itemId]) then
		return unpack(data.motifs[itemId])
	elseif (data and styleId) then
		return styleId, ITEM_STYLE_CHAPTER_ALL
	else
		return 0, 0
	end
end

function Internal.GetStyleIds( )
	local data = Internal.motifAssociations
	return data and data.styleIds
end

function Internal.GetStyleMotifItems( styleId )
	local data = Internal.motifAssociations
	return data and data.styles[styleId]
end

function Internal.GetStyleQuality( styleId )
	return Internal.StyleQuality[styleId] or Internal.QUALITY_HIGH
end


--------------------------------------------------------------------------------
-- Initialization: Master List
--------------------------------------------------------------------------------

function Internal.Initialize( )
	Diagnostics.Stopwatch(true)

	-- Schedule the settings panel initialization
	Public.RegisterForCallback(Internal.name, Public.EVENT_INITIALIZED, Internal.RegisterSettingsPanel)

	-- Initialize data store
	if (not LibCharacterKnowledgeData or LibCharacterKnowledgeData.formatVersion ~= Internal.FORMAT_VERSION) then
		LibCharacterKnowledgeData = {
			formatVersion = Internal.FORMAT_VERSION,
		}
	end
	Internal.vars = LibCharacterKnowledgeData

	-- Diagnostics
	if (not Internal.vars.diagnostics) then
		Internal.vars.diagnostics = { }
	end
	Diagnostics.vars = Internal.vars.diagnostics

	-- Default settings
	if (not Internal.vars.defaults) then
		Internal.vars.defaults = {
			[Internal.CATEGORY_RECIPE] = 4,
			[Internal.CATEGORY_PLAN] = 4,
			[Internal.CATEGORY_MOTIF] = 4,
			[Internal.CATEGORY_SCRIBING] = 2,
			[Internal.CATEGORY_RESEARCH] = 2,
			priority = Internal.PRIORITY_RANK_DEFAULT,
		}
	end

	if (not Internal.vars.defaults[Internal.CATEGORY_SCRIBING]) then
		Internal.vars.defaults[Internal.CATEGORY_SCRIBING] = 2
	end

	if (not Internal.vars.defaults[Internal.CATEGORY_RESEARCH]) then
		Internal.vars.defaults[Internal.CATEGORY_RESEARCH] = 2
	end

	-- Initialize account and character sections
	for _, key in ipairs({ "accounts", "characters" }) do
		if (not Internal.vars[key]) then
			Internal.vars[key] = { }
		end
		if (not Internal.vars[key][Internal.server]) then
			Internal.vars[key][Internal.server] = { }
		end
		Internal[key] = Internal.vars[key]
	end

	-- Load motif associations
	Internal.LoadMotifData()

	-- Initialize the master list
	Diagnostics.Stopwatch()
	if (Internal.GetMasterListParam("api") > 0 and Internal.GetMasterListParam("fieldSize") > 0) then
		Internal.ReadMasterList()
	else
		Internal.Datamine()
	end
end

function Internal.ReadMasterList( finalizeBaseDataLoad )
	local fieldSize = Internal.GetMasterListParam("fieldSize")

	for _, category in ipairs(Internal.ItemIdStores) do
		local encoded = LCCC.Unchunk(Internal.vars.masterList[category])
		local length = zo_strlen(encoded)
		local decoded = { }
		local i, itemId = 1
		while (i < length) do
			itemId, i = LCCC.ReadAndDecode(encoded, i, fieldSize)
			table.insert(decoded, itemId)
		end
		Internal.ids[category] = decoded
	end

	-- Load scribing max IDs (also checks if scribing data exists)
	local validMaxIds = true
	for key in pairs(Internal.ScribingTypes) do
		Internal.maxIds[key] = Internal.GetMasterListParam("maxId_" .. key)
		if (Internal.maxIds[key] <= 0) then
			validMaxIds = false
		end
	end

	if (finalizeBaseDataLoad) then
		Internal.MsgTag(GetString(SI_LCK_SCAN_COMPLETE))
		Internal.MigrateData("flush")
		Internal.InitializeCharacterData()
	elseif (Internal.GetMasterListParam("api") == GetAPIVersion() and not Internal.DoesNewerBaseDataExist() and validMaxIds) then
		Internal.InitializeCharacterData()
	else
		Internal.MigrateData("start")
	end
end

function Internal.WriteMasterList( maxId )
	local fieldSize = zo_ceil(math.log(maxId) / math.log(64))

	Internal.vars.masterList = {
		api = GetAPIVersion(),
		fieldSize = fieldSize,
		timestamp = GetTimeStamp(),
	}

	Diagnostics.vars.masterList = { }

	for _, category in ipairs(Internal.ItemIdStores) do
		local encoded = { }
		for _, id in ipairs(Internal.ids[category]) do
			table.insert(encoded, LCCC.Encode(id, fieldSize))
		end
		Internal.vars.masterList[category] = LCCC.Chunk(table.concat(encoded, ""))
		Diagnostics.vars.masterList[category] = #encoded
	end

	-- Save scribing max IDs
	for key in pairs(Internal.ScribingTypes) do
		Internal.vars.masterList["maxId_" .. key] = Internal.maxIds[key]
	end

	Internal.MsgTag(GetString(SI_LCK_SCAN_COMPLETE))
	Internal.MigrateData("flush")
	Internal.InitializeCharacterData()
end

function Internal.Datamine( )
	Internal.MsgTag(GetString(SI_LCK_SCAN_START))

	if (Internal.DoesValidBaseDataExist()) then
		Internal.vars.masterList = Internal.BaseData
		return Internal.ReadMasterList(true)
	elseif (ZO_IsConsoleOrGameCoreUI()) then
		return Internal.MsgTag(GetString(SI_LCK_SCAN_CONSOLE))
	end

	local BLOCK_SIZE = 10000 -- Block size

	for _, category in ipairs(Internal.ItemIdStores) do
		Internal.ids[category] = { }
	end

	-- Pre-zero the scribing tables to account for any gaps in the IDs
	for key, data in pairs(Internal.ScribingTypes) do
		Internal.maxIds[key] = data.max()
		for i = 1, Internal.maxIds[key] do
			Internal.ids[key][i] = 0
		end
	end

	local startId = 1
	local invalidCount = 0
	local lastValidId = 0

	EVENT_MANAGER:RegisterForUpdate(Internal.name, Internal.scanThrottle, function( )
		local stopId = startId + BLOCK_SIZE
		for i = startId, stopId - 1 do
			local category, quality, data = Internal.GetItemCategoryAndQuality(i)
			if (category == Internal.CATEGORY_INVALID) then
				invalidCount = invalidCount + 1
				if (invalidCount == BLOCK_SIZE) then
					-- Conclude the scan when we see a very large number of consecutive invalid items (highest observed: 4515)
					EVENT_MANAGER:UnregisterForUpdate(Internal.name)
					return Internal.WriteMasterList(lastValidId)
				end
			else
				invalidCount = 0
				lastValidId = i
				if (category == Internal.CATEGORY_SCRIBING) then
					local tbl = Internal.ids[Internal[(quality == SCRIBING_SLOT_NONE) and "SCRIBE_GRIMOIRE" or "SCRIBE_SCRIPT"]]
					local bindType = GetItemLinkBindType(data[1])
					if (tbl[data[2]] == 0 or (bindType ~= BIND_TYPE_ON_PICKUP and bindType ~= BIND_TYPE_ON_PICKUP_BACKPACK)) then
						tbl[data[2]] = i
					end
				elseif (category ~= Internal.CATEGORY_NONE) then
					table.insert(Internal.ids[category], i)
				end
			end
		end
		startId = stopId
	end)
end

function Internal.MigrateData( phase )
	if (phase == "start") then
		-- Start the data migration by decoding all knowledge data into cache using the old master list
		for server, characters in pairs(Internal.characters) do
			for id, data in pairs(characters) do
				for _, category in ipairs(Internal.Categories) do
					if (data[category]) then
						Internal.GetKnowledge(server, id, category)
					end
				end
			end
		end
		-- Build a new master list
		Internal.Datamine()
	elseif (phase == "flush") then
		-- Re-encode and flush the knowledge data from cache using the new master list
		-- Note: The only scenario in which cache is populated at this point is if data is being migrated
		for server, characters in pairs(Internal.caches) do
			for id, data in pairs(characters) do
				for _, category in ipairs(Internal.Categories) do
					if (data[category]) then
						Internal.ScanAndEncodeKnowledgeCategory(server, id, category, data[category])
					end
				end
			end
		end
	end
end

function Internal.DoesValidBaseDataExist( )
	return type(Internal.BaseData) == "table" and Internal.BaseData.api == GetAPIVersion()
end

function Internal.DoesNewerBaseDataExist( )
	return Internal.DoesValidBaseDataExist() and type(Internal.BaseData.timestamp) == "number" and Internal.BaseData.timestamp > Internal.GetMasterListParam("timestamp")
end


--------------------------------------------------------------------------------
-- Initialization: Accounts and Characters
--------------------------------------------------------------------------------

function Internal.InitializeCharacterData( )
	Diagnostics.Stopwatch()

	local charactersLocal = Internal.characters[Internal.server]
	local exists = { }

	-- Create entries for every character on the account
	if (Internal.CanSave()) then
		for i = 1, GetNumCharacters() do
			local name, _, _, _, _, _, id = GetCharacterInfo(i)
			if (not charactersLocal[id]) then
				charactersLocal[id] = { }
			end
			charactersLocal[id].account = Internal.userId
			charactersLocal[id].name = zo_strformat("<<1>>", name)
			exists[id] = true
		end
	end

	-- Delete characters that no longer exist or are on the no-save list
	for id, data in pairs(charactersLocal) do
		if ((data.account == Internal.userId and not exists[id]) or not Internal.CanSave(data.account)) then
			charactersLocal[id] = nil
		end
	end

	-- Initial scan
	Internal.ScanKnowledge()

	-- Listen for changes
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_MULTIPLE_RECIPES_LEARNED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_RECIPE_LEARNED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_STYLE_LEARNED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED, function(_, _, _, isFromInit) if (not isFromInit) then Internal.RefreshKnowledge() end end)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_SMITHING_TRAIT_RESEARCH_STARTED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_SMITHING_TRAIT_RESEARCH_TIMES_UPDATED, Internal.RefreshKnowledge)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_SKILL_RESPEC_RESULT, function(_, result) if (result == RESPEC_RESULT_SUCCESS and Internal.ResearchCheckPassives()) then Internal.RefreshKnowledge() end end)
	EVENT_MANAGER:RegisterForEvent(Internal.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function(_, result) if (result == ARMORY_BUILD_RESTORE_RESULT_SUCCESS and Internal.ResearchCheckPassives()) then Internal.RefreshKnowledge() end end)
end

function Internal.RefreshKnowledge( )
	EVENT_MANAGER:UnregisterForUpdate(Internal.name)
	EVENT_MANAGER:RegisterForUpdate(Internal.name, Internal.scanThrottle, Internal.ScanKnowledge, true)
end


--------------------------------------------------------------------------------
-- Scanning and Encoding
--------------------------------------------------------------------------------

function Internal.ScanKnowledge( )
	if (Internal.initialized) then
		Diagnostics.Stopwatch(true)
	end

	if (Internal.CanSave()) then
		local caches = Internal.GetCaches(Internal.server, Internal.charId)
		for _, category in ipairs(Internal.Categories) do
			caches[category] = Internal.ScanAndEncodeKnowledgeCategory(Internal.server, Internal.charId, category)
		end
		Internal.characters[Internal.server][Internal.charId][Internal.CATEGORY_SCRIBING] = LCCC.Chunk(Internal.ScribingScanAndEncode())
		Internal.characters[Internal.server][Internal.charId][Internal.CATEGORY_RESEARCH] = LCCC.Chunk(Internal.ResearchScanAndEncode())
		Internal.characters[Internal.server][Internal.charId].timestamp = GetTimeStamp()
	end

	if (not Internal.initialized) then
		Internal.initialized = true
		Diagnostics.Stopwatch()
		Internal.FireCallbacks(Public.EVENT_INITIALIZED)
		Diagnostics.LogTime("initialization")
	else
		Internal.NotifyRefresh(false)
		Diagnostics.LogTime("refresh")
	end
end

function Internal.ScanAndEncodeKnowledgeCategory( server, charId, category, cache )
	-- Scan knowledge, if not pre-supplied
	if (not cache) then
		cache = { }

		-- Since the cache is sparsely populated with only known items, this
		-- prevents the cache from being completely empty
		cache[Internal.ids[category][1]] = false

		for _, id in ipairs(Internal.ids[category]) do
			if (Internal.KnowFunctions[category](Internal.GetItemLink(id))) then
				cache[id] = true
			end
		end

		if (category == Internal.CATEGORY_MOTIF) then
			Internal.FixIncorrectMotifBookKnowledge(cache)
		end
	end

	-- Encode into bitfields
	local bitfield = 0
	local bitfields = { }

	for i, id in ipairs(Internal.ids[category]) do
		bitfield = BitLShift(bitfield, 1)

		if (cache[id]) then
			bitfield = bitfield + 1
		end

		if (i % Internal.FIELD_BITS == 0) then
			table.insert(bitfields, LCCC.Encode(bitfield, Internal.FIELD_BYTES))
			bitfield = 0
		end
	end

	local remainder = #Internal.ids[category] % Internal.FIELD_BITS
	if (remainder > 0) then
		table.insert(bitfields, LCCC.Encode(BitLShift(bitfield, Internal.FIELD_BITS - remainder), Internal.FIELD_BYTES))
	end

	Internal.characters[server][charId][category] = LCCC.Chunk(table.concat(bitfields, ""))

	return cache
end

function Internal.FixIncorrectMotifBookKnowledge( cache )
	-- There is a rare bug where IsItemLinkBookKnown will incorrectly report a
	-- book as unknown, so this attempts to work around the problem by looking
	-- at chapter knowledge.

	local overrides = { }

	for _, styleId in ipairs(Internal.GetStyleIds()) do
		local data = Internal.GetStyleMotifItems(styleId)
		if (#data.chapters > 0) then
			local complete = true
			for _, itemId in ipairs(data.chapters) do
				if (not cache[itemId]) then
					complete = false
					break
				end
			end

			if (complete) then
				for _, itemId in ipairs(data.books) do
					if (not cache[itemId]) then
						cache[itemId] = true
						table.insert(overrides, itemId)
					end
				end
			end
		end
	end

	if (#overrides > 0) then
		if (not Diagnostics.vars.bookCorrections) then
			Diagnostics.vars.bookCorrections = { }
		end
		Diagnostics.vars.bookCorrections[Internal.charId] = table.concat(overrides, ",")
	end
end


--------------------------------------------------------------------------------
-- Scribing
--------------------------------------------------------------------------------

local BITS = 6

do
	function Internal.ScribingScanAndEncode( )
		local results = { }

		for key, data in pairs(Internal.ScribingTypes) do
			local result = ""

			-- Pad the scan sequence as needed
			local maxId = zo_ceil(Internal.maxIds[key] / BITS) * BITS

			-- Scan and encode
			local field = 0
			for currentId = 1, maxId do
				field = field * 2
				if (data.know(currentId)) then
					field = field + 1
				end
				if (currentId % BITS == 0) then
					result = result .. LCCC.Encode(field, 1)
					field = 0
				end
			end

			results[data.order] = result
		end

		return table.concat(results, ":")
	end

	function Internal.ScribingGetKnowledge( server, charId, key, id )
		server = server or Internal.server
		charId = charId or Internal.charId
		if (server == Internal.server and charId == Internal.charId) then
			-- Return the result directly from the API
			if (Internal.ScribingTypes[key].know(id)) then
				return Internal.KNOWLEDGE_KNOWN
			else
				return Internal.KNOWLEDGE_UNKNOWN
			end
		else
			local data = Internal.GetCharRawData(server, charId, Internal.CATEGORY_SCRIBING)
			if (not data) then
				return Internal.KNOWLEDGE_NODATA
			else
				local unpacked = { zo_strsplit(":", LCCC.Unchunk(data)) }
				if (LCCC.ReadBitFromEncodedData(unpacked[Internal.ScribingTypes[key].order], id)) then
					return Internal.KNOWLEDGE_KNOWN
				else
					return Internal.KNOWLEDGE_UNKNOWN
				end
			end
		end
	end

	local function GetMaxScribingId( checkFn, checkRet )
		local MAX_CONSECUTIVE_INVALID_IDS = 10
		local currentId = 1
		local invalidCount = 0
		local lastValidId = 0

		repeat
			if (checkFn(currentId) == checkRet) then
				invalidCount = invalidCount + 1
			else
				invalidCount = 0
				lastValidId = currentId
			end
			currentId = currentId + 1
		until invalidCount >= MAX_CONSECUTIVE_INVALID_IDS

		return lastValidId
	end

	Internal.ScribingTypes[Internal.SCRIBE_GRIMOIRE].max = function( )
		-- Could use GetNumCraftedAbilities instead, but it's unclear how it would handle gaps in the IDs should any arise in the future
		return GetMaxScribingId(GetSkillTypeForCraftedAbilityId, SKILL_TYPE_NONE)
	end

	Internal.ScribingTypes[Internal.SCRIBE_SCRIPT].max = function( )
		return GetMaxScribingId(GetCraftedAbilityScriptScribingSlot, SCRIBING_SLOT_NONE)
	end
end


--------------------------------------------------------------------------------
-- Research
-- 54 bytes: trait knowledge (324b)
-- 1 byte: number of extra slots (so 0-2, not 1-3) for non-jewelry (2b each)
-- 10 bytes: each active research slot (12b index, 24b duration, 24b remaining)
--------------------------------------------------------------------------------

do
	local TraitBytes = nil -- Also doubles as initialization check

	local BLOCK_BYTES = 6
	local BLOCK_BITS = 36

	-- For traits currently being researched
	local TIME_INDEX_SIZE = 2
	local TIME_FIELD_SIZE = 4
	local TIME_TOTAL_SIZE = 10

	local TRADESKILL_LOOKUP, TRADESKILL_REVERSE_LOOKUP
	Internal.TRADESKILL_TYPES = {
		CRAFTING_TYPE_BLACKSMITHING,
		CRAFTING_TYPE_CLOTHIER,
		CRAFTING_TYPE_WOODWORKING,
		CRAFTING_TYPE_JEWELRYCRAFTING,
	}

	-- Used for ResearchGetIndicesFromItemLink
	local ITEM_LOOKUPS = {
		EQUIP = {
			[EQUIP_TYPE_CHEST] = 1,
			[EQUIP_TYPE_FEET] = 2,
			[EQUIP_TYPE_HAND] = 3,
			[EQUIP_TYPE_HEAD] = 4,
			[EQUIP_TYPE_LEGS] = 5,
			[EQUIP_TYPE_SHOULDERS] = 6,
			[EQUIP_TYPE_WAIST] = 7,
			[EQUIP_TYPE_RING] = 1,
			[EQUIP_TYPE_NECK] = 2,
			[EQUIP_TYPE_MAIN_HAND] = -1,
			[EQUIP_TYPE_OFF_HAND] = -1,
			[EQUIP_TYPE_ONE_HAND] = -1,
			[EQUIP_TYPE_TWO_HAND] = -1,
		},
		WEAPON = {
			[WEAPONTYPE_AXE] = 1,
			[WEAPONTYPE_HAMMER] = 2,
			[WEAPONTYPE_SWORD] = 3,
			[WEAPONTYPE_TWO_HANDED_AXE] = 4,
			[WEAPONTYPE_TWO_HANDED_HAMMER] = 5,
			[WEAPONTYPE_TWO_HANDED_SWORD] = 6,
			[WEAPONTYPE_DAGGER] = 7,
			[WEAPONTYPE_BOW] = 1,
			[WEAPONTYPE_FIRE_STAFF] = 2,
			[WEAPONTYPE_FROST_STAFF] = 3,
			[WEAPONTYPE_LIGHTNING_STAFF] = 4,
			[WEAPONTYPE_HEALING_STAFF] = 5,
			[WEAPONTYPE_SHIELD] = 6,
		},
		TRAIT = {
			[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 1,
			[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 2,
			[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 3,
			[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 4,
			[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 5,
			[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 6,
			[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 7,
			[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 8,
			[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 9,
			[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 1,
			[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 2,
			[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 3,
			[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 4,
			[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 5,
			[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 6,
			[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 7,
			[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 8,
			[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 9,
			[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 1,
			[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 2,
			[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 3,
			[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 4,
			[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 5,
			[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 6,
			[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 7,
			[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 8,
			[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 9,
		},
		ARMOR_OFFSET = {
			[ARMORTYPE_MEDIUM] = 7,
			[ARMORTYPE_HEAVY] = 7,
		},
	}

	-- Initialization does two things:
	-- 1/ Build a lookup table to map a specific trait to a bitfield index
	-- 2/ Since research uses indices with no corresponding IDs and indices are
	--    not guaranteed to be stable (e.g., that time when rings and necks were
	--    swapped), build a signature tripwire to hopefully catch changes early
	local function InitializeResearch( )
		if (TraitBytes) then return end

		local index = 0
		local signature = { }
		TRADESKILL_LOOKUP = { }
		TRADESKILL_REVERSE_LOOKUP = { }

		-- Build lookup table, gather signature data
		for i, craftingSkillType in ipairs(Internal.TRADESKILL_TYPES) do
			TRADESKILL_LOOKUP[craftingSkillType] = { slotsShift = (i - 1) * 2 }

			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				TRADESKILL_LOOKUP[craftingSkillType][researchLineIndex] = { }

				local _, icon, numTraits = GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)
				table.insert(signature, icon)
				table.insert(signature, numTraits)

				for traitIndex = 1, numTraits do
					index = index + 1
					TRADESKILL_LOOKUP[craftingSkillType][researchLineIndex][traitIndex] = index
					TRADESKILL_REVERSE_LOOKUP[index] = {
						craftingSkillType = craftingSkillType,
						researchLineIndex = researchLineIndex,
						traitIndex = traitIndex,
					}
				end
			end
		end

		-- Check trait count
		if (Diagnostics.vars.researchTraits ~= index) then
			if (Diagnostics.vars.researchTraits) then
				Internal.MsgTag(GetString(SI_LCK_SCAN_RESEARCH_BAD_TRAITS))
			end
			Diagnostics.vars.researchTraits = index
		end

		-- Check signature
		signature = HashString(table.concat(signature, ","))
		if (Diagnostics.vars.researchSignature ~= signature) then
			if (Diagnostics.vars.researchSignature) then
				Internal.MsgTag(GetString(SI_LCK_SCAN_RESEARCH_BAD_SIG))
			end
			Diagnostics.vars.researchSignature = signature
		end

		-- Total bytes devoted to traits
		TraitBytes = zo_ceil(index / BLOCK_BITS) * BLOCK_BYTES
	end

	local function GetTraitIndex( craftingSkillType, researchLineIndex, traitIndex )
		InitializeResearch()
		return craftingSkillType and researchLineIndex and traitIndex and TRADESKILL_LOOKUP[craftingSkillType] and TRADESKILL_LOOKUP[craftingSkillType][researchLineIndex] and TRADESKILL_LOOKUP[craftingSkillType][researchLineIndex][traitIndex]
	end

	function Internal.ResearchScanAndEncode( )
		InitializeResearch()

		Internal.ResearchCheckPassives()

		local index = 0
		local field = 0
		local slots = 0
		local times = { }
		local result = ""

		for i, craftingSkillType in ipairs(Internal.TRADESKILL_TYPES) do
			for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
				for traitIndex = 1, select(3, GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)) do
					index = index + 1

					field = field * 2
					if (select(3, GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex))) then
						field = field + 1
					end
					if (index % BLOCK_BITS == 0) then
						result = result .. LCCC.Encode(field, BLOCK_BYTES)
						field = 0
					end

					local duration, timeRemainingSecs = GetSmithingResearchLineTraitTimes(craftingSkillType, researchLineIndex, traitIndex)
					if (duration and timeRemainingSecs) then
						table.insert(times, LCCC.Encode(index, TIME_INDEX_SIZE) .. LCCC.Encode(duration, TIME_FIELD_SIZE) .. LCCC.Encode(timeRemainingSecs, TIME_FIELD_SIZE))
					end
				end
			end

			local shift = TRADESKILL_LOOKUP[craftingSkillType].slotsShift
			if (shift <= 4) then
				slots = BitOr(BitLShift(BitAnd(GetMaxSimultaneousSmithingResearch(craftingSkillType) - 1, 3), shift), slots)
			end
		end

		local remainder = index % BLOCK_BITS
		if (remainder > 0) then
			-- This should never run unless new traits are added to the game
			result = result .. LCCC.Encode(BitLShift(field, BLOCK_BITS - remainder), BLOCK_BYTES)
		end

		return result .. LCCC.Encode(slots, 1) .. table.concat(times, "")
	end

	function Internal.ResearchGetTraitKnowledge( server, charId, ... )
		server = server or Internal.server
		charId = charId or Internal.charId
		if (server == Internal.server and charId == Internal.charId) then
			-- Return the result directly from the API
			if (select(3, GetSmithingResearchLineTraitInfo(...))) then
				return Internal.KNOWLEDGE_KNOWN
			else
				return Internal.KNOWLEDGE_UNKNOWN
			end
		else
			local data = Internal.GetCharRawData(server, charId, Internal.CATEGORY_RESEARCH)
			if (not data) then
				return Internal.KNOWLEDGE_NODATA
			else
				local index = GetTraitIndex(...)
				if (not index) then
					return Internal.KNOWLEDGE_INVALID
				elseif (LCCC.ReadBitFromEncodedData(LCCC.Unchunk(data), index)) then
					return Internal.KNOWLEDGE_KNOWN
				else
					return Internal.KNOWLEDGE_UNKNOWN
				end
			end
		end
	end

	function Internal.ResearchGetMaxSlots( server, charId, craftingSkillType )
		server = server or Internal.server
		charId = charId or Internal.charId
		if (server == Internal.server and charId == Internal.charId) then
			-- Return the result directly from the API
			return GetMaxSimultaneousSmithingResearch(craftingSkillType)
		else
			local shift = craftingSkillType and TRADESKILL_LOOKUP[craftingSkillType] and TRADESKILL_LOOKUP[craftingSkillType].slotsShift
			if (not shift) then
				return 0 -- Invalid craft
			elseif (shift > 4) then
				return 1 -- Jewelry
			else
				local data = Internal.GetCharRawData(server, charId, Internal.CATEGORY_RESEARCH)
				if (data) then
					InitializeResearch()
					return BitAnd(BitRShift(LCCC.ReadAndDecode(data, TraitBytes + 1, 1), shift), 3) + 1
				else
					return 1
				end
			end
		end
	end

	function Internal.ReadResearchTimes( server, charId, index )
		-- Returns single result matching index, or table of all results if index is nil
		local results = (not index) and { } or nil
		local data = Internal.GetCharRawData(server, charId, Internal.CATEGORY_RESEARCH)
		if (data) then
			local length = zo_strlen(data)
			local pos = TraitBytes + 2
			local field
			while (pos + TIME_TOTAL_SIZE - 1 <= length) do
				field, pos = LCCC.ReadAndDecode(data, pos, TIME_INDEX_SIZE)
				if (results or field == index) then
					local entry = { }
					entry.duration, pos = LCCC.ReadAndDecode(data, pos, TIME_FIELD_SIZE)
					entry.remaining, pos = LCCC.ReadAndDecode(data, pos, TIME_FIELD_SIZE)
					entry.remaining = entry.remaining - (GetTimeStamp() - Public.GetLastScanTime(server, charId))
					if (results) then
						table.insert(results, LCCC.MergeTables(entry, TRADESKILL_REVERSE_LOOKUP[field]))
					else
						return entry.duration, entry.remaining
					end
				else
					pos = pos + TIME_FIELD_SIZE * 2
				end
			end
		end
		return results
	end

	function Internal.ResearchGetTime( server, charId, ... )
		server = server or Internal.server
		charId = charId or Internal.charId
		if (server == Internal.server and charId == Internal.charId) then
			-- Return the result directly from the API
			return GetSmithingResearchLineTraitTimes(...)
		else
			local index = GetTraitIndex(...)
			if (index) then
				return Internal.ReadResearchTimes(server, charId, index)
			end
			return nil
		end
	end

	function Internal.ResearchGetResearchability( server, charId, craftingSkillType, researchLineIndex, traitIndex, extendedCheck )
		if ( Internal.ResearchGetTraitKnowledge(server, charId, craftingSkillType, researchLineIndex, traitIndex) == Internal.KNOWLEDGE_UNKNOWN and
		     not select(2, Internal.ResearchGetTime(server, charId, craftingSkillType, researchLineIndex, traitIndex)) ) then
			if (extendedCheck) then
				-- Check for other research in the line
				for traitIndex = 1, select(3, GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)) do
					local _, remaining = Internal.ResearchGetTime(server, charId, craftingSkillType, researchLineIndex, traitIndex)
					if (remaining and remaining > 0) then
						return remaining
					end
				end

				-- Check for research slot limit
				local found = 0
				local minTime = nil
				for researchLineIndex = 1, GetNumSmithingResearchLines(craftingSkillType) do
					for traitIndex = 1, select(3, GetSmithingResearchLineInfo(craftingSkillType, researchLineIndex)) do
						local _, remaining = Internal.ResearchGetTime(server, charId, craftingSkillType, researchLineIndex, traitIndex)
						if (remaining and remaining > 0) then
							found = found + 1
							minTime = minTime and zo_min(remaining, minTime) or remaining
						end
					end
				end
				return (found >= Internal.ResearchGetMaxSlots(server, charId, craftingSkillType)) and minTime or true
			else
				return true
			end
		else
			return false
		end
	end

	function Internal.ResearchGetIndicesFromItemLink( itemLink )
		local itemTraitInformation = GetItemTraitInformationFromItemLink(itemLink)
		if (itemTraitInformation == ITEM_TRAIT_INFORMATION_NONE or itemTraitInformation == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED) then
			-- GetItemLinkCraftingSkillType only returns craftingSkillType
			local craftingSkillType, researchLineIndex, traitIndex = GetItemLinkCraftingSkillType(itemLink)
			if (GetNumSmithingResearchLines(craftingSkillType) > 0) then
				researchLineIndex = ITEM_LOOKUPS.EQUIP[select(4, GetItemLinkInfo(itemLink))]
				if (researchLineIndex == -1) then
					researchLineIndex = ITEM_LOOKUPS.WEAPON[GetItemLinkWeaponType(itemLink)]
				elseif (researchLineIndex) then
					researchLineIndex = researchLineIndex + (ITEM_LOOKUPS.ARMOR_OFFSET[GetItemLinkArmorType(itemLink)] or 0)
				end
				traitIndex = ITEM_LOOKUPS.TRAIT[GetItemLinkTraitType(itemLink)]
				if (researchLineIndex and traitIndex) then
					return craftingSkillType, researchLineIndex, traitIndex
				end
			end
		end
		return nil
	end

	do
		local RESEARCH_PASSIVES = {
			79, 5, -- Blacksmithing
			80, 5, -- Woodworking
			81, 5, -- Clothing
			141, 4, -- Jewelry Crafting
		}

		local current = nil

		function Internal.ResearchCheckPassives( )
			local previous = current
			current = 0
			for i = 1, #RESEARCH_PASSIVES, 2 do
				local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(RESEARCH_PASSIVES[i])
				local _, _, _, _, _, purchased, _, rank = GetSkillAbilityInfo(skillType, skillLineIndex, RESEARCH_PASSIVES[i + 1])
				current = (current * 8) + (purchased and rank or 0)
			end
			return previous ~= current
		end
	end
end
