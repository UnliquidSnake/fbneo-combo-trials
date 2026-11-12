-- Stuff that runs before the script can start proper

local InitRoutine = {}

function InitRoutine.CheckSupportedRom() -- Check whether specific rom is supported by the script
	local romlist =
	{
		"sfa", -- Street Fighter Alpha - Warriors' Dreams (950727 Euro)
		"sfa2u", -- Street Fighter Alpha 2 (960430 USA)
	}
	local IsSupportedRom = false
	for _, name in pairs(romlist) do
		if (RomName == name) then IsSupportedRom = true end
	end
	if (IsSupportedRom == false) then error("ERROR: Unsupported rom") end
end
function InitRoutine.LoadCharData() -- Generic function for loading character data. Defined and overwritten in main game script when required
	-- Get character ID's and names
	P1.CharID = Read_PlayerCharID(P1)
	P2.CharID = Read_PlayerCharID(P2)
	P1.CharName = T_CharName[P1.CharID]
	P2.CharName = T_CharName[P2.CharID]
	P1.CharShortname = T_CharShortname[P1.CharID]
	P2.CharShortname = T_CharShortname[P2.CharID]
	-- Set paths for char-specific files
	Path_P1StateData = WorkDir .. "/games/" .. GameFolder .. "/char_data/" .. P1.CharShortname .. ".chr"
	Path_P2StateData = WorkDir .. "/games/" .. GameFolder .. "/char_data/" .. P2.CharShortname .. ".chr"
	Path_TrialData = WorkDir .. "/games/" .. GameFolder .. "/trial_data/" .. P1.CharShortname .. ".tr"
	-- Load character state data
	P1.StateTable = Helper.DoFile(Path_P1StateData, "ERROR: Cannot find character data for player 1")
	P2.StateTable = Helper.DoFile(Path_P2StateData, "ERROR: Cannot find character data for player 2")
	if not (type(P1.StateTable) == "table") then error("ERROR: Empty or missing state table for player 1") end
	if not (type(P2.StateTable) == "table") then error("ERROR: Empty or missing state table for player 2") end
end
function InitRoutine.GameInit() -- STUB. Define in game script
	print("Warning: Game script has no defined routine before main loop starts")
end
function InitRoutine.TrialInit() -- Load trials & initialize all necessary values to make them function
	-- Initialize variables
	Trial.CurrentNumber = 1 -- int
	Trial.TotalAmount = 0 -- int
	Trial.IsActionSucceeded = {} -- array of function calls
	Trial.IsFailed = false -- function call
	Trial.DisplayMenu = false -- bool
	Trial.ShowActionInput = false -- bool
	Trial.CurrentTrial = {} -- pointer to current trial
	Trial.NextAction = {} -- pointer to action
		-- Current frame values
	Trial.CurrState.TrialID = 1 -- int
	Trial.CurrState.TotalActions = 0 -- int
	Trial.CurrState.TotalLines = 0 -- int
	Trial.CurrState.TrialProgress = 0 -- int
	Trial.CurrState.LinesCompleted = 0 -- int
	Trial.CurrState.TrialScrolling = 0 -- int
	Trial.CurrState.TrialMaxScrolling = 0 -- int
	Trial.CurrState.IsCompleted = false -- bool
		-- GUI values
	Trial.GUI.LinesDisplayed = 0 -- int
	Trial.GUI.DisplayOffset = 0 -- int
		-- Copy everything for previous frame values; failsafe in case of needing to add more deltas
	Trial.PrevState = Helper.CopyTable(Trial.CurrState)
	-- Load game-specific trial functions
	Helper.LoadModule(Path_TrialFunctions, "ERROR: Cannot find trial functions script")
	-- Load trial data
	TrialRoutine.LoadData()
	print("Loaded trial data")
end
function InitRoutine.MenuInit() -- Initialize menus
	-- Define dimensions of trial menu buttons
	MenuState.MaxTrialButtonsX = 2
	MenuState.MaxTrialButtonsY = 10 -- will be filled in automatically by MenuRoutine.CreateTrialButtons()
	-- Set main menu as default
	MenuState.CurrentMenu = Menus.MainMenu
	-- Populate trial menu with buttons
	MenuRoutine.CreateTrialButtons(Menus.TrialMenu)
	-- Set all appropriate metatables & automatic width for buttons
	for _, menu in pairs(Menus) do
		setmetatable(menu, {__index = MenuClass.Box})
		MenuRoutine.SetOptionMTs(menu)
		MenuRoutine.SetButtonsAutoWidth(menu)
	end
end
function InitRoutine.PrintConsoleMsgs() -- Print messages to console
	if (#GameMessage > 0) then
		for _, line in pairs(GameMessage) do print(line) end
	end
	print("Lua hotkey 1 (Alt+1): toggle menu")
	print("Lua hotkey 2 (Alt+2): open trial menu")
end

return InitRoutine