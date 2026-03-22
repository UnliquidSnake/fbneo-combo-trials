-------------------------------------------------------Variables-------------------------------------------------------
Menu.CurrentMenu = MainMenu -- pointer to menu object
Menu.IsActive = false -- bool
-- Values for populating trial menu
Menu.MaxTrialButtonsX = 2
Menu.MaxTrialButtonsY = 10 -- will be filled in automatically during CreateTrialMenuButtons()
-- Shorthands for current menu values
Menu.CurrentOption = nil -- pointer to current active option
Menu.CurrentOptionID = 1 -- int
Menu.CurrentState = nil -- pointer to current state of active option
Menu.CurrentStateID = nil -- int
-------------------------------------------------------Classes for menu objects-------------------------------------------------------
MenuBox =
{
	PrevMenu = nil,
	Title = "",
	OriginX = 0,
	OriginY = 0,
	Width = ScreenWidth-1,
	Height = ScreenHeight-1,
	-- add buttons & toggles for menu
	Options =
	{

	},
	CurrentOptionID = 1,
}
	MenuButton =
	{
		Text = "",
		Description = "",
		OriginX = 0,
		OriginY = 0,
		Width = "Auto",
		Height = 10,
		OnPress = function(self)
			Menu.IsActive = false
		end
	}
	MenuToggle =
	{
		Var = nil,
		Text = "",
		Description = "",
		OriginX = 0,
		OriginY = 0,
		TogglePosX = 100,
		Width = 50,
		Height = 10,
		-- add states for toggle
		States =
		{

		},
		CurrentStateID = 1,
	}
		MenuToggleState =
		{Value = 0, Text = ""}
-------------------------------------------------------Menus-------------------------------------------------------
MainMenu =
{
	PrevMenu = nil,
	Title = "Main Menu",
	Options =
	{
		{
			Type = "Button",
			Text = "Resume",
			Description = "Close this menu and return to the game.",
			OriginX = 10,
			OriginY = 20,
			OnPress = function(self)
				Menu.IsActive = false
			end
		},
		{
			Type = "Button",
			Text = "Next Trial",
			Description = "Attempt the next trial in sequence.",
			OriginX = 10,
			OriginY = 32,
			OnPress = function(self)
				SelectNextTrial()
				Menu.IsActive = false
			end
		},
		{
			Type = "Button",
			Text = "Previous Trial",
			Description = "Attempt the previous trial in sequence.",
			OriginX = 10,
			OriginY = 44,
			OnPress = function(self)
				SelectPreviousTrial()
				Menu.IsActive = false
			end
		},
		{
			Type = "Button",
			Text = "Select Trial",
			Description = "Select a different trial to attempt.",
			OriginX = 10,
			OriginY = 56,
			OnPress = function(self)
				Menu.CurrentMenu = TrialMenu
			end
		},
		{
			Type = "Toggle",
			Var = "ShowActionInput",
			Text = "Trial Display",
			Description = "Toggle between displaying move names or commands (numpad notation).",
			OriginX = 10,
			OriginY = 68,
			States =
			{
				{Value = false, Text = "Move Names"},
				{Value = true, Text = "Inputs"},
			}
		},
	},
} setmetatable(MainMenu, {__index = MenuBox})
TrialMenu =
{
	PrevMenu = MainMenu,
	Title = "Trial Menu",
	Options = {}, -- will be filled in via CreateTrialMenuButtons()
} setmetatable(TrialMenu, {__index = MenuBox})
-------------------------------------------------------Functions-------------------------------------------------------
local function SetMenuOptionMTs(param_menu)
	for i = 1, #param_menu.Options do
	    if (param_menu.Options[i].Type == "Button") then setmetatable(param_menu.Options[i], {__index = MenuButton}) end
	    if (param_menu.Options[i].Type == "Toggle") then setmetatable(param_menu.Options[i], {__index = MenuToggle}) end
	end
end
-- Drawing functions
local function DrawMenuBox(param_menu, param_inputhelp_txtcolor)
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
		InputHelperText, param_inputhelp_txtcolor
	)
end
local function DrawMenuButton(param_button, param_txtcolor)
	gui.box(
		Menu.CurrentMenu.OriginX+param_button.OriginX, Menu.CurrentMenu.OriginY+param_button.OriginY,
		Menu.CurrentMenu.OriginX+param_button.OriginX+param_button.Width, Menu.CurrentMenu.OriginY+param_button.OriginY+param_button.Height,
		"white", "grey"
	)
	gui.text(
		Menu.CurrentMenu.OriginX+param_button.OriginX+4, Menu.CurrentMenu.OriginY+param_button.OriginY+2,
		param_button.Text, param_txtcolor
	)
