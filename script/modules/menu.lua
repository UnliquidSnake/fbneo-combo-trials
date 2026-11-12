-- Module for menu functionality

MenuRoutine = {}
MenuRoutine.Gui = {}

function MenuRoutine.OpenMenu()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block menuing while combo is going
	MenuState.CurrentMenu = Menus.MainMenu
	MenuState.IsActive = true
end
function MenuRoutine.CloseMenu()
	MenuState.IsActive = false
	-- Hacky fix to ensure no immediate button press happens upon exiting menu
	P1.CurrState.InputFreezeTimer = InputFreezeInterval
end
function MenuRoutine.SetOptionMTs(param_menu) -- Sets menu elements to inherit from already defined data structures
	for _, option in pairs(param_menu.Options) do
	    if (option.Type == "Button") then setmetatable(option, {__index = MenuClass.Button}) end
	    if (option.Type == "Toggle") then setmetatable(option, {__index = MenuClass.Toggle}) end
	end
end
function MenuRoutine.SetButtonsAutoWidth(param_menu) -- Automatically sets the width of menu buttons depending on text
	for _, option in pairs(param_menu.Options) do
		if (option.Type == "Button" and option.Width == "Auto") then option.Width = #option.Text*CharIntervalX + 7 end
	end
end
function MenuRoutine.CreateTrialButtons(param_trialmenu) -- Automatically populate trial menu with buttons based on their amount
	MenuState.MaxTrialButtonsY = math.floor((ScreenHeight-44) / 12)
	local ColumnInterval = (ScreenWidth-10)/MenuState.MaxTrialButtonsX
	local ButtonText = ""
	local HelperText = ""
	local NewButton = {}
	
	for i, trial in ipairs(Trial.TrialTable) do
		if i > MenuState.MaxTrialButtonsX*MenuState.MaxTrialButtonsY then break end
		ButtonText = "Trial " .. i
		if (trial.name ~= nil) then ButtonText = trial.name end
		HelperText = ""
		if (trial.description ~= nil) then HelperText = trial.description end

		NewButton =
		{
			Type = "Button",
			Text = ButtonText,
			Description = HelperText,
			OriginX = 10 + (i - ((i-1) % MenuState.MaxTrialButtonsY + 1))/MenuState.MaxTrialButtonsY*ColumnInterval,
			OriginY = 12*((i-1) % MenuState.MaxTrialButtonsY + 1)+8,
			IndexX = math.floor((i-1) / MenuState.MaxTrialButtonsY) + 1,
			IndexY = (i-1) % MenuState.MaxTrialButtonsY + 1,
			OnPress = function(self)
				Trial.CurrentNumber = i
				TrialRoutine.LoadSave(Trial.CurrentNumber)
				MenuRoutine.CloseMenu()
			end
		}
		table.insert(param_trialmenu.Options, NewButton)
	end
end
function MenuRoutine.UpdateVars() -- Update shorthands for current menu values
	MenuState.CurrentOptionID = MenuState.CurrentMenu.CurrentOptionID
	MenuState.CurrentOption = MenuState.CurrentMenu.Options[MenuState.CurrentOptionID]
	MenuState.CurrentState = nil
	MenuState.CurrentStateID = nil
	if (MenuState.CurrentOption.Type == "Toggle") then
		MenuState.CurrentStateID = MenuState.CurrentOption.CurrentStateID
		MenuState.CurrentState = MenuState.CurrentOption.States[MenuState.CurrentStateID]
		-- Update toggle vars
		Trial[MenuState.CurrentOption.Var] = MenuState.CurrentState.Value
	end
	-- Update whether button for reloading savestate is active
	Menus.MainMenu.Options[2].IsEnabled = (Trial.CurrentTrial.save ~= nil)
	if (Menus.MainMenu.CurrentOptionID == 2 and Trial.CurrentTrial.save == nil) then Menus.MainMenu.CurrentOptionID = 1 end
