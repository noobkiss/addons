------------------------------------------------
-- TextureIt - Language localization: English --

------------------------------------------------
-- luacheck: push ignore 631  (--IceH:Ignore long lines)
local strings = {
	-- Tree widget:  --
	TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE	= "Click to search / Selected texture path will be placed here",
	TEXTUREIT_TREE_EBOX_SEARCH_TTIP   		= "When you select a texture its path will be placed here & automatically selected, you can then press cntrl+c to copy.\nYou must press ctrl+c before any other actions or the window will loose focus.\nYou can double click the box to reselect it at any time for copying.\nManually enter a texture path to display it in the window.\nEnter a string to search for (a maximum of 250 texture matches will be displayed, do NOT include texture paths).",
	TEXTUREIT_TREE_LBL_FOUND				= "Textures found.",
	TEXTUREIT_TREE_BTN_RESET_LIST 			= "Reset List",
	-- View  widget:
	TEXTUREIT_VIEW_LBL_ORIG_SIZE 			= "Original Size: ",
	TEXTUREIT_VIEW_LBL_CURRENT_SIZE			= "Current size: ",
	TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE		= "Viewport size: ",
	TEXTUREIT_VIEW_BTN_ACTUAL_SIZE_TOGGLE	= "Toggle actual size",
	TEXTUREIT_VIEW_LBL_BKGROUND_SET_TO		= "Background Set to: ",
	-- Background Combo box Lines:
	TEXTUREIT_VIEW_CMBX_BKGROUND_1			= "Hidden",
	TEXTUREIT_VIEW_CMBX_BKGROUND_2			= "Black",
	TEXTUREIT_VIEW_CMBX_BKGROUND_3			= "White",
	TEXTUREIT_VIEW_CMBX_BKGROUND_4			= "Gray",
	TEXTUREIT_VIEW_CMBX_BKGROUND_5			= "Red",
	-- Animate PopUp Button
	TEXTUREIT_VIEW_BTN_ANIMATE 				= "A",
	TEXTUREIT_VIEW_BTN_ANIMATE_TTIP			= "Show the Animate pop-up window",
	-- Animate Popup widget: --
	TEXTUREIT_ANIMATE_LBL_WIDTH				= "Cells width: ",
	TEXTUREIT_ANIMATE_LBL_HEIGHT 			= "Cells height: ",
	TEXTUREIT_ANIMATE_LBL_FPS 				= "Framerate: ",
	-- Execute Animation button
	TEXTUREIT_ANIMATE_BTN_ANIMATE			= "Animate",
	-- Settings Menu
	TEXTUREIT_SETT_DEBUG_MSGS				= "Enable Info & Debug Messages:",
	TEXTUREIT_SETT_DEBUG_MSGS_TTIP			= "De/Activate Informational and Debug messages to chat window.",
	TEXTUREIT_SETT_TOOLTIPS					= "Enable Tool Tips:",
	TEXTUREIT_SETT_TOOLTIPS_TTIP			= "De/Activate hovering tooltips on some UI elements.",
	TEXTUREIT_SETT_START_HIDDEN				= "Hide the Window at Start:",
	TEXTUREIT_SETT_START_HIDDEN_TTIP		= "Show or Hide the TextureIt window on UI load/reload (also see Bindings)",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS		= "Max number of search results:",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP  = "Inc/Decrease the maximum number of results when making a texture search by name",
	TEXTUREIT_SETT_SLASHCOMM_TITLE			= "Slash Commands",
	TEXTUREIT_SETT_SLASHCOMM_DESC			= "/textureit -or- /texit: Show / Hide the main window.\n/texit-menu: Open the settings menu.",
	-- Bindings
	SI_BINDING_NAME_TEXTUREIT_TOGGLE_MAIN	= "Toggle the TextureIt window.",
}
-- luacheck: pop  (re-enable warn long lines)
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
