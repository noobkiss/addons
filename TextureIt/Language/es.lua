------------------------------------------------
-- TextureIt - Language localization: Spanish --
-- Provided by: IceHeart
------------------------------------------------
-- luacheck: push ignore 631  (--IceH:Ignore long lines)

local strings = {
	-- Tree widget:  --
	TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE	= "Clic para buscar / El trayecto hacia la textura aparecerá aquí.",
	TEXTUREIT_TREE_EBOX_SEARCH_TTIP   		= "Cuando seleccione una textura su trayecto aparecerá aquí, ya seleccionado; Presione Ctrl+c para copiar.\n Asegúrese de dar ctrl+c antes de cualquier otra acción, o la ventana perderá su foco. Puede hacer doble-clic para reseleccionar de nuevo.\nEntre un trayecto para presentar la textura correspondiente.\nEntre una palabra o texto parcial para hacer una búsqueda (Máximo de 250 coincidencias); No incluya trayectos parciales.",
	TEXTUREIT_TREE_LBL_FOUND				= "Texturas encontradas.",
	TEXTUREIT_TREE_BTN_RESET_LIST 			= "Refrescar Lista",
	-- View  widget:
	TEXTUREIT_VIEW_LBL_CURRENT_SIZE			= "Tamaño Actual: ",
	TEXTUREIT_VIEW_LBL_ORIG_SIZE 			= "Tamaño Original: ",
	TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE		= "Tamaño Ventana: ",
	TEXTUREIT_VIEW_BTN_ACTUAL_SIZE_TOGGLE	= "Alternar tamaño",
	TEXTUREIT_VIEW_LBL_BKGROUND_SET_TO		= "Fondo puesto en: ",
	-- Background Combo box Lines:
	TEXTUREIT_VIEW_CMBX_BKGROUND_1			= "Oculto",
	TEXTUREIT_VIEW_CMBX_BKGROUND_2			= "Negro",
	TEXTUREIT_VIEW_CMBX_BKGROUND_3			= "Blanco",
	TEXTUREIT_VIEW_CMBX_BKGROUND_4			= "Gris",
	TEXTUREIT_VIEW_CMBX_BKGROUND_5			= "Rojo",
	-- Animate PopUp Button
	TEXTUREIT_VIEW_BTN_ANIMATE 				= "A",
	TEXTUREIT_VIEW_BTN_ANIMATE_TTIP			= "Mostrar la ventana de animación",
	-- Animate Popup widget: --
	TEXTUREIT_ANIMATE_LBL_WIDTH				= "Ancho de Celdas: ",
	TEXTUREIT_ANIMATE_LBL_HEIGHT 			= "Altura de Celdas: ",
	TEXTUREIT_ANIMATE_LBL_FPS 				= "Velocidad (framerate): ",
	-- Execute Animation button
	TEXTUREIT_ANIMATE_BTN_ANIMATE			= "Animar",
	-- Settings Menu
	TEXTUREIT_SETT_DEBUG_MSGS				= "Activar Mensajes Informativos:",
	TEXTUREIT_SETT_DEBUG_MSGS_TTIP			= "Des/Activar mensajes de debug e informativos hacia la ventana de conversación.",
	TEXTUREIT_SETT_TOOLTIPS					= "Activar notas flotantes:",
	TEXTUREIT_SETT_TOOLTIPS_TTIP			= "Des/Activar las notas flotantes en algunos elementos.",
	TEXTUREIT_SETT_START_HIDDEN				= "Ocultar la ventana al inicio :",
	TEXTUREIT_SETT_START_HIDDEN_TTIP		= "Mostrar/Ocultar la ventana al inicio o en recarga (ver también Conexiones/'Bindings')",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS		= "Máximo número de resultados de búsqueda:",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP  = "Aumentar/Reducir el número de resultados cuando se realiza una búsqueda de texturas por nombre.",
	TEXTUREIT_SETT_SLASHCOMM_TITLE			= "Comandos de línea ('Slash Commands')",
	TEXTUREIT_SETT_SLASHCOMM_DESC			= "/textureit -or- /texit: Des/Activar la ventana principal.\n/texit-menu: Abrir el menú de configuración.",
	-- Bindings
	SI_BINDING_NAME_TEXTUREIT_TOGGLE_MAIN	= "Des/Activa la ventana completa de TextureIt"
}
-- luacheck: pop  (re-enable warn long lines)
for stringId, stringValue in pairs(strings) do
	--ZO_CreateStringId(stringId, stringValue)
	--SafeAddVersion(stringId, 1)
	SafeAddString(_G[stringId],stringValue,2 )
end
