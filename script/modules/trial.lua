-- Module for trial functionality

local TrialRoutine = {}
TrialRoutine.Gui = {}

function TrialRoutine.CheckPrimaryErrors(param_trialtable) -- Checks integrity of trial table
	if not (type(param_trialtable) == "table" and #param_trialtable > 0) then error("ERROR: Missing or empty trial table") end
	for i, trial in ipairs(param_trialtable) do
		-- Set values for error checks
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
		if not (type(trial.save) == "string" or trial.save == nil) then 
			error("ERROR: Trial " .. i .. " has incorrectly defined savestate path") end
		if not (type(trial.acttable) == "table" and #trial.acttable > 0) then 
			error("ERROR: Trial " .. i .. " has empty or missing action table") end
		for j, action in ipairs(trial.acttable) do
			-- Set values for error checks
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
			if not ((type(action.inputname) == "string" and action.inputname ~= "") or action.inputname == nil) then
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrectly defined inputname") end
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
function TrialRoutine.CheckSecondaryErrors(param_trialtable) -- Check integrity of game-specific values in trial table. Stub, meant to be defined and overwritten in trial functions script
	print("WARNING: Error checking of game-specific values in trial data is not defined")
end
function TrialRoutine.LoadData() -- Load trials with all appropriate error checks
	-- Check integrity of trial functions
	if not (type(DefaultFail) == "function") then error("ERROR: Default failstate not found") end
	if not (type(DefaultSuccess) == "function") then error("ERROR: Default success condition not found") end
	if not (type(DefaultFail()) == "boolean") then error("ERROR: Default failstate function does not return boolean value") end
	-- Initialize buffers
	States = Helper.CopyTable(P1.StateTable)
	-- Read data from trial file
	local TrialFile = io.open(Path_TrialData, "rb")
	if (TrialFile == nil) then error("ERROR: Failed to open trial file") end
	local TrialRawData = TrialFile:read("*a")
	if not (type(TrialRawData) == "string" and #TrialRawData > 0) then error("ERROR: Failed to read data from trial file") end
	TrialFile:close()
	local TrialCode = loadstring("return " .. TrialRawData)
	if not (type(TrialCode) == "function") then error("ERROR: Failed to read table function from trial file") end
	Trial.TrialTable = TrialCode()
	-- Check errors in trial data
	TrialRoutine.CheckPrimaryErrors(Trial.TrialTable)
	TrialRoutine.CheckSecondaryErrors(Trial.TrialTable)
end
function TrialRoutine.UpdateVars() -- Update all stored variables
	Trial.TotalAmount = #Trial.TrialTable
	-- Update current frame values
	Trial.CurrState.TrialID = Trial.CurrentNumber
	Trial.CurrState.TotalActions = #Trial.TrialTable[Trial.CurrState.TrialID].acttable -- TODO: try removing maybe?
	Trial.CurrState.TotalLines = Trial.CurrState.TotalActions
	-- Update shortcut values
	Trial.CurrentTrial = Trial.TrialTable[Trial.CurrState.TrialID]
	if (Trial.CurrState.TrialProgress < Trial.CurrState.TotalActions) then Trial.NextAction = Trial.CurrentTrial.acttable[Trial.CurrState.TrialProgress+1] end
	Trial.IsFailed = DefaultFail -- If trial has no specified failstate, use default
	if (Trial.CurrentTrial.fail ~= nil) then Trial.IsFailed = loadstring("return " .. Trial.CurrentTrial.fail) end
	-- Create table of success conditions for actions
	for i, action in ipairs(Trial.CurrentTrial.acttable) do
		Trial.IsActionSucceeded[i] = function() return DefaultSuccess(action) end -- If action has no specified condition, use default
		if (action.success ~= nil) then Trial.IsActionSucceeded[i] = loadstring("return " .. action.success) end
	end
	-- Calculate total number of lines to display depending on carry flags
	if (Config.AllowLineCarry == true and Trial.CurrState.TotalActions > 1) then
		local CarryCount = 0
		for i, action in ipairs(Trial.CurrentTrial.acttable) do
			if i == Trial.CurrState.TotalActions then break end
			if (action.carry == true) then CarryCount = CarryCount + 1 end
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
function TrialRoutine.LoadSave(param_number) -- Load a savestate when pressing hotkey or selecting trial
	if (Trial.CurrState.TrialProgress ~= 0 or Trial.TrialTable[param_number].save == nil) then return end
	savestate.load(Path_Saves .. Trial.TrialTable[param_number].save)
end
function TrialRoutine.ResetProgress() -- Reset all trial progress
	Trial.CurrState.IsCompleted = false
	Trial.CurrState.TrialProgress = 0
	Trial.CurrState.LinesCompleted = 0
	Trial.CurrState.TrialScrolling = 0
end
function TrialRoutine.SelectNextTrial()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block switching while combo is going
	Trial.CurrentNumber = Helper.SelectNext(Trial.CurrentNumber, Trial.TotalAmount)
	Menus.TrialMenu.CurrentOptionID = math.min(Trial.CurrentNumber, #Menus.TrialMenu.Options)
end
function TrialRoutine.SelectPreviousTrial()
	if (Trial.CurrState.TrialProgress ~= 0) then return end -- Block switching while combo is going
	Trial.CurrentNumber = Helper.SelectPrevious(Trial.CurrentNumber, Trial.TotalAmount)
	Menus.TrialMenu.CurrentOptionID = math.min(Trial.CurrentNumber, #Menus.TrialMenu.Options)
end
-------------------------------------------------------Display functions-------------------------------------------------------
function TrialRoutine.Gui.DisplayHeader()
	local GUIHeaderText = "Trial " .. Trial.CurrState.TrialID
	if (Trial.CurrentTrial.name ~= nil) then GUIHeaderText = Trial.CurrentTrial.name end
	gui.text(Config.GUIHeaderPosX,Config.GUIHeaderPosY,GUIHeaderText,Config.GUIDefaultColor)
end
function TrialRoutine.Gui.DisplaySuccessText()
	gui.text(Config.GUISuccessPosX,Config.GUISuccessPosY,Config.GUISuccessText,Config.GUISuccessColor)
end
function TrialRoutine.Gui.DisplayScrollMarkers()
	if (Trial.CurrState.TrialScrolling > 0) then 
		gui.text(Config.GUIListPosX-Config.GUIScrollMarkerInterval,Config.GUIListPosY-Config.GUIListInterval, "^", Config.GUIDefaultColor) end
	if (Trial.CurrState.TrialScrolling < Trial.CurrState.TrialMaxScrolling) then
		gui.text(Config.GUIListPosX-Config.GUIScrollMarkerInterval,Config.GUIListPosY+Trial.GUI.LinesDisplayed*Config.GUIListInterval, "v", Config.GUIDefaultColor) end
end
function TrialRoutine.Gui.DisplayActionList()
	-- Local vars
	local DrawLineID = 0
	local LinePosX = Config.GUIListPosX
	local LinePosY = Config.GUIListPosY
	local LinePosOffsetX = 0
	local LinePosOffsetY = 0
	local CarryStr = " -> "
	if (Trial.ShowActionInput == true) then CarryStr = "->" end
	
	for i, action in ipairs(Trial.CurrentTrial.acttable) do
		-- Check for carry flags
		local IsCarry = (Config.AllowLineCarry == true and i < Trial.CurrState.TotalActions and action.carry == true)
		local IsPrevCarry = (Config.AllowLineCarry == true and i > 1 and Trial.CurrentTrial.acttable[i-1].carry == true)
		-- Decide what text to display, default to statename if all else fails
		local acttext = action.state.name
		if (Trial.ShowActionInput == true and action.state.inputname ~= nil) then acttext = action.state.inputname end
		if (action.name ~= nil) then acttext = action.name end
		if (Trial.ShowActionInput == true and action.inputname ~= nil) then acttext = action.inputname end
		if (action.nameadd ~= nil) then acttext = "" .. acttext .. action.nameadd end
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

return TrialRoutine