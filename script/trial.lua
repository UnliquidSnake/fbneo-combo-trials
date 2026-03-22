-------------------------------------------------------Loading routine-------------------------------------------------------
LoadScript(Path_TrialFunctions, "ERROR: Cannot find trial functions for " .. GameFolder) -- Load trial functions for specific game
-------------------------------------------------------Variables-------------------------------------------------------
-- Array for trial data
Trial.TrialTable = {}
-- Trial variables
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
CopyTable(Trial.CurrState, Trial.PrevState)
-------------------------------------------------------Functions-------------------------------------------------------
local function CheckPrimaryTrialErrors(param_trialtable) -- Checks integrity of trial table
	if not (type(param_trialtable) == "table" and #param_trialtable > 0) then error("ERROR: Missing or empty trial table") end
	for i = 1, #param_trialtable do
		-- Set values for error checks
		local trial = param_trialtable[i]
		Trial.CurrState.TrialID = i
		local fail_state = DefaultFail
		if (trial.fail ~= nil) then fail_state = loadstring("return " .. trial.fail) end
		-- Check integrity of trial data
		if not (type(trial) == "table") then 
			error("ERROR: Trial table has hole in position " .. i) end
		if not (type(trial.name) == "string" or trial.name == nil) then 
			error("ERROR: Trial " .. i .. " has incorrect name") end
		if not (type(trial.description) == "string" or trial.description == nil) then 
			error("ERROR: Trial " .. i .. " has incorrect description") end
		if not (type(trial.fail) == "string" or trial.fail == nil) then 
			error("ERROR: Trial " .. i .. " has incorrectly defined failstate") end
		if not (type(trial.acttable) == "table" and #trial.acttable > 0) then 
			error("ERROR: Trial " .. i .. " has empty or missing action table") end
		for j = 1, #trial.acttable do
			-- Set values for error checks
			local action = trial.acttable[j]
			Trial.CurrState.TrialProgress = j-1
			local success_state = function() return DefaultSuccess(action) end
			if (action.success ~= nil) then success_state = loadstring("return " .. action.success) end
			-- Check integrity of trial data
			if not (type(action) == "table") then 
				error("ERROR: Action table in trial " .. i .. " has hole in position " .. j) end
			if not (type(action.state) == "table") then 
				error("ERROR: In trial " .. i .. ", action " .. j .. " has no defined state") end
			if not (type(action.state.name) == "string" and action.state.name ~= "") then 
				error("ERROR: In trial " .. i .. ", action " .. j .. "'s state has no defined name") end
			if not (type(action.success) == "string" or action.success == nil) then 
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrectly defined success condition") end
			if not ((type(action.name) == "string" and action.name ~= "") or action.name == nil) then
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrectly defined name") end
			if not ((type(action.nameadd) == "string" and action.nameadd ~= "") or action.nameadd == nil) then
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrectly defined addition to name") end
			if not (type(action.carry) == "boolean" or action.carry == nil) then
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect carry flag") end
			if not (type(success_state()) == "boolean") then
				error("ERROR: In trial " .. i .. ", action " .. j .. "'s success condition does not return boolean value") end
		end
		if not (type(fail_state()) == "boolean") then
			error("ERROR: In trial " .. i .. ", failstate does not return boolean value") end
	end
	-- Reset trial values before loading trial data
	Trial.CurrState.TrialID = 1
	Trial.CurrState.TrialProgress = 0
end
local function LoadTrialData() -- Check data in trial file to make sure everything is intact
	-- Check integrity of trial functions
	if not (type(DefaultFail) == "function") then error("ERROR: Default failstate not found") end
	if not (type(DefaultSuccess) == "function") then error("ERROR: Default success condition not found") end
	if not (type(DefaultFail()) == "boolean") then error("ERROR: Default failstate function does not return boolean value") end
	-- Initialize buffers
	States = P1.StateTable
	-- Read data from trial file
	local TrialFile = io.open(Path_TrialData, "rb")
	if (TrialFile == nil) then error("ERROR: Failed to open trial file") end
	local TrialRawData = TrialFile:read("*a")
	if not (type(TrialRawData) == "string" and #TrialRawData > 0) then error("ERROR: Failed to read data from trial file") end
	TrialFile:close()
	local TrialCode = loadstring("return " .. TrialRawData)
	if not (type(TrialCode) == "function") then error("ERROR: Failed to read table function from trial file") end
	Trial.TrialTable = TrialCode()
	-- Old code for loading trial data, leaving it in if current implementation turns out to be too retarded
	--LoadScript(Path_TrialData, "ERROR: Cannot find trial data for " .. P1.CharShortname)
	--Trial.TrialTable = CharTrialTable
	CheckPrimaryTrialErrors(Trial.TrialTable)
	CheckSecondaryTrialErrors(Trial.TrialTable)
end
local function UpdateTrialVars() -- Update all stored variables
	local CarryCount = 0
	Trial.TotalAmount = #Trial.TrialTable
	-- Update previous frame values
	CopyTable(Trial.CurrState, Trial.PrevState)
	-- Update current frame values
	Trial.CurrState.TrialID = Trial.CurrentNumber
	Trial.CurrState.TotalActions = #Trial.TrialTable[Trial.CurrState.TrialID].acttable
	Trial.CurrState.TotalLines = Trial.CurrState.TotalActions
	-- Update shortcut values
	Trial.CurrentTrial = Trial.TrialTable[Trial.CurrState.TrialID]
	if (Trial.CurrState.TrialProgress < Trial.CurrState.TotalActions) then Trial.NextAction = Trial.CurrentTrial.acttable[Trial.CurrState.TrialProgress+1] end
	Trial.IsFailed = DefaultFail -- If trial has no specified failstate, use default
	if (Trial.CurrentTrial.fail ~= nil) then Trial.IsFailed = loadstring("return " .. Trial.CurrentTrial.fail) end
	for i = 1, Trial.CurrState.TotalActions do
		Trial.IsActionSucceeded[i] = function() return DefaultSuccess(Trial.CurrentTrial.acttable[i]) end -- If action has no specified condition, use default
		if (Trial.CurrentTrial.acttable[i].success ~= nil) then Trial.IsActionSucceeded[i] = loadstring("return " .. Trial.CurrentTrial.acttable[i].success) end
	end
	-- Calculate total number of lines to display depending on carry flags
	if (Config.AllowLineCarry == true and Trial.CurrState.TotalActions > 1) then
		CarryCount = 0
		for i = 1, Trial.CurrState.TotalActions - 1 do
			if (Trial.TrialTable[Trial.CurrState.TrialID].acttable[i].carry == true) then CarryCount = CarryCount + 1 end
		end
		Trial.CurrState.TotalLines = Trial.CurrState.TotalActions - CarryCount
	end
	-- Calculate scrolling to apply to trial list
	Trial.GUI.LinesDisplayed = math.min(Trial.CurrState.TotalLines,Config.TrialMaxLines)
	if (Config.TrialMaxLines > 0) then
		Trial.CurrState.TrialMaxScrolling = math.max(0,Trial.CurrState.TotalLines-Config.TrialMaxLines)
		Trial.CurrState.TrialScrolling = math.min(math.max(0,Trial.CurrState.LinesCompleted-Config.TrialScrollingStart),Trial.CurrState.TrialMaxScrolling)
		Trial.GUI.DisplayOffset = Trial.CurrState.TrialScrolling
	end
end
	-------------------------------------------------------Lua hotkey functions-------------------------------------------------------
function ToggleMenu()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block menuing while combo is going
	if (Menu.CurrentMenu == nil) then Menu.CurrentMenu = MainMenu end
	Menu.IsActive = not Menu.IsActive
end
function OpenTrialMenu()
	if (Trial.CurrState.TrialProgress ~= 0 or Menu.IsActive == true) then return end -- Block menuing while combo is going or menu is open
	Menu.CurrentMenu = TrialMenu
	Menu.IsActive = true
end
function SelectNextTrial()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block switching while combo is going
	Trial.CurrentNumber = SelectNext(Trial.CurrentNumber, Trial.TotalAmount)
	TrialMenu.CurrentOptionID = math.min(Trial.CurrentNumber, #TrialMenu.Options)
end
function SelectPreviousTrial()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block switching while combo is going
	Trial.CurrentNumber = SelectPrevious(Trial.CurrentNumber, Trial.TotalAmount)
	TrialMenu.CurrentOptionID = math.min(Trial.CurrentNumber, #TrialMenu.Options)
end
	-------------------------------------------------------Display functions-------------------------------------------------------
local function DisplayTrialHeader()
	local GUIHeaderText = "Trial " .. Trial.CurrState.TrialID
	if (Trial.CurrentTrial.name ~= nil) then GUIHeaderText = Trial.CurrentTrial.name end
	gui.text(Config.GUIHeaderPosX,Config.GUIHeaderPosY,GUIHeaderText,Config.GUIDefaultColor)
end
local function DisplayTrialSuccess()
	gui.text(Config.GUISuccessPosX,Config.GUISuccessPosY,Config.GUISuccessText,Config.GUISuccessColor)
end
local function DisplayTrialScrollMarker()
	if (Trial.CurrState.TrialScrolling > 0) then 
		gui.text(Config.GUIListPosX-Config.GUIScrollMarkerInterval,Config.GUIListPosY-Config.GUIListInterval, "^", Config.GUIDefaultColor) end
	if (Trial.CurrState.TrialScrolling < Trial.CurrState.TrialMaxScrolling) then
		gui.text(Config.GUIListPosX-Config.GUIScrollMarkerInterval,Config.GUIListPosY+Trial.GUI.LinesDisplayed*Config.GUIListInterval, "v", Config.GUIDefaultColor) end
end
local function DisplayTrialList()
	-- Local vars
	local DrawLineID = 0
	local LinePosX = Config.GUIListPosX
	local LinePosY = Config.GUIListPosY
	local LinePosOffsetX = 0
	local LinePosOffsetY = 0
	local CarryStr = " -> "
	if (Trial.ShowActionInput == true) then CarryStr = "->" end

	for i = 1, Trial.CurrState.TotalActions do
		-- Check for carry flags
		local IsCarry = (Config.AllowLineCarry == true and i < Trial.CurrState.TotalActions and Trial.CurrentTrial.acttable[i].carry == true)
		local IsPrevCarry = (Config.AllowLineCarry == true and i > 1 and Trial.CurrentTrial.acttable[i-1].carry == true)
		-- Decide what text to display, default to statename if all else fails
		local acttext = Trial.CurrentTrial.acttable[i].state.name
		if (Trial.ShowActionInput == true and Trial.CurrentTrial.acttable[i].state.inputname ~= nil) then acttext = Trial.CurrentTrial.acttable[i].state.inputname end
		if (Trial.CurrentTrial.acttable[i].name ~= nil) then acttext = Trial.CurrentTrial.acttable[i].name end
		if (Trial.CurrentTrial.acttable[i].nameadd ~= nil) then acttext = "" .. acttext .. Trial.CurrentTrial.acttable[i].nameadd end
		if (IsPrevCarry) then acttext = CarryStr .. acttext end
		-- Decide how to color the text depending on trial progress
		local textcolor = Config.GUIDefaultColor
		if (Trial.CurrState.TrialProgress >= i) then textcolor = Config.GUISuccessColor end
		-- Decide where to display the line depending on carry flags and position in trial
		if (DrawLineID >= Trial.GUI.DisplayOffset and DrawLineID < Trial.GUI.DisplayOffset + Trial.GUI.LinesDisplayed) or Config.TrialMaxLines == 0 then
			gui.text(LinePosX+LinePosOffsetX,LinePosY+LinePosOffsetY-Trial.GUI.DisplayOffset*Config.GUIListInterval, acttext, textcolor) end
		if (IsCarry) then LinePosOffsetX = LinePosOffsetX + #acttext*CharIntervalX
		else
			DrawLineID = DrawLineID+1
			LinePosOffsetX = 0
			LinePosOffsetY = LinePosOffsetY + Config.GUIListInterval
		end
	end
end
-------------------------------------------------------Main execution loop-------------------------------------------------------
function UpdateTrialGUI()
	DisplayTrialHeader()
	if (Trial.CurrState.IsCompleted == true) then DisplayTrialSuccess() end
	DisplayTrialScrollMarker()
	DisplayTrialList()
end
function TrialHandler()
	UpdateTrialVars()
	if (Trial.IsFailed()) == true then
		-- Reset everything
		Trial.CurrState.TrialProgress = 0
		Trial.CurrState.LinesCompleted = 0
		Trial.CurrState.TrialScrolling = 0
		-- If current trial has been completed, switch to the next one
		if (Trial.PrevState.IsCompleted == true) then SelectNextTrial() end
	end
	-- Check if all actions of a trial have been completed
	if (Trial.CurrState.TrialProgress == Trial.CurrState.TotalActions) then Trial.CurrState.IsCompleted = true return
	else Trial.CurrState.IsCompleted = false
	end
	-- Check if the next action of the trial has been completed
	if (Trial.IsActionSucceeded[Trial.CurrState.TrialProgress + 1]() == true) then
		if not (Config.AllowLineCarry == true and Trial.NextAction.carry == true and Trial.CurrState.TrialProgress < Trial.CurrState.TotalActions-1) then
			Trial.CurrState.LinesCompleted = Trial.CurrState.LinesCompleted + 1 end
		Trial.CurrState.TrialProgress = Trial.CurrState.TrialProgress + 1
	end
end
-------------------------------------------------------First run routine-------------------------------------------------------
LoadTrialData()
print("Loaded trial data")