-- Data structures for menus & menu elements; this is what the menus are built from

local MenuClass = {}

MenuClass.Box =
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
MenuClass.Button =
{
	IsEnabled = true,
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
MenuClass.Toggle =
{
	IsEnabled = true,
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
MenuClass.ToggleState =
{
	Value = 0, 
	Text = "",
}

return MenuClass