-------------------------------------------------------Loading routine-------------------------------------------------------
for i = 1, 3 do emu.frameadvance() end -- Wait 3 frames to allow for emu.screenwidth() and emu.screenheight() to be obtained properly
-------------------------------------------------------Variables-------------------------------------------------------
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
-- Get name of currently loaded rom & game, and folder name for game-specific files
RomName = emu.romname()
GameName = emu.gamename()
GameFolder = emu.parentname()
if (GameFolder == "0") then GameFolder = RomName end -- if rom has no parent, use same folder as name of rom
-- Get screen dimensions
ScreenWidth = emu.screenwidth()
ScreenHeight = emu.screenheight()
-- Buffer for message to display when loading specific game
GameMessage = {""} -- table of strings
-- Filepaths
local Path_ScriptTrial = "script/trial.lua"
local Path_ScriptMenus = "script/menus.lua"
local Path_ScriptInput = "script/input.lua"
local Path_GameScriptMain = "games/" .. GameFolder .. "/script/main.lua"
local Path_DefaultConfig = "default_config.ini"
local Path_RomList = "romlist.ini"
local Path_GameConfig = "games/" .. GameFolder .. "/" .. "config.ini"
-- Paths for character-specific stuff, will be filled in after confirming characters in match
Path_P1StateData = "" -- string
Path_P2StateData = "" -- string
Path_TrialData = "" -- string
-- Path for game-specific trial functions, will be filled in after main game script is loaded
Path_TrialFunctions = "" -- string
-- Data tables for players, game state, config vars & trial handling.
-- Includes buffers for previous frame - this is needed for comparison statements later.
P1 = {}
P2 = {}
Match = {}
Trial = {}
Config = {}
Menu = {}
Inputs = {}
P1.StateTable = {}
P2.StateTable = {}
P1.CurrState = {}
P2.CurrState = {}
Match.CurrState = {}
Trial.CurrState = {}
P1.PrevState = {}
P2.PrevState = {}
Match.PrevState = {}
Trial.PrevState = {}
Trial.GUI = {}
-------------------------------------------------------Universal Functions-------------------------------------------------------
function IsInteger(param_number)
	if not (tostring(param_number) == string.format("%i", param_number)) then return false end
	return true
end
-- Scroll to the previous or next element in a sequence of elements of specific length. Will also cycle between first and last element
function SelectNext(param_i, param_len)
	return param_i % param_len + 1 end
function SelectPrevious(param_i, param_len)
	return (param_i + param_len - 2) % param_len + 1 end
-- Table functions
function CopyTable(t_src, t_dst) -- Copy all values from one table to another
	if (type(t_src) ~= "table" or type(t_dst) ~= "table") then return false end
	for k,v in pairs(t_src) do t_dst["" .. k] = v end
	return true
end
function CombineTable(t1, t2) -- Combine two tables into one, return combined table. Any shared values will be overwritten by second table's values
	if (type(t1) ~= "table" or type(t2) ~= "table") then return false end
	local t_comb = {}
	for k,v in pairs(t1) do t_comb["" .. k] = v end
	for k,v in pairs(t2) do t_comb["" .. k] = v end
	return t_comb
end
-- File loading functions
function IsFileExists(param_filepath) -- Check for opening file, taken from peon2's training script
	local fs = io.open(param_filepath,"r")
	local res = fs~=nil
	if (res) then fs:close() end
	return res
end
function LoadScript(param_filepath, param_errormsg) -- Try to load script, throw up error if unsuccessful
	if not IsFileExists(param_filepath) then error(param_errormsg) end
	dofile(param_filepath)
