----------------------------------------
-- Russian localization for TextureIt --
-- Original translation by ForgottenLight; Additional lines by Zelenin
----------------------------------------
-- luacheck: push ignore 631  (--IceH:Ignore long lines)
local strings = {
    -- Tree widget:  --
	TEXTUREIT_TREE_EBOX_SEARCH_PATH_HERE	= "Нажмите для поиска / Путь выбранной текстуры будет размещен здесь",
	TEXTUREIT_TREE_EBOX_SEARCH_TTIP   		= "Когда вы выбираете текстуру, ее путь будет размещен здесь и автоматически отмечен, вы можете нажать ctrl+c для копирования.\nВы должны нажать ctrl+c перед любыми другими действиями или окно потеряет фокус.\nВ любой момент вы можете заново двойным кликом выделить текст для копирования.\nВручную введите путь текстуры, чтобы отобразить его в окне.\nВведите строку для поиска (отобразится максимум 250 совпадений текстур, НЕ включайте пути текстуры).",
	TEXTUREIT_TREE_LBL_FOUND				= "Текстуры найдены.",
	TEXTUREIT_TREE_BTN_RESET_LIST 			= "Сбросить список",
	-- View  widget:
	TEXTUREIT_VIEW_LBL_ORIG_SIZE 			= "Оригинальный размер: ",
	TEXTUREIT_VIEW_LBL_CURRENT_SIZE			= "Текущий размер: ",
	TEXTUREIT_VIEW_LBL_VIEWPORT_SIZE		= "Размер окна: ",
	TEXTUREIT_VIEW_BTN_ACTUAL_SIZE_TOGGLE	= "Перекл. реальный размер",
	TEXTUREIT_VIEW_LBL_BKGROUND_SET_TO		= "Перекл. фон: ",
	-- Background Combo box Lines:
	TEXTUREIT_VIEW_CMBX_BKGROUND_1			= "cкрытый",
	TEXTUREIT_VIEW_CMBX_BKGROUND_2			= "черный",
	TEXTUREIT_VIEW_CMBX_BKGROUND_3			= "белый",
	TEXTUREIT_VIEW_CMBX_BKGROUND_4			= "Серый",
	TEXTUREIT_VIEW_CMBX_BKGROUND_5			= "красный",
	-- Animate PopUp Button
	TEXTUREIT_VIEW_BTN_ANIMATE 				= "A",
	TEXTUREIT_VIEW_BTN_ANIMATE_TTIP			= "Показать окно анимации",
	-- Animate Popup widget: --
	TEXTUREIT_ANIMATE_LBL_WIDTH				= "Ширина ячейки",
	TEXTUREIT_ANIMATE_LBL_HEIGHT 			= "Высота ячейки",
	TEXTUREIT_ANIMATE_LBL_FPS 				= "FPS: ",
	-- Execute Animation button
	TEXTUREIT_ANIMATE_BTN_ANIMATE			= "Анимация",
	-- Settings Menu
	TEXTUREIT_SETT_DEBUG_MSGS				= "Включить информационные / отладочные сообщения:",
	TEXTUREIT_SETT_DEBUG_MSGS_TTIP			= "(Де-)активировать информационные и отладочные сообщения в окне чата.",
	TEXTUREIT_SETT_TOOLTIPS					= "Включить подсказки:",
	TEXTUREIT_SETT_TOOLTIPS_TTIP			= "Отключить / активировать всплывающие подсказки для некоторых элементов интерфейса.",
	TEXTUREIT_SETT_START_HIDDEN				= "Скрыть окно при запуске:",
	TEXTUREIT_SETT_START_HIDDEN_TTIP		= "Показать или скрыть окно TextureIt при загрузке / перезагрузке пользовательского интерфейса (также см. Привязки ('Bindings'))",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS		= "Максимальное количество результатов поиска:",
	TEXTUREIT_SETT_MAX_SEARCH_RESULTS_TTIP  = "Изменить максимальное количество результатов при поиске текстур.",
	TEXTUREIT_SETT_SLASHCOMM_TITLE			= "Команды",
	TEXTUREIT_SETT_SLASHCOMM_DESC			= "/textureit -or- /texit: Показать / Скрыть главное окно.\n/texit-menu: Откройте меню конфигурации.",
	-- Bindings
	SI_BINDING_NAME_TEXTUREIT_TOGGLE_MAIN	= "Изменить состояние окна TextureIt."
}
-- luacheck: pop  (re-enable warn long lines)
for stringId, stringValue in pairs(strings) do
	--ZO_CreateStringId(stringId, stringValue)
	--SafeAddVersion(stringId, 1)
	SafeAddString(_G[stringId],stringValue,2 )
end