end
function MenuRoutine.ProcessInput() -- Scroll through buttons while menuing
	if not (MenuState.CurrentMenu == Menus.TrialMenu) then
		if (InputRoutine.IsPressed(P1, "Up")) then repeat -- accounting for disabled buttons (reload save)
			MenuState.CurrentMenu.CurrentOptionID = Helper.SelectPrevious(MenuState.CurrentMenu.CurrentOptionID, #MenuState.CurrentMenu.Options)
		until (MenuState.CurrentMenu.Options[MenuState.CurrentMenu.CurrentOptionID].IsEnabled == true)
		end
		if (InputRoutine.IsPressed(P1, "Down")) then repeat -- accounting for disabled buttons (reload save)
			MenuState.CurrentMenu.CurrentOptionID = Helper.SelectNext(MenuState.CurrentMenu.CurrentOptionID, #MenuState.CurrentMenu.Options)
		until (MenuState.CurrentMenu.Options[MenuState.CurrentMenu.CurrentOptionID].IsEnabled == true)
		end
		-- Scrolling through options in a toggle
		if (InputRoutine.IsPressed(P1, "Left") and MenuState.CurrentOption.Type == "Toggle" and MenuState.CurrentOption.IsEnabled) then 
			MenuState.CurrentOption.CurrentStateID = Helper.SelectPrevious(MenuState.CurrentStateID, #MenuState.CurrentOption.States) end
		if (InputRoutine.IsPressed(P1, "Right") and MenuState.CurrentOption.Type == "Toggle" and MenuState.CurrentOption.IsEnabled) then 
			MenuState.CurrentOption.CurrentStateID = Helper.SelectNext(MenuState.CurrentStateID, #MenuState.CurrentOption.States) end
	end
	-- Trial menu has a 2d coordinate system of buttons, process all inputs differently
	if (MenuState.CurrentMenu == Menus.TrialMenu) then
		local ButtonIndexX = Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID].IndexX
		local ButtonIndexY = Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID].IndexY
		if (InputRoutine.IsPressed(P1, "Up") and MenuState.MaxTrialButtonsY > 1) then 
			if not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID-1] == nil or ButtonIndexY == 1) then
				Menus.TrialMenu.CurrentOptionID = Helper.SelectPrevious(Menus.TrialMenu.CurrentOptionID, #Menus.TrialMenu.Options)
			else
				Menus.TrialMenu.CurrentOptionID = math.min(#Menus.TrialMenu.Options, (ButtonIndexX-1)*MenuState.MaxTrialButtonsY + MenuState.MaxTrialButtonsY)
			end
		end
		if (InputRoutine.IsPressed(P1, "Down") and MenuState.MaxTrialButtonsY > 1) then 
			if not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID+1] == nil or ButtonIndexY == MenuState.MaxTrialButtonsY) then
				Menus.TrialMenu.CurrentOptionID = Helper.SelectNext(Menus.TrialMenu.CurrentOptionID, #Menus.TrialMenu.Options)
			else
				Menus.TrialMenu.CurrentOptionID = (ButtonIndexX-1)*MenuState.MaxTrialButtonsY + 1
			end
		end
		if (InputRoutine.IsPressed(P1, "Left") and #Menus.TrialMenu.Options > MenuState.MaxTrialButtonsY and MenuState.MaxTrialButtonsX > 1) then 
			if not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID-MenuState.MaxTrialButtonsY] == nil or ButtonIndexX == 1) then
				Menus.TrialMenu.CurrentOptionID = Menus.TrialMenu.CurrentOptionID-MenuState.MaxTrialButtonsY
			elseif not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID+MenuState.MaxTrialButtonsY] == nil) then
				if not ((MenuState.MaxTrialButtonsX-1)*MenuState.MaxTrialButtonsY + ButtonIndexY > #Menus.TrialMenu.Options) then
					Menus.TrialMenu.CurrentOptionID = (MenuState.MaxTrialButtonsX-1)*MenuState.MaxTrialButtonsY + ButtonIndexY
				else
					Menus.TrialMenu.CurrentOptionID = (MenuState.MaxTrialButtonsX-2)*MenuState.MaxTrialButtonsY + ButtonIndexY
				end
			end
		end
		if (InputRoutine.IsPressed(P1, "Right") and #Menus.TrialMenu.Options > MenuState.MaxTrialButtonsY and MenuState.MaxTrialButtonsX > 1) then 
			if not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID+MenuState.MaxTrialButtonsY] == nil or ButtonIndexX == MenuState.MaxTrialButtonsX) then
				Menus.TrialMenu.CurrentOptionID = Menus.TrialMenu.CurrentOptionID+MenuState.MaxTrialButtonsY
			elseif not (Menus.TrialMenu.Options[Menus.TrialMenu.CurrentOptionID-MenuState.MaxTrialButtonsY] == nil) then
				Menus.TrialMenu.CurrentOptionID = ButtonIndexY
			end
		end
	end
	-- Confirm button signals that a menu button is pressed
	if (InputRoutine.IsPressed(P1, Button_Confirm) and MenuState.CurrentOption.Type == "Button" and MenuState.CurrentOption.IsEnabled) then MenuState.CurrentOption:OnPress() end
	-- Back button to return to previous menu or exit out
	if (InputRoutine.IsPressed(P1, Button_Back)) then
		if (MenuState.CurrentMenu.PrevMenu == nil) then MenuRoutine.CloseMenu()
		else MenuState.CurrentMenu = MenuState.CurrentMenu.PrevMenu
		end
	end
