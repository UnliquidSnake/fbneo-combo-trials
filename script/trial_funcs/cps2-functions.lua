-------------------------------------------------------Variables-------------------------------------------------------
local DefaultAtkInterval = 120 -- const int
-- Additional trial variables
Trial.CurrState.IsStartstate = false -- bool
Trial.HitCount = 0 -- int
Trial.IsAtkStarted = false -- int
Trial.EnemyAtk = "" -- string
Trial.EnemyAtkTimer = 0 -- int
-------------------------------------------------------Integrity Functions-------------------------------------------------------
function CheckSecondaryTrialErrors(param_trialtable) -- Checks integrity of game-specific values in trial table
	for i = 1, #param_trialtable do
		local trial = param_trialtable[i]
		local p1_meter = trial.p1meter
		local enemy_state = trial.enemystate
		local enemy_atk = trial.enemyatk
		local enemy_atkinterval = trial.enemyatkinterval
		-- Check integrity of trial values
		if (p1_meter ~= nil) and not (type(p1_meter) == "number" and IsInteger(p1_meter) and p1_meter >= 0 and p1_meter <= PlayerMaxSuperMeter) then
			error("ERROR: Trial " .. i .. " has incorrect p1meter value") end
		-- Check integrity of enemy settings
		if (enemy_state ~= nil) and not (enemy_state == "stand" or enemy_state == "crouch" or enemy_state == "jump") then
			error("ERROR: Trial " .. i .. " has incorrect enemystate value") end
		if (enemy_atk ~= nil) and not (enemy_atk == "LP" or enemy_atk == "MP" or enemy_atk == "HP" or enemy_atk == "LK" or enemy_atk == "MK" or enemy_atk == "HK") then
			error("ERROR: Trial " .. i .. " has incorrect enemyatk value") end
		if (enemy_atkinterval ~= nil) and not (type(enemy_atkinterval) == "number" and IsInteger(enemy_atkinterval) and enemy_atkinterval > 1) then
			error("ERROR: Trial " .. i .. " has incorrect enemyatkinterval value") end
		if (enemy_atk == nil and enemy_atkinterval ~= nil) then
			error("ERROR: Trial " .. i .. " has an enemy attack interval with no attack") end
		-- Check integrity of game-specific values in action table
		for j = 1, #trial.acttable do
			local action = trial.acttable[j]
			if not (type(action.state.stateval) == "table") then 
				error("ERROR: In trial " .. i .. ", action " .. j .. " has missing stateval table") end
			-- Check if stateval is a table of min and max
			if not (#action.state.stateval > 0 and type(action.state.stateval[1]) == "table") then
				-- If it is, check correct statevals
				if not (type(action.state.stateval.min) == "number" and type(action.state.stateval.max) == "number") then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has non-number min/max values for stateval table") end
				if not (IsInteger(action.state.stateval.min) and action.state.stateval.min >= 0 and action.state.stateval.min <= 0xffff) then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect min value for stateval table") end
				if not (IsInteger(action.state.stateval.max) and action.state.stateval.max >= 0 and action.state.stateval.max <= 0xffff) then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect max value for stateval table") end
			end
			-- Otherwise, stateval is a table of tables each containing a min and max value. Check statevals accordingly
			for k = 1, #action.state.stateval do
				if not (type(action.state.stateval[k].min) == "number" and type(action.state.stateval[k].max) == "number") then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has non-number min/max values for stateval table in position " .. k) end
				if not (IsInteger(action.state.stateval[k].min) and action.state.stateval[k].min >= 0 and action.state.stateval[k].min <= 0xffff) then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect min value for stateval table in position " .. k) end
				if not (IsInteger(action.state.stateval[k].max) and action.state.stateval[k].max >= 0 and action.state.stateval[k].max <= 0xffff) then
					error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect max value for stateval table in position " .. k) end
			end
			if (action.forcestart ~= nil) and not (type(action.forcestart) == "boolean") then 
				error("ERROR: In trial " .. i .. ", action " .. j .. " has incorrect forcestart parameter") end
		end
	end
end
function CheckStateArgs(...) -- Check for correct state arguments passed to other functions
	local args = {...}
	if (#args > 1) then return nil end
	if (#args == 0) then return Trial.TrialTable[Trial.CurrState.TrialID].acttable[Trial.CurrState.TrialProgress+1].state end
	if (#args == 1) then return args[1] end
end
function ConvertStatevals(param_state) -- Convert action stateval table from a number table into a table of tables. Hacky fix to avoid changing a billion things in other functions
	if not (#param_state.stateval > 0 and type(param_state.stateval[1]) == "table") then param_state.stateval = {{min = param_state.stateval.min, max = param_state.stateval.max}} end
end
-- Error checking functions
function CheckPlayerErrors(param_player, param_funcname)
	if not (param_player == P1 or param_player == P2) then 
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. param_funcname .. " - incorrect player argument") end
end
function CheckStateErrors(param_state, param_funcname)
	if not (type(param_state) == "table") then 
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. param_funcname .. " - incorrect state argument") end
	if not (type(param_state.stateval) == "table") then 
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. param_funcname .. " - missing stateval table") end
	-- Check if stateval is a table of min and max
	if not (#param_state.stateval > 0 and type(param_state.stateval[1]) == "table") then
		-- If it is, check correct statevals
		if not (type(param_state.stateval.min) == "number" and type(param_state.stateval.max) == "number") then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. 
			param_funcname .. " - stateval table has non-number min/max values") 
		end
		if not (IsInteger(param_state.stateval.min) and param_state.stateval.min >= 0 and param_state.stateval.min <= 0xffff) then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " ..
			param_funcname .. " - stateval table has incorrect min value") 
		end
		if not (IsInteger(param_state.stateval.max) and param_state.stateval.max >= 0 and param_state.stateval.max <= 0xffff) then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " ..
			param_funcname .. " - stateval table has incorrect max value") 
		end
	end
	-- Otherwise, stateval is a table of tables each containing a min and max value. Check statevals accordingly
	for i = 1, #param_state.stateval do
		if not (type(param_state.stateval[i].min) == "number" and type(param_state.stateval[i].max) == "number") then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. 
			param_funcname .. " - stateval table has non-number min/max values in position " .. i)
		end
		if not (IsInteger(param_state.stateval[i].min) and param_state.stateval[i].min >= 0 and param_state.stateval[i].min <= 0xffff) then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " ..
			param_funcname .. " - stateval table has incorrect min value in position " .. i) 
		end
		if not (IsInteger(param_state.stateval[i].max) and param_state.stateval[i].max >= 0 and param_state.stateval[i].max <= 0xffff) then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " ..
			param_funcname .. " - stateval table has incorrect max value in position " .. i) 
		end
	end