end
local function DrawMenuToggle(param_toggle, param_txtcolor)
	gui.text(
		Menu.CurrentMenu.OriginX+param_toggle.OriginX+4, Menu.CurrentMenu.OriginY+param_toggle.OriginY+2,
		param_toggle.Text, param_txtcolor
	)
	gui.text(
		Menu.CurrentMenu.OriginX+param_toggle.TogglePosX, Menu.CurrentMenu.OriginY+param_toggle.OriginY+2,
		"< " .. param_toggle.States[param_toggle.CurrentStateID].Text .. " >", param_txtcolor
	)
end
local function DrawMenuOptionHelperText(param_menu, param_option, param_txtcolor)
	gui.text(param_menu.OriginX+4, param_menu.OriginY+param_menu.Height-21, param_option.Description)
end
local function SetButtonsAutoWidth(param_menu)
	for i = 1, #param_menu.Options do
		if (param_menu.Options[i].Type == "Button" and param_menu.Options[i].Width == "Auto") then param_menu.Options[i].Width = #param_menu.Options[i].Text*CharIntervalX + 7 end
	end
end
local function CreateTrialMenuButtons() -- Automatically populate trial menu with buttons based on their amount
	Menu.MaxTrialButtonsY = math.floor((ScreenHeight-44) / 12)
	local ColumnInterval = (ScreenWidth-10)/Menu.MaxTrialButtonsX
	local ButtonText = ""
	local HelperText = ""
	local NewButton = nil
	for i = 1, math.min(#Trial.TrialTable, Menu.MaxTrialButtonsX*Menu.MaxTrialButtonsY) do
		ButtonText = "Trial " .. i
		if (Trial.TrialTable[i].name ~= nil) then ButtonText = Trial.TrialTable[i].name end
		HelperText = ""
		if (Trial.TrialTable[i].description ~= nil) then HelperText = Trial.TrialTable[i].description end 
		NewButton =
		{
			Type = "Button",
			Text = ButtonText,
			Description = HelperText,
			OriginX = 10 + (i - ((i-1) % Menu.MaxTrialButtonsY + 1))/Menu.MaxTrialButtonsY*ColumnInterval,
			OriginY = 12*((i-1) % Menu.MaxTrialButtonsY + 1)+8,
			IndexX = math.floor((i-1) / Menu.MaxTrialButtonsY) + 1,
			IndexY = (i-1) % Menu.MaxTrialButtonsY + 1,
			OnPress = function(self)
				Trial.CurrentNumber = i
				Menu.IsActive = false
			end
		}
		table.insert(TrialMenu.Options, NewButton)
	end
end
local function UpdateMenuVars() -- Update shorthands for current menu values
	Menu.CurrentOptionID = Menu.CurrentMenu.CurrentOptionID
	Menu.CurrentOption = Menu.CurrentMenu.Options[Menu.CurrentOptionID]
	Menu.CurrentState = nil
	Menu.CurrentStateID = nil
	if (Menu.CurrentOption.Type == "Toggle") then
		Menu.CurrentStateID = Menu.CurrentOption.CurrentStateID
		Menu.CurrentState = Menu.CurrentOption.States[Menu.CurrentStateID]
		-- Update toggle vars
		Trial[Menu.CurrentOption.Var] = Menu.CurrentState.Value
	end
end
local function ProcessMenuInputs() -- Scroll through buttons while menuing
	if not (Menu.CurrentMenu == TrialMenu) then
		if (IsPressed(P1, "Up")) then Menu.CurrentMenu.CurrentOptionID = SelectPrevious(Menu.CurrentOptionID, #Menu.CurrentMenu.Options) end
		if (IsPressed(P1, "Down")) then Menu.CurrentMenu.CurrentOptionID = SelectNext(Menu.CurrentOptionID, #Menu.CurrentMenu.Options) end
		-- Scrolling through options in a toggle
		if (IsPressed(P1, "Left") and Menu.CurrentOption.Type == "Toggle") then Menu.CurrentOption.CurrentStateID = SelectPrevious(Menu.CurrentStateID, #Menu.CurrentOption.States) end
		if (IsPressed(P1, "Right") and Menu.CurrentOption.Type == "Toggle") then Menu.CurrentOption.CurrentStateID = SelectNext(Menu.CurrentStateID, #Menu.CurrentOption.States) end
	end
	-- Trial menu has a 2d coordinate system of buttons, process all inputs differently
	if (Menu.CurrentMenu == TrialMenu) then
		local ButtonIndexX = TrialMenu.Options[TrialMenu.CurrentOptionID].IndexX
		local ButtonIndexY = TrialMenu.Options[TrialMenu.CurrentOptionID].IndexY
		if (IsPressed(P1, "Up") and Menu.MaxTrialButtonsY > 1) then 
			if not (TrialMenu.Options[TrialMenu.CurrentOptionID-1] == nil or ButtonIndexY == 1) then
				TrialMenu.CurrentOptionID = SelectPrevious(TrialMenu.CurrentOptionID, #TrialMenu.Options)
			else
				TrialMenu.CurrentOptionID = math.min(#TrialMenu.Options, (ButtonIndexX-1)*Menu.MaxTrialButtonsY + Menu.MaxTrialButtonsY)
			end
		end
		if (IsPressed(P1, "Down") and Menu.MaxTrialButtonsY > 1) then 
			if not (TrialMenu.Options[TrialMenu.CurrentOptionID+1] == nil or ButtonIndexY == Menu.MaxTrialButtonsY) then
				TrialMenu.CurrentOptionID = SelectNext(TrialMenu.CurrentOptionID, #TrialMenu.Options)
			else
				TrialMenu.CurrentOptionID = (ButtonIndexX-1)*Menu.MaxTrialButtonsY + 1
			end
		end
		if (IsPressed(P1, "Left") and #TrialMenu.Options > Menu.MaxTrialButtonsY and Menu.MaxTrialButtonsX > 1) then 
			if not (TrialMenu.Options[TrialMenu.CurrentOptionID-Menu.MaxTrialButtonsY] == nil or ButtonIndexX == 1) then
				TrialMenu.CurrentOptionID = TrialMenu.CurrentOptionID-Menu.MaxTrialButtonsY
			elseif not (TrialMenu.Options[TrialMenu.CurrentOptionID+Menu.MaxTrialButtonsY] == nil) then
				if not ((Menu.MaxTrialButtonsX-1)*Menu.MaxTrialButtonsY + ButtonIndexY > #TrialMenu.Options) then
					TrialMenu.CurrentOptionID = (Menu.MaxTrialButtonsX-1)*Menu.MaxTrialButtonsY + ButtonIndexY
				else
					TrialMenu.CurrentOptionID = (Menu.MaxTrialButtonsX-2)*Menu.MaxTrialButtonsY + ButtonIndexY
				end
			end
		end
		if (IsPressed(P1, "Right") and #TrialMenu.Options > Menu.MaxTrialButtonsY and Menu.MaxTrialButtonsX > 1) then 
			if not (TrialMenu.Options[TrialMenu.CurrentOptionID+Menu.MaxTrialButtonsY] == nil or ButtonIndexX == Menu.MaxTrialButtonsX) then
				TrialMenu.CurrentOptionID = TrialMenu.CurrentOptionID+Menu.MaxTrialButtonsY
			elseif not (TrialMenu.Options[TrialMenu.CurrentOptionID-Menu.MaxTrialButtonsY] == nil) then
				TrialMenu.CurrentOptionID = ButtonIndexY
			end
		end
	end
	-- Confirm button signals that a menu button is pressed
	if (IsPressed(P1, Button_Confirm) and Menu.CurrentOption.Type == "Button") then Menu.CurrentOption:OnPress() end
	-- Back button to return to previous menu or exit out
	if (IsPressed(P1, Button_Back)) then
		if (Menu.CurrentMenu.PrevMenu == nil) then Menu.IsActive = false
		else Menu.CurrentMenu = Menu.CurrentMenu.PrevMenu
		end
	end
end
-------------------------------------------------------Main execution loop-------------------------------------------------------
function UpdateMenuGUI() -- runs every frame that display is updated
	-- Show nothing unless menu is active
	if (Menu.IsActive == false) then return end
	-- Draw menu
	DrawMenuBox(Menu.CurrentMenu, Config.MenuInputHelperTextColor)
	-- Draw menu buttons & toggles
	for i = 1, #Menu.CurrentMenu.Options do
		TextColor = Config.MenuDefaultTextColor
		if (i == Menu.CurrentOptionID) then TextColor = Config.MenuHighlightTextColor end
		if (Menu.CurrentMenu.Options[i].Type == "Button") then DrawMenuButton(Menu.CurrentMenu.Options[i], TextColor) end
		if (Menu.CurrentMenu.Options[i].Type == "Toggle") then DrawMenuToggle(Menu.CurrentMenu.Options[i], TextColor) end
	end
	DrawMenuOptionHelperText(Menu.CurrentMenu, Menu.CurrentOption, Config.MenuHelperTextColor)
end
function MenuHandler() -- runs every frame
	P1.FreezeGameInputs = false -- Unfreeze game inputs before starting function
	if (Menu.IsActive == false) then return end
	UpdateMenuVars()
	P1.FreezeGameInputs = true -- Freeze game inputs when in menu
	ProcessMenuInputs()
end
-------------------------------------------------------First run routine-------------------------------------------------------
MenuList = {MainMenu, TrialMenu} -- Array of all menus
CreateTrialMenuButtons()
for i = 1, #MenuList do
	SetMenuOptionMTs(MenuList[i])
	SetButtonsAutoWidth(MenuList[i])
end