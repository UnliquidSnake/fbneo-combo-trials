-- Stuff that runs every frame during the main execution loop

local ExecRoutine = {}

function ExecRoutine.InputExec()
	InputRoutine.ProcessLuaHotkeys()
	-- Freeze P2's inputs to prevent uncalled for situations
	P2.CurrState.FreezeGameInputs = true
	-- Unfreeze P1's inputs according to timer
	if P1.CurrState.InputFreezeTimer > 0 then P1.CurrState.FreezeGameInputs = true end
	if (P1.CurrState.InputFreezeTimer < P1.PrevState.InputFreezeTimer and P1.CurrState.InputFreezeTimer == 0) then P1.CurrState.FreezeGameInputs = false end
	-- Update deltas
	P1.PrevInputs = Helper.CopyTable(P1.CurrInputs)
	P2.PrevInputs = Helper.CopyTable(P2.CurrInputs)
	P1.PrevGameInputs = Helper.CopyTable(P1.CurrGameInputs)
	P2.PrevGameInputs = Helper.CopyTable(P2.CurrGameInputs)
	-- Filter player inputs
	P1.CurrGameInputs, P2.CurrGameInputs = InputRoutine.FilterPlayerInput()
	-- Add enemy settings to P2 inputs
	P2.CurrGameInputs = Helper.CombineTable(P2.CurrGameInputs, EnemyInputs)
	InputRoutine.SetGameInput(P1.CurrGameInputs, P2.CurrGameInputs)
end
function ExecRoutine.GameExec() -- STUB. Define in game script
end
function ExecRoutine.TrialExec()
	-- Update previous frame values
	Trial.PrevState = Helper.CopyTable(Trial.CurrState)
	-- Update current frame values
	TrialRoutine.UpdateVars()
	-- If trial's fail condition is triggered, reset everything
	if (Trial.IsFailed()) == true then
		Trial.CurrState.TrialProgress = 0
		Trial.CurrState.LinesCompleted = 0
		Trial.CurrState.TrialScrolling = 0
		-- If current trial has been completed, switch to the next one
		if (Trial.PrevState.IsCompleted == true) then TrialRoutine.SelectNextTrial() end
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
	-- Set P2's inputs during frame's emulation. Doing it during the input execution (before the frame emulates) bugs out and opponent never attacks for some reason
	InputRoutine.SetEnemyInput()
end
function ExecRoutine.TrialSupportExec() -- STUB. Game-specific addons for trial functionality; define in trial support functions
end
function ExecRoutine.MenuExec()
	if (MenuState.IsActive == false) then return end
	MenuRoutine.UpdateVars()
	P1.CurrState.FreezeGameInputs = true -- Freeze game inputs when in menu
	MenuRoutine.ProcessInput()
end

return ExecRoutine