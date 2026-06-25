local LAM = LibAddonMenu2
local LMP = LibMediaProvider

if ( not LAM ) then return end
if ( not LMP ) then return end

local tsort = table.sort
local tinsert = table.insert

local FontaccessibilityConfig =
{
    _name = '_fontaccessibility',
    _headers = setmetatable( {}, { __mode = 'kv' } )
}

local CBM = CALLBACK_MANAGER

local THIN          = 'soft-shadow-thin'
local THICK         = 'soft-shadow-thick'
local SHADOW        = 'shadow'
local NONE          = 'none'

local defaults =
{
    ZoFontWinH1 = { face = 'ZH-StdFont', size = 30, decoration = THICK },
    ZoFontWinH2 = { face = 'ZH-StdFont', size = 24, decoration = THICK },
    ZoFontWinH3 = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontWinH4 = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontWinH5 = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontWinT1 = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontWinT2 = { face = 'ZH-StdFont', size = 20, decoration = THIN },

    ZoFontGame = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontGameMedium = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontGameBold = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontGameOutline = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontGameShadow = { face = 'ZH-StdFont', size = 20, decoration = THIN },

    ZoFontGameSmall = { face = 'ZH-StdFont', size = 14, decoration = THIN },
    ZoFontGameLarge = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontGameLargeBold = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontGameLargeBoldShadow = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontHeader  = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontHeader2  = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontHeader3  = { face = 'ZH-StdFont', size = 24, decoration = THICK },
    ZoFontHeader4  = { face = 'ZH-StdFont', size = 26, decoration = THICK },

    ZoFontHeaderNoShadow  = { face = 'ZH-StdFont', size = 20, decoration = NONE },

    ZoFontCallout  = { face = 'ZH-StdFont', size = 36, decoration = THICK },
    ZoFontCallout2  = { face = 'ZH-StdFont', size = 48, decoration = THICK },
    ZoFontCallout3  = { face = 'ZH-StdFont', size = 50, decoration = THICK },

    ZoFontEdit  = { face = 'ZH-StdFont', size = 20, decoration = SHADOW },

    ZoFontChat  = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontEditChat  = { face = 'ZH-StdFont', size = 20, decoration = SHADOW },

    ZoFontWindowTitle  = { face = 'ZH-StdFont', size = 30, decoration = THICK },
    ZoFontWindowSubtitle  = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontTooltipTitle  = { face = 'ZH-StdFont', size = 22, decoration = NONE },
    ZoFontTooltipSubtitle  = { face = 'ZH-StdFont', size = 20, decoration = NONE },

    ZoFontAnnounce  = { face = 'ZH-StdFont', size = 28, decoration = THICK },
    ZoFontAnnounceMessage  = { face = 'ZH-StdFont', size = 24, decoration = THICK },
    ZoFontAnnounceMedium  = { face = 'ZH-StdFont', size = 24, decoration = THICK },
    ZoFontAnnounceLarge  = { face = 'ZH-StdFont', size = 36, decoration = THICK },

    ZoFontAnnounceNoShadow  = { face = 'ZH-StdFont', size = 36, decoration = NONE },

    ZoFontCenterScreenAnnounceLarge  = { face = 'ZH-StdFont', size = 40, decoration = THICK },
    ZoFontCenterScreenAnnounceSmall  = { face = 'ZH-StdFont', size = 30, decoration = THICK },

    ZoFontAlert  = { face = 'ZH-StdFont', size = 24, decoration = THICK },

    ZoFontConversationName  = { face = 'ZH-StdFont', size = 28, decoration = THICK },
    ZoFontConversationText  = { face = 'ZH-StdFont', size = 24, decoration = THICK },
    ZoFontConversationOption  = { face = 'ZH-StdFont', size = 22, decoration = THICK },
    ZoFontConversationQuestReward  = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontKeybindStripKey  = { face = 'ZH-StdFont', size = 20, decoration = THIN },
    ZoFontKeybindStripDescription  = { face = 'ZH-StdFont', size = 25, decoration = THICK },
    ZoFontDialogKeybindDescription  = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoInteractionPrompt  = { face = 'ZH-StdFont', size = 24, decoration = THICK },

    ZoFontCreditsHeader  = { face = 'ZH-StdFont', size = 24, decoration = NONE },
    ZoFontCreditsText  = { face = 'ZH-StdFont', size = 20, decoration = NONE },

    ZoFontBookPaper  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontBookSkin  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontBookRubbing  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontBookLetter  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontBookNote  = { face = 'ZH-StdFont', size = 22, decoration = NONE },
    ZoFontBookScroll  = { face = 'ZH-StdFont', size = 26, decoration = NONE },
    ZoFontBookTablet  = { face = 'ZH-StdFont', size = 30, decoration = THICK },

    ZoFontBookPaperTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontBookSkinTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontBookRubbingTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontBookLetterTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontBookNoteTitle  = { face = 'ZH-StdFont', size = 32, decoration = NONE },
    ZoFontBookScrollTitle  = { face = 'ZH-StdFont', size = 34, decoration = NONE },
    ZoFontBookTabletTitle  = { face = 'ZH-StdFont', size = 48, decoration = THICK },


    ZoFontGamepad61 = { face = 'ZH-StdFont', size = 61, decoration = THICK },
    ZoFontGamepad54 = { face = 'ZH-StdFont', size = 54, decoration = THICK },
    ZoFontGamepad45 = { face = 'ZH-StdFont', size = 45, decoration = THICK },
    ZoFontGamepad42 = { face = 'ZH-StdFont', size = 42, decoration = THICK },
    ZoFontGamepad36 = { face = 'ZH-StdFont', size = 36, decoration = THICK },
    ZoFontGamepad34 = { face = 'ZH-StdFont', size = 34, decoration = THICK },
    ZoFontGamepad27 = { face = 'ZH-StdFont', size = 27, decoration = THICK },
    ZoFontGamepad25 = { face = 'ZH-StdFont', size = 25, decoration = THICK },
    ZoFontGamepad22 = { face = 'ZH-StdFont', size = 22, decoration = THICK },
    ZoFontGamepad20 = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontGamepad18 = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontGamepad27NoShadow = { face = 'ZH-StdFont', size = 27, decoration = NONE },
    ZoFontGamepad42NoShadow = { face = 'ZH-StdFont', size = 42, decoration = NONE },

    ZoFontGamepadCondensed61 = { face = 'ZH-StdFont', size = 61, decoration = THICK },
    ZoFontGamepadCondensed54 = { face = 'ZH-StdFont', size = 54, decoration = THICK },
    ZoFontGamepadCondensed45 = { face = 'ZH-StdFont', size = 45, decoration = THICK },
    ZoFontGamepadCondensed42 = { face = 'ZH-StdFont', size = 42, decoration = THICK },
    ZoFontGamepadCondensed36 = { face = 'ZH-StdFont', size = 36, decoration = THICK },
    ZoFontGamepadCondensed34 = { face = 'ZH-StdFont', size = 34, decoration = THICK },
    ZoFontGamepadCondensed27 = { face = 'ZH-StdFont', size = 27, decoration = THICK },
    ZoFontGamepadCondensed25 = { face = 'ZH-StdFont', size = 25, decoration = THICK },
    ZoFontGamepadCondensed22 = { face = 'ZH-StdFont', size = 22, decoration = THICK },
    ZoFontGamepadCondensed20 = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontGamepadCondensed18 = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontGamepadBold61 = { face = 'ZH-StdFont', size = 61, decoration = THICK },
    ZoFontGamepadBold54 = { face = 'ZH-StdFont', size = 54, decoration = THICK },
    ZoFontGamepadBold45 = { face = 'ZH-StdFont', size = 45, decoration = THICK },
    ZoFontGamepadBold42 = { face = 'ZH-StdFont', size = 42, decoration = THICK },
    ZoFontGamepadBold36 = { face = 'ZH-StdFont', size = 36, decoration = THICK },
    ZoFontGamepadBold34 = { face = 'ZH-StdFont', size = 34, decoration = THICK },
    ZoFontGamepadBold27 = { face = 'ZH-StdFont', size = 27, decoration = THICK },
    ZoFontGamepadBold25 = { face = 'ZH-StdFont', size = 25, decoration = THICK },
    ZoFontGamepadBold22 = { face = 'ZH-StdFont', size = 22, decoration = THICK },
    ZoFontGamepadBold20 = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontGamepadBold18 = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontGamepadChat = { face = 'ZH-StdFont', size = 20, decoration = THICK },
    ZoFontGamepadEditChat = { face = 'ZH-StdFont', size = 20, decoration = THICK },

    ZoFontGamepadBookPaper  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontGamepadBookSkin  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontGamepadBookRubbing  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontGamepadBookLetter  = { face = 'ZH-StdFont', size = 20, decoration = NONE },
    ZoFontGamepadBookNote  = { face = 'ZH-StdFont', size = 22, decoration = NONE },
    ZoFontGamepadBookScroll  = { face = 'ZH-StdFont', size = 26, decoration = NONE },
    ZoFontGamepadBookTablet  = { face = 'ZH-StdFont', size = 30, decoration = THICK },

    ZoFontGamepadBookPaperTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontGamepadBookSkinTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontGamepadBookRubbingTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontGamepadBookLetterTitle  = { face = 'ZH-StdFont', size = 30, decoration = NONE },
    ZoFontGamepadBookNoteTitle  = { face = 'ZH-StdFont', size = 32, decoration = NONE },
    ZoFontGamepadBookScrollTitle  = { face = 'ZH-StdFont', size = 34, decoration = NONE },
    ZoFontGamepadBookTabletTitle  = { face = 'ZH-StdFont', size = 48, decoration = THICK },

    ZoFontGamepadHeaderDataValue = { face = 'ZH-StdFont', size = 42, decoration = THICK },
}