end
-- Hotkey functions
function MenuRoutine.ToggleMenu() -- This is what happens when you press Alt+1
	if MenuState.IsActive then MenuRoutine.CloseMenu() return end
	MenuRoutine.OpenMenu()
end
function MenuRoutine.OpenTrialMenu()
	if (Trial.CurrState.TrialProgress ~= 0 or MenuState.IsActive == true) then return end -- Block menuing while combo is going or menu is open
	MenuState.CurrentMenu = Menus.TrialMenu
	MenuState.IsActive = true
end
-- Drawing functions
function MenuRoutine.Gui.DrawBox(param_menu) -- Draws area of current menu
	gui.box(
		param_menu.OriginX, param_menu.OriginY,
		param_menu.OriginX+param_menu.Width, param_menu.OriginY+param_menu.Height,
		"white", "grey"
	)
	gui.text(param_menu.OriginX+5, param_menu.OriginY+3, param_menu.Title)
	gui.line( -- Draw lines to denote space for helper texts
		param_menu.OriginX+1, param_menu.OriginY+param_menu.Height-24,
		param_menu.OriginX+param_menu.Width-1, param_menu.OriginY+param_menu.Height-24,
		"red"
	)
	gui.line(
		param_menu.OriginX+1, param_menu.OriginY+param_menu.Height-12,
		param_menu.OriginX+param_menu.Width-1, param_menu.OriginY+param_menu.Height-12,
		"red"
	)
	gui.text( -- Draw input helper text
		param_menu.OriginX+4, param_menu.OriginY+param_menu.Height-9,
		InputHelperText, Config.MenuInputHelperTextColor
	)
end
function MenuRoutine.Gui.DrawButton(param_button, param_txtcolor)
	gui.box(
		MenuState.CurrentMenu.OriginX+param_button.OriginX, MenuState.CurrentMenu.OriginY+param_button.OriginY,
		MenuState.CurrentMenu.OriginX+param_button.OriginX+param_button.Width, MenuState.CurrentMenu.OriginY+param_button.OriginY+param_button.Height,
		"white", "grey"
	)
	gui.text(
		MenuState.CurrentMenu.OriginX+param_button.OriginX+4, MenuState.CurrentMenu.OriginY+param_button.OriginY+2,
		param_button.Text, param_txtcolor
	)
end
function MenuRoutine.Gui.DrawToggle(param_toggle, param_txtcolor)
	gui.text(
		MenuState.CurrentMenu.OriginX+param_toggle.OriginX+4, MenuState.CurrentMenu.OriginY+param_toggle.OriginY+2,
		param_toggle.Text, param_txtcolor
	)
	gui.text(
		MenuState.CurrentMenu.OriginX+param_toggle.TogglePosX, MenuState.CurrentMenu.OriginY+param_toggle.OriginY+2,
		"< " .. param_toggle.States[param_toggle.CurrentStateID].Text .. " >", param_txtcolor
	)
end
function MenuRoutine.Gui.DrawOptionHelperText(param_menu, param_option, param_txtcolor) -- Text explanation at bottom of menu
	gui.text(param_menu.OriginX+4, param_menu.OriginY+param_menu.Height-21, param_option.Description)
end

return MenuRoutine