end
function CheckStartstateErrors(param_startstate, param_funcname)
	if not (type(param_startstate) == "table" and #param_startstate > 0) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. param_funcname .. " - incorrect startstate argument") end
	for i = 1, #param_startstate do
		if not (type(param_startstate[i]) == "number") then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. 
			param_funcname .. " - startstate table has non-number value in position " .. i)
		end
		if not (IsInteger(param_startstate[i]) and param_startstate[i] >= 0 and param_startstate[i] <= 0xffff) then
			error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): " .. 
			param_funcname .. " - startstate table has incorrect value in position " .. i)
		end
	end
end
-------------------------------------------------------Helper Functions-------------------------------------------------------
function IsPlayerInStartstate(param_player, param_state) -- Same thing for startstates
	-- Check integrity of arguments
	CheckPlayerErrors(param_player, "IsPlayerInStartstate")
	CheckStateErrors(param_state, "IsPlayerInStartstate")
	ConvertStatevals(param_state)
	-- Grab first two values to account for random frameskipping - some moves may hit on two separate actions like Chun upkicks, but combos won't drop for no reason
	local t_startstate = {param_state.stateval[1].min, param_state.stateval[1].min + 0x18 % 0x10000} 
	if not (param_state.startstate == nil) then t_startstate = param_state.startstate end
	CheckStartstateErrors(t_startstate, "IsPlayerInStartstate")
	for i = 1, #t_startstate do
		if (param_player.CurrState.CharState == t_startstate[i]) then return true end
	end
	return false
end
function IsCorrectAtkProps(param_state) -- Check for the attack's properties being correct when defined
	-- Check integrity of arguments
	CheckStateErrors(param_state, "IsCorrectAtkProps")
	-- Check for the correct strength of attack (i.e. buttons pressed)
	if (param_state.atkstr ~= nil and P1.CurrState.AtkStr ~= param_state.atkstr) then return false end
	-- Check for the correct ID of the special/super, if exists
	if (param_state.spid ~= nil and P1.CurrState.SpecialID ~= param_state.spid) then return false end
	return true
