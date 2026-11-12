-- Main script file for fbneo-combo-trials; this is what you run in fbneo to load the trials
TRIALS_VERSION = "0.2"
-------------------------------------------------------Loading routine-------------------------------------------------------
-- Wait 3 frames to allow for emu.screenwidth() and emu.screenheight() to be obtained properly
for i = 1, 3 do emu.frameadvance() end
-- Get constants from emulator functions
RomName = emu.romname()
GameName = emu.gamename()
GameFolder = emu.parentname()
if (GameFolder == "0") then GameFolder = RomName end -- if rom has no parent, use same folder as name of rom
ScreenWidth = emu.screenwidth()
ScreenHeight = emu.screenheight()
-- Load helper module
Helper = require("script/helper")
-- Save working directory at start of execution for savestate reloads
WorkDir = Helper.GetCWD()
-- Define filepaths for modules, then load them
-- Logic modules
local Path_Module_CfgRoutine = "script/modules/config.lua"
local Path_Module_InputRoutine = "script/modules/input.lua"
local Path_Module_TrialRoutine = "script/modules/trial.lua"
local Path_Module_MenuRoutine = "script/modules/menu.lua"
-- Menu data
local Path_Module_MenuClass = "script/menu/class.lua"
local Path_Module_Menus = "script/menu/data.lua"
-- Execution modules
local Path_Module_InitRoutine = "script/init.lua"
local Path_Module_ExecRoutine = "script/exec.lua"
local Path_Module_GuiRoutine = "script/gui.lua"
-- Define path for main game script
local Path_GameScript = "games/" .. GameFolder .. "/script/main.lua"
-- Load all modules
CfgRoutine = Helper.LoadModule(Path_Module_CfgRoutine, "ERROR: Cannot find config module")
InputRoutine = Helper.LoadModule(Path_Module_InputRoutine, "ERROR: Cannot find input module")
TrialRoutine = Helper.LoadModule(Path_Module_TrialRoutine, "ERROR: Cannot find trial module")
MenuRoutine = Helper.LoadModule(Path_Module_MenuRoutine, "ERROR: Cannot find menu module")
MenuClass = Helper.LoadModule(Path_Module_MenuClass, "ERROR: Cannot find menu classes")
Menus = Helper.LoadModule(Path_Module_Menus, "ERROR: Cannot find menu data")
InitRoutine = Helper.LoadModule(Path_Module_InitRoutine, "ERROR: Cannot find initialization module")
ExecRoutine = Helper.LoadModule(Path_Module_ExecRoutine, "ERROR: Cannot find main execution module")
GuiRoutine = Helper.LoadModule(Path_Module_GuiRoutine, "ERROR: Cannot find GUI module")
-------------------------------------------------------Constants-------------------------------------------------------
-- Memory macros
wb = memory.writebyte
ww = memory.writeword
wdw = memory.writedword
rb = memory.readbyte
rw = memory.readword
rws = memory.readwordsigned
rdw = memory.readdword
-- Text intervals for spacing trial lines
CharIntervalX = 4
CharIntervalY = 7
-------------------------------------------------------Variables-------------------------------------------------------
GameMessage = {""} -- table of strings; buffer for message to display when loading specific game
CharMessage = function() return "unknown chars" end -- function for info about selected chars to display after character state data is loaded. Overwritten in game script
-- Filepaths for config files
Path_DefaultConfig = WorkDir .. "/default_config.ini"
Path_GameConfig = WorkDir .. "/games/" .. GameFolder .. "/config.ini"
-- Paths for character-specific stuff, will be filled in after confirming characters in match
Path_P1StateData = "" -- string
Path_P2StateData = "" -- string
Path_TrialData = "" -- string
-- Path for game-specific trial functions, will be filled in after main game script is loaded
Path_TrialFunctions = "" -- string
-- Path for savestates
Path_Saves = WorkDir .. "/games/" .. GameFolder .. "/" .. "saves/"
-- Buffer for script configuration
Config = {}
-- Input variables & objects
Buttons = {} -- Buffer for button names & shorthands
EnemyInputs = {} -- Buffer for enemy inputs in trial settings
DefaultEnemyAtkInterval = 120 -- const int; interval between enemy button presses when enemy is set to attack
-- Player variables & objects
P1 = {}
P2 = {}
P1.StateTable = {}
P2.StateTable = {}
P1.CurrState = {}
P2.CurrState = {}
P1.CurrState.FreezeGameInputs = false
P2.CurrState.FreezeGameInputs = false
P1.CurrState.InputFreezeTimer = 0
P2.CurrState.InputFreezeTimer = 0
P1.PrevState = {}
P2.PrevState = {}
-- Player input arrays
P1.CurrInputs = {}
P1.PrevInputs = {}
P2.CurrInputs = {}
P2.PrevInputs = {}
P1.CurrGameInputs = {}
P1.PrevGameInputs = {}
P2.CurrGameInputs = {}
P2.PrevGameInputs = {}
-- Match variables & objects
Match = {}
Match.CurrState = {}
Match.PrevState = {}
-- Trial variables & objects
Trial = {}
Trial.TrialTable = {}
Trial.CurrentNumber = 1 -- int
Trial.TotalAmount = 0 -- int
Trial.IsActionSucceeded = {} -- array of function calls
Trial.IsFailed = false -- function call
Trial.DisplayMenu = false -- bool
Trial.ShowActionInput = false -- bool
Trial.CurrentTrial = {} -- pointer to current trial
Trial.NextAction = {} -- pointer to action
Trial.CurrState = {}
Trial.CurrState.TrialID = 1 -- int
Trial.CurrState.TotalActions = 0 -- int
Trial.CurrState.TotalLines = 0 -- int
Trial.CurrState.TrialProgress = 0 -- int
Trial.CurrState.LinesCompleted = 0 -- int
Trial.CurrState.TrialScrolling = 0 -- int
Trial.CurrState.TrialMaxScrolling = 0 -- int
Trial.CurrState.IsCompleted = false -- bool
Trial.PrevState = {}
Trial.GUI = {}
Trial.GUI.LinesDisplayed = 0 -- int
Trial.GUI.DisplayOffset = 0 -- int
Trial.EnemyAtk = "" -- string
Trial.EnemyAtkTimer = 0 -- int
-- Menu variables & objects
MenuState = {}
MenuState.CurrentMenu = {} -- pointer to menu object
MenuState.IsActive = false -- bool
MenuState.MaxTrialButtonsX = 0
MenuState.MaxTrialButtonsY = 0 -- will be filled in automatically by MenuRoutine.CreateTrialButtons()
-- Shorthands for current menu values
MenuState.CurrentOption = nil -- pointer to current active option
MenuState.CurrentOptionID = 1 -- int
MenuState.CurrentState = nil -- pointer to current state of active option
MenuState.CurrentStateID = nil -- int
-- Hacky fix to ensure no immediate button press happens upon exiting menu
InputFreezeInterval = 5
-------------------------------------------------------Execution Handlers-------------------------------------------------------
function InitHandler() -- Stuff to run before the script can start proper
	InitRoutine.CheckSupportedRom()
	print ("Running game: " .. GameName .. " [" .. GameFolder .. "]")
	-- Load main game script
	GameRoutine = Helper.LoadModule(Path_GameScript, "ERROR: Cannot find game script")
	-- Load config parameters
	Config = CfgRoutine.Load()
	-- Load character state data
	InitRoutine.LoadCharData()
	print ("Loaded character state data: " .. CharMessage())
	-- Run all necessary initialization procedures in individual modules
	InitRoutine.GameInit()
	InitRoutine.TrialInit()
	InitRoutine.MenuInit()
	-- Print console text
	InitRoutine.PrintConsoleMsgs()
