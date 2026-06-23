---------------------------------------
-- French localization for TextureIt --
-- Translated by vvarden
---------------------------------------
-- luacheck: push ignore 631  (--IceH:Ignore long lines)
local strings = {
	-- Tree widget:  --
	TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE	= "Cliquez pour rechercher / Le chemin de la texture sélectionnée sera inscrit ici",
	TEXTUREIT_TREE_EBOX_SEARCH_TTIP   		= "Quand vous sélectionnez un chemin d'une texture, il sera écrit ici & automatiquement sélectionné. Vous pouvez appuyez sur CTRL+c pour le copier.\nVous devez appuyez sur CTRL+c AVANT toute autre action sinon vous ne pourrez pas procéder à la copie du chemin.\nVous pouvez double-cliquer dans le champs pour sélectionner à tout moment son contenu pour la copie.\nEntrez manuellement le chemin d'une texture pour l'afficher dans la fenêtre.\nEntrez une chaîne de caractères pour lancer la recherche (Un maximum de 250 textures correspondantes peuvent être affichées, ne PAS inclure de chemins de textures).",
	TEXTUREIT_TREE_LBL_FOUND				= "Textures trouvées.",
	TEXTUREIT_TREE_BTN_RESET_LIST 			= "Réinitialiser liste",
	-- View  widget:
	TEXTUREIT_VIEW_LBL_ORIG_SIZE 			= "Dim. original: ",
	TEXTUREIT_VIEW_LBL_CURRENT_SIZE			= "Dim. actuelle: ",
	TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE		= "Dim. Viewport: ",
	TEXTUREIT_VIEW_BTN_ACTUAL_SIZE_TOGGLE	= "Basculer Dim.",
	TEXTUREIT_VIEW_LBL_BKGROUND_SET_TO		= "Image de fond: ",
	-- Background Combo box Lines:
	TEXTUREIT_VIEW_CMBX_BKGROUND_1			= "Caché",
	TEXTUREIT_VIEW_CMBX_BKGROUND_2			= "Noir",
	TEXTUREIT_VIEW_CMBX_BKGROUND_3			= "Blanc",
	TEXTUREIT_VIEW_CMBX_BKGROUND_4			= "Gris",
	TEXTUREIT_VIEW_CMBX_BKGROUND_5			= "Rouge",
	-- Animate PopUp Button
	TEXTUREIT_VIEW_BTN_ANIMATE 				= "A",
	TEXTUREIT_VIEW_BTN_ANIMATE_TTIP			= "Afficher la fenêtre contextuelle d'Animer",
	-- Animate Popup widget: --
	TEXTUREIT_ANIMATE_LBL_WIDTH				= "Larg. cellules",
	TEXTUREIT_ANIMATE_LBL_HEIGHT 			= "Haut. cellules",
	TEXTUREIT_ANIMATE_LBL_FPS 				= "IPS/FPS",
	-- Execute Animation button
	TEXTUREIT_ANIMATE_BTN_ANIMATE			= "Animer",
	-- Settings Menu
	TEXTUREIT_SETT_DEBUG_MSGS				= "Activer messages d'information / de débogage:",
	TEXTUREIT_SETT_DEBUG_MSGS_TTIP			= "Dés/Activer les messages d'information et de débogage dans la fenêtre de discussion (chat).",
	TEXTUREIT_SETT_TOOLTIPS					= "Activer les info-bulles ('tooltips'):",
	TEXTUREIT_SETT_TOOLTIPS_TTIP			= "Des/Activer des info-bulles sur certains éléments de l'interface .",
	TEXTUREIT_SETT_START_HIDDEN				= "Masquer la fenêtre à l'initialisation::",
	TEXTUREIT_SETT_START_HIDDEN_TTIP		= "Afficher ou masquer la fenêtre TextureIt lors du chargement / rechargement de l'interface (voir Liaisons('Bindings'))",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS		= "Maximum de résultats de recherche:",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP  = "Augmente / diminue le nombre maximal de résultats lors d'une recherche de texture.",
	TEXTUREIT_SETT_SLASHCOMM_TITLE			= "Commandes ('Slash Commands')",
	TEXTUREIT_SETT_SLASHCOMM_DESC			= "/textureit -or- /texit: Afficher / masquer la fenêtre principale.\n/texit-menu: Ouvrez le menu de configuration.",
	-- Bindings
	SI_BINDING_NAME_TEXTUREIT_TOGGLE_MAIN	= "Bascule complètement la fenêtre de TextureIt."
}
-- luacheck: pop  (re-enable warn long lines)
for stringId, stringValue in pairs(strings) do
	--ZO_CreateStringId(stringId, stringValue)
	--SafeAddVersion(stringId, 1)
	SafeAddString(_G[stringId],stringValue,2 )
end