end
-------------------------------------------------------Trial Functions-------------------------------------------------------
function IsPlayerInState(param_player, param_state) -- Check if player is currently in specific state - usually for attacks, can be other things
	-- Check integrity of arguments
	CheckPlayerErrors(param_player, "IsPlayerInState")
	CheckStateErrors(param_state, "IsPlayerInState")
	ConvertStatevals(param_state)
	for i = 1, #param_state.stateval do
		if (param_player.CurrState.CharState >= param_state.stateval[i].min and param_player.CurrState.CharState <= param_state.stateval[i].max) then return true end
	end
	return false
end
function IsAtkCombo(...) -- Check if combo counter increments while player is in specific animation of the move
	-- Check integrity of state arguments
	local param_state = CheckStateArgs(...)
	if (param_state == nil) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsAtkCombo - too many arguments") end
	CheckStateErrors(param_state, "IsAtkCombo")
	if (IsCorrectAtkProps(param_state) == false) then return false end
	if (Trial.IsAtkStarted == false) then return false end
	return
	(
		IsPlayerInState(P1, param_state) and
		P1.CurrState.ComboCounter > P1.PrevState.ComboCounter and
		-- if move is not a fireball, prevent move from registering if hit by a fireball
		(param_state.type == "projectile" or (P1.PrevState.ProjActive == false and P1.CurrState.ProjActive == false))	
	)
end
function IsAtkDamage(...) -- Check if opponent takes damage while player is in specific animation of the move
	-- Check integrity of state arguments
	local param_state = CheckStateArgs(...)
	if (param_state == nil) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsAtkDamage - too many arguments") end
	CheckStateErrors(param_state, "IsAtkDamage")
	if (IsCorrectAtkProps(param_state) == false) then return false end
	return
	(
		IsPlayerInState(P1, param_state) and
		(P2.CurrState.Health + 1 % 256) < (P2.PrevState.Health + 1 % 256) and -- account for 0xff value when KO'd
		-- if move is not a fireball, prevent move from registering if hit by a fireball
		(param_state.type == "projectile" or (P1.PrevState.ProjActive == false and P1.CurrState.ProjActive == false))
	)
end
function IsAtkMultiCombo(param_hitcount, ...) -- Check if an attack hits many consecutive times
	if not (type(param_hitcount) == "number" and IsInteger(param_hitcount) and param_hitcount >= 1) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsAtkMultiCombo - incorrect hitcount argument") end
	-- Check integrity of state arguments
	local param_state = CheckStateArgs(...)
	if (param_state == nil) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsAtkMultiCombo - too many arguments") end
	CheckStateErrors(param_state, "IsAtkMultiCombo")
	return (IsAtkCombo(param_state) and Trial.HitCount >= param_hitcount-1)
end
function IsAtkWhiff(...) -- For whiffing, no need to check the opponent's state
	-- Check integrity of state arguments
	local param_state = CheckStateArgs(...)
	if (param_state == nil) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsAtkWhiff - too many arguments") end
	CheckStateErrors(param_state, "IsAtkWhiff")
	if (IsCorrectAtkProps(param_state) == false) then return false end
	if (Trial.IsAtkStarted == false) then return false end
	return IsPlayerInState(P1, param_state)
end
function IsProjHit(...) -- Check if projectile hits opponent irrespective of player animation
	-- Check integrity of state arguments
	local param_state = CheckStateArgs(...)
	if (param_state == nil) then
		error("ERROR (trial " .. Trial.CurrState.TrialID .. ", action " .. Trial.CurrState.TrialProgress+1 .. "): IsProjHit - too many arguments") end
	CheckStateErrors(param_state, "IsProjHit")
	if not (param_state.type == "projectile") then return false end -- no error message - screws up because function bleeds into next action when combo drops
	-- Check for the correct strength of the thrown projectile on the frame before the check happens
	if (param_state.atkstr ~= nil and P1.PrevState.ProjStr ~= param_state.atkstr) then return false end
	-- Check for the correct ID of the thrown projectile on the frame before the check happens
	if (param_state.spid ~= nil and P1.PrevState.ProjID ~= param_state.spid) then return false end
	if (Trial.IsAtkStarted == false) then return false end
	-- Check succeeds if projectile dissipates while combo is going. Very lenient but will suffice for most things
	return (P2.CurrState.InHitstun and P1.PrevState.ProjActive == true and P1.CurrState.ProjActive == false)
end
function IsCrossup() -- Check if both players are facing the same side, usually good indicator for crossups
	return P1.CurrState.FacingLeft == P2.CurrState.FacingLeft end
function IsComboDropped()
	return (P1.CurrState.ComboCounter < P1.PrevState.ComboCounter) end
