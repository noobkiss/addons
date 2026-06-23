---------------------------------------
-- German localization for TextureIt --
-- translated by Baertram
---------------------------------------
-- luacheck: push ignore 631  (--IceH:Ignore long lines)
local strings = {
	-- Tree widget:  --
	TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE	= "Klicken für Suche / Ausgewählter Dateipfad und -name wird hier angezeigt",
	TEXTUREIT_TREE_EBOX_SEARCH_TTIP   		= "Wenn du eine Textur auswählst wird ihr Dateipfad & -name hier angezeigt. Du kannst dann STRG+C drücken, um den Pfad zu kopieren.\n|cFF0000Du musst STRG+C drücken bevor du irgendeine andere Aktion im Fenster durchführst und bevor die Zeile den Fokus verliert!\n|r|c00FFFFDu kannst die Zeile doppelt klicken, um den Text wieder zu markieren.\n|r|cFFFF00Trage manuell einen Pfad & Dateinamen ein, um die Textur rechts anzuzeigen.\n|r|cFFA500Gebe einen Suchbegriff ein und drücke die ENTER Taste|r|cFF0000 (maximal 250 Suchergebnisse werden angezeigt. Gebe KEINEN Pfad mit an!).|r",
	TEXTUREIT_TREE_LBL_FOUND				= "Texturen gefunden.",
	TEXTUREIT_TREE_BTN_RESET_LIST 			= "Liste zurücksetzen",
	-- View  widget:
	TEXTUREIT_VIEW_LBL_ORIG_SIZE 			= "Originalgröße ",
	TEXTUREIT_VIEW_LBL_CURRENT_SIZE			= "Aktuelle Größe: ",
	TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE		= "Ansichtsgröße: ",
	TEXTUREIT_VIEW_BTN_ACTUAL_SIZE_TOGGLE	= "Größe umschalten",
	TEXTUREIT_VIEW_LBL_BKGROUND_SET_TO		= "Hintergrund: ",
	-- Background Combo box Lines:
	TEXTUREIT_VIEW_CMBX_BKGROUND_1			= "Durchsichtig",
	TEXTUREIT_VIEW_CMBX_BKGROUND_2			= "Schwarz",
	TEXTUREIT_VIEW_CMBX_BKGROUND_3			= "Weiß",
	TEXTUREIT_VIEW_CMBX_BKGROUND_4			= "Grau",
	TEXTUREIT_VIEW_CMBX_BKGROUND_5			= "Rot",
	-- Animate PopUp Button
	TEXTUREIT_VIEW_BTN_ANIMATE 				= "A",
	TEXTUREIT_VIEW_BTN_ANIMATE_TTIP			= "Popup-Fenster \'Animation\' anzeigen",
	-- Animate Popup widget: --
	TEXTUREIT_ANIMATE_LBL_WIDTH				= "Zell-Breite: ",
	TEXTUREIT_ANIMATE_LBL_HEIGHT 			= "Zell-Höhe: ",
	TEXTUREIT_ANIMATE_LBL_FPS 				= "Framerate: ",
	-- Execute Animation button
	TEXTUREIT_ANIMATE_BTN_ANIMATE			= "Animieren",
	-- Settings Menu
	TEXTUREIT_SETT_DEBUG_MSGS				= "Aktivieren Sie Informations- und Debug-Meldungen:",
	TEXTUREIT_SETT_DEBUG_MSGS_TTIP			= "De/Aktivieren Sie Informations- und Debug-Meldungen im Chat-Fenster.",
	TEXTUREIT_SETT_TOOLTIPS					= "De/Aktivieren Tool Tips:",
	TEXTUREIT_SETT_TOOLTIPS_TTIP			= "De/Aktivieren Sie schwebende Notizen tooltips auf einigen Elementen der Benutzeroberfläche.",
	TEXTUREIT_SETT_START_HIDDEN				= "Blenden Sie das Fenster beim Laden aus:",
	TEXTUREIT_SETT_START_HIDDEN_TTIP		= "Anzeigen oder Ausblenden des TextureIt-Fensters beim Laden / Neuladen der Benutzeroberfläche (siehe auch Bindungen)",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS		= "Maximale Anzahl der Suchergebnisse:",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP  = "Erhöhen / Verringern Sie die maximale Anzahl von Ergebnissen, wenn Sie eine Textur-Suche durchführen",
	TEXTUREIT_SETT_SLASHCOMM_TITLE			= "Slash-Befehle ('Slash Commands')",
	TEXTUREIT_SETT_SLASHCOMM_DESC			= "/textureit -or- /texit: Hauptfenster ein- oder ausblenden.\n/texit-menu: Öffnen Sie das Einstellungsmenü.",
	-- Bindings
	SI_BINDING_NAME_TEXTUREIT_TOGGLE_MAIN	= "Schaltet das TextureIt vollständig um."
}
-- luacheck: pop  (re-enable warn long lines)
for stringId, stringValue in pairs(strings) do
	--ZO_CreateStringId(stringId, stringValue)
	--SafeAddVersion(stringId, 1)
	SafeAddString(_G[stringId],stringValue,2 )
end