local logical = {}
local decorations = { 'none', 'outline', 'thin-outline', 'thick-outline', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }

function FontaccessibilityConfig:FormatFont( fontEntry )
    local str = '%s|%d'
    if ( fontEntry.decoration ~= NONE ) then
        str = str .. '|%s'
    end

    fontEntry.face = string.gsub(fontEntry.face, '^Futura Std Condensed', 'ZH-StdFont', 1)
    return string.format( str, LMP:Fetch( 'font', fontEntry.face ), fontEntry.size or 10, fontEntry.decoration )
end

function FontaccessibilityConfig:OnLoaded()
    self.db = ZO_SavedVars:NewAccountWide( 'FONTACCESSIBILITY_DB', 1.6, nil, defaults )

    --fonts removed in Update 7
    self.db[ 'ZoLargeFontEdit' ]  = nil
    self.db[ 'ZoFontAnnounceSmall' ]  = nil
    self.db[ 'ZoFontBossName' ]  = nil
    self.db[ 'ZoFontBoss' ]  = nil

    for k,_ in pairs( defaults ) do
        tinsert( logical, k )
    end

    tsort( logical )

    self.config_panel = LAM:RegisterAddonPanel(self._name, {
        type = panel,
        name = 'Fontaccessibility',
        displayName = ZO_HIGHLIGHT_TEXT:Colorize('Fontaccessibility'),
        author = "Pawkette (updated by Garkin, Lucifer1309)",
        version = "1.6",
        slashCommand = "/fontcha",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    self:BeginAddingOptions()

    local UpdateHeaders
    UpdateHeaders = function(panel)
        if panel == self.config_panel then
            for i, gameFont in ipairs(logical) do
                local newFont = self:FormatFont( self.db[ gameFont ] )
                self._headers[ gameFont ] = _G[self._name .. '_header_' .. i].header
                self._headers[ gameFont ]:SetFont( newFont )
            end
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", UpdateHeaders)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", UpdateHeaders)
end

function FontaccessibilityConfig:BeginAddingOptions()
    local optionsData = {}

    for i, gameFont in ipairs(logical) do
        if ( self.db[ gameFont ] ) then
            CBM:FireCallbacks( 'FONTACCESSIBILITY_FONT_CHANGED', gameFont, self:FormatFont( self.db[ gameFont ] ) )

            tinsert( optionsData, {
                type = 'header',
                name = gameFont,
                reference = self._name .. '_header_' .. i,
                } )
            tinsert( optionsData, {
                type = 'dropdown',
                name = 'Font:',
                choices = LMP:List( 'font' ),
                getFunc = function() return self.db[ gameFont ].face end,
                setFunc = function( selection )  self:FontDropdownChanged( gameFont, selection ) end,
                default = defaults[ gameFont ].face,
                } )
            tinsert( optionsData, {
                type = 'slider',
                name = 'Size:',
                min = 5,
                max = 50,
                getFunc = function() return self.db[ gameFont ].size end,
                setFunc = function( size ) self:SliderChanged( gameFont, size ) end,
                default = defaults[ gameFont ].size,
                } )
            tinsert( optionsData, {
                type = 'dropdown',
                name = 'Decoration:',
                choices = decorations,
                getFunc = function() return self.db[ gameFont ].decoration end,
                setFunc = function( selection ) self:DecorationDropdownChanged( gameFont, selection ) end,
                default = defaults[ gameFont ].decoration,
                } )
        end
    end

    LAM:RegisterOptionControls(self._name, optionsData)
end

function FontaccessibilityConfig:FontDropdownChanged( gameFont, fontFace )
    self.db[ gameFont ].face = fontFace
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'FONTACCESSIBILITY_FONT_CHANGED', gameFont, newFont )
end

function FontaccessibilityConfig:SliderChanged( gameFont, size )
    self.db[ gameFont ].size = size
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'FONTACCESSIBILITY_FONT_CHANGED', gameFont, newFont )
end

function FontaccessibilityConfig:DecorationDropdownChanged( gameFont, decoration )
    self.db[ gameFont ].decoration = decoration
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'FONTACCESSIBILITY_FONT_CHANGED', gameFont, newFont )
end

CBM:RegisterCallback( 'FONTACCESSIBILITY_LOADED', function( ... ) FontaccessibilityConfig:OnLoaded( ... ) end )
