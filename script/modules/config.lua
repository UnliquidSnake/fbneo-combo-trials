-- Module for functions pertaining to trial configuration

local CfgRoutine = {}

function CfgRoutine.IsCorrectColor(param_color) -- Check integrity of color value in config file
	if (type(param_color) == "number") then return true end
	local ColorList = {"clear", "white", "black", "gray", "grey", "red", "green", "blue", "yellow", "cyan", "magenta", "purple", "teal", "orange", "chartreuse"}
	if (type(param_color) == "string") then
		for _, color in pairs(ColorList) do
			if (param_color == color) then return true end
		end
	end
	return false
end
function CfgRoutine.CheckPrimaryErrors(param_cfgobj) -- Error handling of config file when script starts
	if not (type(param_cfgobj.MaxRefillTimer) == "number" and Helper.IsInteger(param_cfgobj.MaxRefillTimer) and param_cfgobj.MaxRefillTimer >= 0) then
		error("ERROR: Config parameter MaxRefillTimer has incorrect value") end
	if not (type(param_cfgobj.TrialMaxLines) == "number" and Helper.IsInteger(param_cfgobj.TrialMaxLines) and param_cfgobj.TrialMaxLines >= 0) then
		error("ERROR: Config parameter TrialMaxLines has incorrect value") end
	if not (type(param_cfgobj.TrialScrollingStart) == "number" and Helper.IsInteger(param_cfgobj.TrialScrollingStart) and param_cfgobj.TrialScrollingStart >= 0) then
		error("ERROR: Config parameter TrialScrollingStart has incorrect value") end
	if not (param_cfgobj.TrialMaxLines == 0 or param_cfgobj.TrialScrollingStart < param_cfgobj.TrialMaxLines) then
		error("ERROR: Config parameter TrialScrollingStart is not smaller than TrialMaxLines") end
	if not (type(param_cfgobj.AllowLineCarry) == "boolean") then
		error("ERROR: Config parameter AllowLineCarry has incorrect value") end
	if not (type(param_cfgobj.GUIHeaderPosX) == "number" and Helper.IsInteger(param_cfgobj.GUIHeaderPosX) and param_cfgobj.GUIHeaderPosX >= 0 and param_cfgobj.GUIHeaderPosX < ScreenWidth) then
		error("ERROR: Config parameter GUIHeaderPosX has incorrect value") end
	if not (type(param_cfgobj.GUIHeaderPosY) == "number" and Helper.IsInteger(param_cfgobj.GUIHeaderPosY) and param_cfgobj.GUIHeaderPosY >= 0 and param_cfgobj.GUIHeaderPosY < ScreenHeight) then
		error("ERROR: Config parameter GUIHeaderPosY has incorrect value") end
	if not (type(param_cfgobj.GUISuccessPosX) == "number" and Helper.IsInteger(param_cfgobj.GUISuccessPosX) and param_cfgobj.GUISuccessPosX >= 0 and param_cfgobj.GUISuccessPosX < ScreenWidth) then
		error("ERROR: Config parameter GUISuccessPosX has incorrect value") end
	if not (type(param_cfgobj.GUISuccessPosY) == "number" and Helper.IsInteger(param_cfgobj.GUISuccessPosY) and param_cfgobj.GUISuccessPosY >= 0 and param_cfgobj.GUISuccessPosY < ScreenHeight) then
		error("ERROR: Config parameter GUISuccessPosY has incorrect value") end
	if not (type(param_cfgobj.GUIListPosX) == "number" and Helper.IsInteger(param_cfgobj.GUIListPosX) and param_cfgobj.GUIListPosX >= 0 and param_cfgobj.GUIListPosX < ScreenWidth) then
		error("ERROR: Config parameter GUIListPosX has incorrect value") end
	if not (type(param_cfgobj.GUIListPosY) == "number" and Helper.IsInteger(param_cfgobj.GUIListPosY) and param_cfgobj.GUIListPosY >= CharIntervalY and param_cfgobj.GUIListPosY < ScreenHeight) then
		error("ERROR: Config parameter GUIListPosY has incorrect value") end
	if not (type(param_cfgobj.DebugTextPosX) == "number" and Helper.IsInteger(param_cfgobj.DebugTextPosX) and param_cfgobj.DebugTextPosX >= 0 and param_cfgobj.DebugTextPosX < ScreenWidth) then
		error("ERROR: Config parameter DebugTextPosX has incorrect value") end
	if not (type(param_cfgobj.DebugTextPosY) == "number" and Helper.IsInteger(param_cfgobj.DebugTextPosY) and param_cfgobj.DebugTextPosY >= 0 and param_cfgobj.DebugTextPosY < ScreenHeight) then
		error("ERROR: Config parameter DebugTextPosY has incorrect value") end
	if not (type(param_cfgobj.GUIListInterval) == "number" and Helper.IsInteger(param_cfgobj.GUIListInterval) and param_cfgobj.GUIListInterval >= CharIntervalY and param_cfgobj.GUIListInterval < ScreenHeight) then
		error("ERROR: Config parameter GUIListInterval has incorrect value") end
	if not (param_cfgobj.GUIListPosY + param_cfgobj.GUIListInterval < ScreenHeight) then
		error("ERROR: After GUIList, trial list's vertical position is off-screen") end
	if not (type(param_cfgobj.GUIScrollMarkerInterval) == "number" and Helper.IsInteger(param_cfgobj.GUIScrollMarkerInterval) and param_cfgobj.GUIScrollMarkerInterval >= 0) then
		error("ERROR: Config parameter GUIScrollMarkerInterval has incorrect value") end
	if not (param_cfgobj.GUIListPosX - param_cfgobj.GUIScrollMarkerInterval >= 0) then
		error("ERROR: Scroll markers' horizontal position is off-screen") end
	if not (param_cfgobj.GUIListPosY - param_cfgobj.GUIListInterval >= 0) then
		error("ERROR: Scroll markers' vertical position is off-screen") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.GUIDefaultColor)) then
		error("ERROR: Config parameter GUIDefaultColor has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.GUISuccessColor)) then
		error("ERROR: Config parameter GUISuccessColor has incorrect value") end
	if not (type(param_cfgobj.GUISuccessText) == "string" and #param_cfgobj.GUISuccessText > 0) then
		error("ERROR: Config parameter GUISuccessText has incorrect value") end
	if not (type(param_cfgobj.DisplayDebugText) == "boolean") then
		error("ERROR: Config parameter DisplayDebugText has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.MenuDefaultTextColor)) then
		error("ERROR: Config parameter MenuDefaultTextColor has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.MenuHighlightTextColor)) then
		error("ERROR: Config parameter MenuHighlightTextColor has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.MenuDisabledTextColor)) then
		error("ERROR: Config parameter MenuDisabledTextColor has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.MenuDescriptionTextColor)) then
		error("ERROR: Config parameter MenuDescriptionTextColor has incorrect value") end
	if not (CfgRoutine.IsCorrectColor(param_cfgobj.MenuInputHelperTextColor)) then
		error("ERROR: Config parameter MenuInputHelperTextColor has incorrect value") end
end
function CfgRoutine.CheckSecondaryErrors(param_cfgobj) -- Game-specific error handling of config file when script starts. Meant to be defined & overwritten by the game script
	print("WARNING: Game specific error checks of config file are not defined")
end
function CfgRoutine.Read(param_cfgpath, param_errorname) -- Read all data from config file & mutate it into correct data types where appropriate. Returns table of config parameters
	local cfglines = Helper.ReadLinesFromFile(param_cfgpath, param_errorname)
	local cfgtable = {}
	-- Split lines
	for _, line in pairs(cfglines) do
		local strsplit = {}
		for i in line:gmatch("[^=]+") do table.insert(strsplit, i) end -- Split by equal sign
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
function CfgRoutine.Load() -- Load default config, overwrite with game-specific config if present
	local defaultcfg = {}
	local gamecfg = {}
	local cfgobj = {}
	-- Read from default config always & game-specific config if present
	defaultcfg = CfgRoutine.Read(Path_DefaultConfig, "default config file")
	if not Helper.IsFileExists(Path_GameConfig) then print("WARNING: Cannot find config file for " .. GameFolder .. ". Using default config")
	else gamecfg = CfgRoutine.Read(Path_GameConfig, "game config file")
	end
	-- Combine values from both configs into config object. In case of overlaps, game-specific config will overwrite default config
	cfgobj = Helper.CombineTable(defaultcfg, gamecfg)
	-- Check errors
	CfgRoutine.CheckPrimaryErrors(cfgobj)
	CfgRoutine.CheckSecondaryErrors(cfgobj)

	return cfgobj
end

return CfgRoutine