end
function ReadLinesFromFile(param_filepath, param_errorname)
	if not IsFileExists(param_filepath) then error("ERROR: Cannot find " .. param_errorname) end
	local file = io.open(param_filepath, "rb")
	if (file == nil) then error("ERROR: Cannot open " .. param_errorname) end
	local lines = {}
	while true do
		nxtline = file:read()
		if (nxtline == nil) then break end -- Stop reading at eof
		-- Ignore comments that span the whole line
		if not (nxtline:find("^%s*%-%-")) then
			nxtline = nxtline:gsub("[\n\r]", "") -- Remove endline symbols from line
			table.insert(lines, nxtline)
		end
	end
	file:close()
	if not (#lines > 0) then error("ERROR: " .. param_errorname .. " is empty") end
	return lines
end
-------------------------------------------------------Config Functions-------------------------------------------------------
function IsCorrectConfigColor(param_color) -- Check integrity of color value in config file
	if (type(param_color) == "number") then return true end
	local ColorList = {"clear", "white", "black", "gray", "grey", "red", "green", "blue", "yellow", "cyan", "magenta", "purple", "teal", "orange", "chartreuse"}
	if (type(param_color) == "string") then
		for i = 1, #ColorList do
			if (param_color == ColorList[i]) then return true end
		end
	end
	return false
end
function CheckPrimaryConfigErrors() -- Error handling of config file when script starts
	if not (type(Config.MaxRefillTimer) == "number" and IsInteger(Config.MaxRefillTimer) and Config.MaxRefillTimer >= 0) then
		error("ERROR: Config parameter MaxRefillTimer has incorrect value") end
	if not (type(Config.TrialMaxLines) == "number" and IsInteger(Config.TrialMaxLines) and Config.TrialMaxLines >= 0) then
		error("ERROR: Config parameter TrialMaxLines has incorrect value") end
	if not (type(Config.TrialScrollingStart) == "number" and IsInteger(Config.TrialScrollingStart) and Config.TrialScrollingStart >= 0) then
		error("ERROR: Config parameter TrialScrollingStart has incorrect value") end
	if not (Config.TrialMaxLines == 0 or Config.TrialScrollingStart < Config.TrialMaxLines) then
		error("ERROR: Config parameter TrialScrollingStart is not smaller than TrialMaxLines") end
	if not (type(Config.AllowLineCarry) == "boolean") then
		error("ERROR: Config parameter AllowLineCarry has incorrect value") end
	if not (type(Config.GUIHeaderPosX) == "number" and IsInteger(Config.GUIHeaderPosX) and Config.GUIHeaderPosX >= 0 and Config.GUIHeaderPosX < ScreenWidth) then
		error("ERROR: Config parameter GUIHeaderPosX has incorrect value") end
	if not (type(Config.GUIHeaderPosY) == "number" and IsInteger(Config.GUIHeaderPosY) and Config.GUIHeaderPosY >= 0 and Config.GUIHeaderPosY < ScreenHeight) then
		error("ERROR: Config parameter GUIHeaderPosY has incorrect value") end
	if not (type(Config.GUISuccessPosX) == "number" and IsInteger(Config.GUISuccessPosX) and Config.GUISuccessPosX >= 0 and Config.GUISuccessPosX < ScreenWidth) then
		error("ERROR: Config parameter GUISuccessPosX has incorrect value") end
	if not (type(Config.GUISuccessPosY) == "number" and IsInteger(Config.GUISuccessPosY) and Config.GUISuccessPosY >= 0 and Config.GUISuccessPosY < ScreenHeight) then
		error("ERROR: Config parameter GUISuccessPosY has incorrect value") end
	if not (type(Config.GUIListPosX) == "number" and IsInteger(Config.GUIListPosX) and Config.GUIListPosX >= 0 and Config.GUIListPosX < ScreenWidth) then
		error("ERROR: Config parameter GUIListPosX has incorrect value") end
	if not (type(Config.GUIListPosY) == "number" and IsInteger(Config.GUIListPosY) and Config.GUIListPosY >= CharIntervalY and Config.GUIListPosY < ScreenHeight) then
		error("ERROR: Config parameter GUIListPosY has incorrect value") end
	if not (type(Config.DebugTextPosX) == "number" and IsInteger(Config.DebugTextPosX) and Config.DebugTextPosX >= 0 and Config.DebugTextPosX < ScreenWidth) then
		error("ERROR: Config parameter DebugTextPosX has incorrect value") end
	if not (type(Config.DebugTextPosY) == "number" and IsInteger(Config.DebugTextPosY) and Config.DebugTextPosY >= 0 and Config.DebugTextPosY < ScreenHeight) then
		error("ERROR: Config parameter DebugTextPosY has incorrect value") end
	if not (type(Config.GUIListInterval) == "number" and IsInteger(Config.GUIListInterval) and Config.GUIListInterval >= CharIntervalY and Config.GUIListInterval < ScreenHeight) then
		error("ERROR: Config parameter GUIListInterval has incorrect value") end
	if not (Config.GUIListPosY + Config.GUIListInterval < ScreenHeight) then
		error("ERROR: After GUIList, trial list's vertical position is off-screen") end
	if not (type(Config.GUIScrollMarkerInterval) == "number" and IsInteger(Config.GUIScrollMarkerInterval) and Config.GUIScrollMarkerInterval >= 0) then
		error("ERROR: Config parameter GUIScrollMarkerInterval has incorrect value") end
	if not (Config.GUIListPosX - Config.GUIScrollMarkerInterval >= 0) then
		error("ERROR: Scroll markers' horizontal position is off-screen") end
	if not (Config.GUIListPosY - Config.GUIListInterval >= 0) then
		error("ERROR: Scroll markers' vertical position is off-screen") end
	if not (IsCorrectConfigColor(Config.GUIDefaultColor)) then
		error("ERROR: Config parameter GUIDefaultColor has incorrect value") end
	if not (IsCorrectConfigColor(Config.GUISuccessColor)) then
		error("ERROR: Config parameter GUISuccessColor has incorrect value") end
	if not (type(Config.GUISuccessText) == "string" and #Config.GUISuccessText > 0) then
		error("ERROR: Config parameter GUISuccessText has incorrect value") end
	if not (type(Config.DisplayDebugText) == "boolean") then
		error("ERROR: Config parameter DisplayDebugText has incorrect value") end
	if not (IsCorrectConfigColor(Config.MenuDefaultTextColor)) then
		error("ERROR: Config parameter MenuDefaultTextColor has incorrect value") end
	if not (IsCorrectConfigColor(Config.MenuHighlightTextColor)) then
		error("ERROR: Config parameter MenuHighlightTextColor has incorrect value") end
	if not (IsCorrectConfigColor(Config.MenuDescriptionTextColor)) then
		error("ERROR: Config parameter MenuDescriptionTextColor has incorrect value") end
	if not (IsCorrectConfigColor(Config.MenuInputHelperTextColor)) then
		error("ERROR: Config parameter MenuInputHelperTextColor has incorrect value") end
end
function ReadConfig(param_cfgpath, param_errorname) -- Read all data from config file & mutate it into correct data types where appropriate. Returns table of config parameters
	local cfglines = ReadLinesFromFile(param_cfgpath, param_errorname)
	local cfgtable = {}
	-- Split lines
	for i = 1, #cfglines do
		local strsplit = {}
		--for j in cfglines[i]:gmatch("[^=%s]+") do table.insert(strsplit, j) end -- Split by spaces and equal signs
		for j in cfglines[i]:gmatch("[^=]+") do table.insert(strsplit, j) end -- Split by equal sign
		if not (#strsplit == 2) then error("ERROR: Cannot parse parameter " .. strsplit[1]) end
		local key = strsplit[1]
		local val = strsplit[2]
		-- Remove spaces on either side of =
		key = key:gsub("%s+$", "")
		val = val:gsub("^%s+", "")
		-- Take strings out of quotes where applicable
		val = val:gsub("^[\"']+", ""):gsub("[\"']+$", "")
		-- Convert to number values where possible
		if not (tonumber(val) == nil) then val = tonumber(val) end
		-- Convert to boolean values where possible
		if (val == "true" or val == "TRUE") then val = true end
		if (val == "false" or val == "FALSE") then val = false end
		-- Insert values into table
		cfgtable[key] = val
	end
	return cfgtable
end
function LoadConfig() -- Load default config, overwrite with game-specific config if present
	local defaultcfg = {}
	local gamecfg = {}
	-- Read from default config always & game-specific config if present
	defaultcfg = ReadConfig(Path_DefaultConfig, "default config file")
	if not IsFileExists(Path_GameConfig) then print("WARNING: Cannot find config file for " .. GameFolder .. ". Using default config")
	else gamecfg = ReadConfig(Path_GameConfig, "game config file")
	end
	-- Combine values from both configs into config table. In case of overlaps, game-specific config will overwrite default config
	Config = CombineTable(defaultcfg, gamecfg)
	-- Check errors
	CheckPrimaryConfigErrors()
	CheckSecondaryConfigErrors()
end
-------------------------------------------------------Other Script Functions-------------------------------------------------------
local function CheckSupportedRom() -- Check whether specific rom are supported by the script
	local romlist = ReadLinesFromFile(Path_RomList, "rom list")
	local IsSupportedRom = false
	for i = 1, #romlist do
		if (RomName == romlist[i]) then IsSupportedRom = true end
	end
	if (IsSupportedRom == false) then error("ERROR: Unsupported rom") end
end
local function PrintConsoleMsgs() -- Print messages to console
	if (#GameMessage > 0) then
		for i = 1, #GameMessage do print(GameMessage[i]) end
	end
	print("Lua hotkey 1 (Alt+1): toggle menu")
	print("Lua hotkey 2 (Alt+2): open trial menu")
end
-------------------------------------------------------Execution-------------------------------------------------------
CheckSupportedRom()
print ("Running game: " .. GameName .. " [" .. GameFolder .. "]")
LoadScript(Path_ScriptInput, "ERROR: Cannot find input script file")
LoadScript(Path_GameScriptMain, "ERROR: Cannot find main script file for " .. GameFolder)
LoadScript(Path_ScriptTrial, "ERROR: Cannot find trial script file")
LoadScript(Path_ScriptMenus, "ERROR: Cannot find menus script file")
PrintConsoleMsgs()
-- Main execution loop; runs constantly while the script is active. Main functionality is here, refers to individual game scripts
while true do
	emu.registerbefore(InputHandler) -- Inputs are handled before frame is emulated to properly process inputs when menuing
	-- The following functions update every frame
	GameHandler()
	TrialHandler()
	TrialSupportHandler()
	MenuHandler()
	-- Updates GUI of the script every time the display is updated in the emulator
	gui.register(
		UpdateGameGUI(),
		UpdateTrialGUI(), 
		UpdateMenuGUI()
	)
	emu.frameadvance() -- Lets emulator advance the frame, then begins next iteration
end