function IsEnemyKD()
	return (IsPlayerInState(P2, P2.StateTable.Basic.Knockdown) or IsPlayerInState(P2, P2.StateTable.Basic.Recovery)) end
-------------------------------------------------------Default conditions for trial success/failure-------------------------------------------------------
function DefaultFail()
	return IsComboDropped() or IsEnemyKD() end
function DefaultSuccess(param_action)
	if (param_action.state.type == "throw") then return IsAtkDamage(param_action.state) end
	if (param_action.state.type == "notatk") then return IsAtkWhiff(param_action.state) end
	return IsAtkCombo(param_action.state) end
-------------------------------------------------------Support functions for main execution loop-------------------------------------------------------
function DisplayDebugText()
	gui.text(Config.DebugTextPosX,Config.DebugTextPosY,"HitCount: " .. Trial.HitCount)
	gui.text(Config.DebugTextPosX,Config.DebugTextPosY+CharIntervalY,"AtkStarted: " .. tostring(Trial.IsAtkStarted))
end
local function SetAtkStarted()
	if (Trial.NextAction.forcestart == true) then Trial.IsAtkStarted = true return end
	if (Trial.IsAtkStarted == true) then
		if (Trial.CurrState.TrialID ~= Trial.PrevState.TrialID or Trial.CurrState.TrialProgress ~= Trial.PrevState.TrialProgress) then Trial.IsAtkStarted = false return
		-- If player finishes animation, set to false unless next action is a projectile
		elseif not (IsPlayerInState(P1, Trial.NextAction.state) or Trial.NextAction.state.type == "projectile") then Trial.IsAtkStarted = false return
		-- Set to false if projectile dissipates
		elseif (Trial.NextAction.state.type == "projectile" and P1.PrevState.ProjActive == true and P1.CurrState.ProjActive == false) then Trial.IsAtkStarted = false return
		end
	end
	if (Trial.IsAtkStarted == false) then Trial.IsAtkStarted = (IsPlayerInStartstate(P1, Trial.NextAction.state)) return end
	Trial.IsAtkStarted = true
end
local function SetHitCount()
	Trial.PrevState.IsStartstate = Trial.CurrState.IsStartstate
	Trial.CurrState.IsStartstate = IsPlayerInStartstate(P1, Trial.NextAction.state)
	if 
	(
		not Trial.IsAtkStarted or
		Trial.CurrState.TrialID ~= Trial.PrevState.TrialID or 
		Trial.CurrState.TrialProgress ~= Trial.PrevState.TrialProgress or
		(Trial.PrevState.IsStartstate == false and Trial.CurrState.IsStartstate == true) or
		IsComboDropped() or IsEnemyKD() or DefaultFail()
	) then Trial.HitCount = 0 end
	if (IsAtkCombo(Trial.NextAction.state) and Trial.IsAtkStarted) then Trial.HitCount = Trial.HitCount + 1 end
end
local function SetEnemyInput()
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
	-- Check if trial has setting for enemy attacking at specific interval
	if (Trial.CurrentTrial.enemyatk ~= nil) then
		if (Trial.CurrentTrial.enemyatkinterval == nil) then Trial.CurrentTrial.enemyatkinterval = DefaultAtkInterval end
		-- Check trial setting for enemy's specific button
		if (Trial.CurrentTrial.enemyatk == "LP") then Trial.EnemyAtk = "Weak Punch"
		elseif (Trial.CurrentTrial.enemyatk == "MP") then Trial.EnemyAtk = "Medium Punch"
		elseif (Trial.CurrentTrial.enemyatk == "HP") then Trial.EnemyAtk = "Strong Punch"
		elseif (Trial.CurrentTrial.enemyatk == "LK") then Trial.EnemyAtk = "Weak Kick"
		elseif (Trial.CurrentTrial.enemyatk == "MK") then Trial.EnemyAtk = "Medium Kick"
		elseif (Trial.CurrentTrial.enemyatk == "HK") then Trial.EnemyAtk = "Strong Kick"
		end
		Trial.EnemyAtkTimer = Trial.EnemyAtkTimer - 1
		if (Trial.EnemyAtkTimer <= 0) then
			if (type(Trial.EnemyAtk) == "string") then EnemyInputs[Trial.EnemyAtk] = true end
			Trial.EnemyAtkTimer = Trial.CurrentTrial.enemyatkinterval
		end
	end
end
-------------------------------------------------------Main execution loop-------------------------------------------------------
function TrialSupportHandler()
	SetAtkStarted()
	SetHitCount()
	SetEnemyInput()
end