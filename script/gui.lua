-- GUI functionality; runs every frame the display gets updated after the main execution routines

local GuiRoutine = {}

function GuiRoutine.GameGui() -- STUB. Define in game script
end
function GuiRoutine.TrialGui()
	TrialRoutine.Gui.DisplayHeader()
	if (Trial.CurrState.IsCompleted == true) then TrialRoutine.Gui.DisplaySuccessText() end
	TrialRoutine.Gui.DisplayScrollMarkers()
	TrialRoutine.Gui.DisplayActionList()
end
function GuiRoutine.MenuGui()
	-- Show nothing unless menu is active
	if (MenuState.IsActive == false) then return end
	-- Draw menu
	MenuRoutine.Gui.DrawBox(MenuState.CurrentMenu)
	-- Draw menu buttons & toggles
	for _, option in pairs(MenuState.CurrentMenu.Options) do
		local TextColor = Config.MenuDefaultTextColor
		if (option == MenuState.CurrentOption) then TextColor = Config.MenuHighlightTextColor end
		if not option.IsEnabled then TextColor = Config.MenuDisabledTextColor end
		if (option.Type == "Button") then MenuRoutine.Gui.DrawButton(option, TextColor) end
		if (option.Type == "Toggle") then MenuRoutine.Gui.DrawToggle(option, TextColor) end
	end
	MenuRoutine.Gui.DrawOptionHelperText(MenuState.CurrentMenu, MenuState.CurrentOption, Config.MenuHelperTextColor)
end
function GuiRoutine.DebugGui() -- STUB. Define in game script
end

return GuiRoutine