end
function ExecHandler() -- Stuff to run during the main execution loop
	-- Update previous frame values
	P1.PrevState = Helper.CopyTable(P1.CurrState)
	P2.PrevState = Helper.CopyTable(P2.CurrState)
	Match.PrevState = Helper.CopyTable(Match.CurrState)
	-- Handle input freeze timer
	if (P1.CurrState.InputFreezeTimer > 0) then P1.CurrState.InputFreezeTimer = P1.CurrState.InputFreezeTimer - 1 end
	-- Run all required code
	ExecRoutine.GameExec()
	ExecRoutine.TrialExec()
	ExecRoutine.TrialSupportExec()
	ExecRoutine.MenuExec()
end
function GuiHandler() -- Stuff to run every time the emulator display is updated
	GuiRoutine.GameGui()
	GuiRoutine.TrialGui()
	if (Config.DisplayDebugText == true) then GuiRoutine.DebugGui() end
	GuiRoutine.MenuGui()
end
function ExecOnLoadstate() -- Stuff to run every time the user loads a savestate
	TrialRoutine.ResetProgress()
	InitRoutine.LoadCharData()
	GameRoutine.RefillPlayers()
end
-------------------------------------------------------Execution-------------------------------------------------------
-- Set event registers for GUI, input processing & savestates
emu.registerbefore(ExecRoutine.InputExec) -- Inputs are handled before frame is emulated to properly process inputs when menuing
gui.register(GuiHandler) -- Updates GUI of the script every time the display is updated in the emulator
savestate.registerload(ExecOnLoadstate)
-- Initialize script
InitHandler()
-- Main execution loop; runs constantly while the script is active. Main functionality is here, refers to individual game scripts
while true do
	ExecHandler()
	emu.frameadvance() -- Lets emulator advance the frame, then begins next iteration
end