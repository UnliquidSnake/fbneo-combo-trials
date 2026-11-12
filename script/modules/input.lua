-- Module for processing input & manipulating player inputs inside of the game

local InputRoutine = {}

function InputRoutine.IsPressed(param_player, param_button) -- Checks if an input is pressed on that specific frame
	if not (param_player == P1 or param_player == P2) then return false end
	if (param_player.PrevInputs[param_button] == false and param_player.CurrInputs[param_button] == true) then return true end
	return false
end
function InputRoutine.IsReleased(param_player, param_button) -- Checks if an input is released on that specific frame
	if not (param_player == P1 or param_player == P2) then return false end
	if (param_player.PrevInputs[param_button] == true and param_player.CurrInputs[param_button] == false) then return true end
	return false
end
function InputRoutine.SetEnemyInput() -- Generic function for setting enemy's input based on trial parameters. Button table is defined in game script
	Trial.EnemyDir = nil
	Trial.EnemyAtk = nil
	-- Reset all auto inputs, reestablish them later
	for k,v in pairs(EnemyInputs) do EnemyInputs["" .. k] = nil end
	-- Check if trial has setting for enemy state, make enemy hold down or up accordingly
	if (Trial.CurrentTrial.enemystate ~= nil) then
		if (Trial.CurrentTrial.enemystate == "crouch") then Trial.EnemyDir = "Down" end
		if (Trial.CurrentTrial.enemystate == "jump") then Trial.EnemyDir = "Up" end
		if (type(Trial.EnemyDir) == "string") then EnemyInputs[Trial.EnemyDir] = true end
	end
	--  Set enemy attack interval
	if (Trial.CurrentTrial.enemyatkinterval == nil) then Trial.CurrentTrial.enemyatkinterval = DefaultEnemyAtkInterval end
	-- Check if trial has setting for enemy attacking at specific interval. If not (or if changed the trial), reset the timer and stop executing function
	if (Trial.CurrentTrial.enemyatk == nil or Trial.CurrState.TrialID ~= Trial.PrevState.TrialID) then Trial.EnemyAtkTimer = Trial.CurrentTrial.enemyatkinterval return end
	-- Check trial setting for enemy's specific button, use defined button table
	for btn, btnname in pairs(Buttons) do
		if (Trial.CurrentTrial.enemyatk == btn) then Trial.EnemyAtk = btnname end
	end
	Trial.EnemyAtkTimer = Trial.EnemyAtkTimer - 1
	if (Trial.EnemyAtkTimer <= 0) then
		if (type(Trial.EnemyAtk) == "string") then EnemyInputs[Trial.EnemyAtk] = true end
		Trial.EnemyAtkTimer = Trial.CurrentTrial.enemyatkinterval
	end
end
function InputRoutine.FilterPlayerInput() -- Filter player input to prevent unwanted inputs in menus
	-- Refresh game inputs
	for k,v in pairs(P1.CurrGameInputs) do P1.CurrGameInputs["" .. k] = nil end
	for k,v in pairs(P2.CurrGameInputs) do P2.CurrGameInputs["" .. k] = nil end
	-- Get current frame inputs
	local RawInputs = joypad.get()
	-- Split inputs into player arrays
	for k,v in pairs(RawInputs) do
		PlayerStr = k:sub(1,2)
		InputStr = k:sub(4)
		if PlayerStr == "P1" then
			P1.CurrInputs[InputStr] = v
			-- If button is pressed, carry over to game inputs
			if (P1.CurrInputs[InputStr] == true) then P1.CurrGameInputs[InputStr] = true end
			if (P1.CurrState.FreezeGameInputs == true) then P1.CurrGameInputs[InputStr] = false end
		end
		if PlayerStr == "P2" then
			P2.CurrInputs[InputStr] = v
			-- If button is pressed, carry over to game inputs
			if (P2.CurrInputs[InputStr] == true) then P2.CurrGameInputs[InputStr] = true end
			if (P2.CurrState.FreezeGameInputs == true) then P2.CurrGameInputs[InputStr] = false end
		end
	end

	return P1.CurrGameInputs, P2.CurrGameInputs
end
function InputRoutine.SetGameInput(param_p1table, param_p2table) -- Feeds the filtered inputs to the game
	if not (type(param_p1table) == "table" and type(param_p2table) == "table") then return end
	local GameInput = {}
	for k,v in pairs(param_p1table) do GameInput["P1 " .. k] = v end
	for k,v in pairs(param_p2table) do GameInput["P2 " .. k] = v end
	joypad.set(GameInput)
end
function InputRoutine.ProcessLuaHotkeys() -- Register Lua hotkey inputs
	input.registerhotkey(1, MenuRoutine.ToggleMenu)
	input.registerhotkey(2, MenuRoutine.OpenTrialMenu)
end

return InputRoutine