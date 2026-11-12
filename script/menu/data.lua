-- The menus themselves, all specific text, elements & their functions

local Menus = {}

Menus.MainMenu =
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
			OnPress = function(self) MenuRoutine.CloseMenu() end
		},
		{
			Type = "Button",
			Text = "Reload Save",
			Description = "Reload the savestate attached to the trial (if exists).",
			OriginX = 10,
			OriginY = 32,
			OnPress = function(self)
				TrialRoutine.LoadSave(Trial.CurrentNumber)
				MenuRoutine.CloseMenu()
			end
		},
		{
			Type = "Button",
			Text = "Next Trial",
			Description = "Attempt the next trial in sequence.",
			OriginX = 10,
			OriginY = 44,
			OnPress = function(self)
				TrialRoutine.SelectNextTrial()
				TrialRoutine.LoadSave(Trial.CurrentNumber)
				MenuRoutine.CloseMenu()
			end
		},
		{
			Type = "Button",
			Text = "Previous Trial",
			Description = "Attempt the previous trial in sequence.",
			OriginX = 10,
			OriginY = 56,
			OnPress = function(self)
				TrialRoutine.SelectPreviousTrial()
				TrialRoutine.LoadSave(Trial.CurrentNumber)
				MenuRoutine.CloseMenu()
			end
		},
		{
			Type = "Button",
			Text = "Select Trial",
			Description = "Select a different trial to attempt.",
			OriginX = 10,
			OriginY = 68,
			OnPress = function(self)
				MenuState.CurrentMenu = Menus.TrialMenu
			end
		},
		{
			Type = "Toggle",
			Var = "ShowActionInput",
			Text = "Trial Display",
			Description = "Toggle between displaying move names or commands (numpad notation).",
			OriginX = 10,
			OriginY = 80,
			States =
			{
				{Value = false, Text = "Move Names"},
				{Value = true, Text = "Inputs"},
			}
		},
	},
}

Menus.TrialMenu =
{
	PrevMenu = Menus.MainMenu,
	Title = "Trial Menu",
	Options = {}, -- will be filled in via MenuRoutine.CreateTrialButtons()
}

return Menus