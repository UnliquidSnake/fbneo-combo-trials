-- Main script for Street Fighter Alpha 2

local GameRoutine = {}
-------------------------------------------------------Loading routine-------------------------------------------------------
-- Load helper script for player variables
local Path_GameState = "games/" .. GameFolder .. "/script/gamestate.lua"
Helper.LoadModule(Path_GameState, "ERROR: Cannot find gamestate script")
-------------------------------------------------------Constants-------------------------------------------------------
-- Define path for game-specific trial functions & helper script for player variables
Path_TrialFunctions = "script/trial_funcs/cps2-functions.lua"
-- Message values
GameMessage = {} -- Message when loading script
CharMessage = function() return P1.CharName .. " vs. " .. P2.CharName end
-- Button table & helper values
Buttons = 
{
	LP = "Weak Punch",
	MP = "Medium Punch",
	HP = "Strong Punch",
	LK = "Weak Kick",
	MK = "Medium Kick",
	HK = "Strong Kick",
}
Button_Confirm = Buttons.LP
Button_Back = Buttons.MP
InputHelperText = "LP - Confirm, MP - Back"
-- Refill timer
local RefillTimer = 0
-------------------------------------------------------Functions-------------------------------------------------------
function CfgRoutine.CheckSecondaryErrors(param_cfgobj) -- Error handling of game-specific config values
	-- Read values from config file
	local config_p1meter = param_cfgobj.P1RefillSuperMeter
	-- Check integrity of config values
	if not (type(config_p1meter) == "number" and Helper.IsInteger(config_p1meter) and config_p1meter >= 0 and config_p1meter <= PlayerMaxSuperMeter) then
		error("ERROR: Config parameter P1RefillSuperMeter has incorrect value") end
end
function GameRoutine.SetInfiniteTime() -- Freeze timer
	ww(Addr_MatchTimer, MaxTimeCount) end
function GameRoutine.SetInfiniteStun() -- Freeze stun values
	wb(Addr_PlayerStun(P1), 0)
	wb(Addr_PlayerStun(P2), 0)
end
function GameRoutine.RemoveGenCountdown() -- Remove the countdown for Gen's stun super, preventing additional damage & stun
	ww(Addr_PlayerGenCountdown(P1), 0)
	ww(Addr_PlayerGenCountdown(P2), 0)
end
function GameRoutine.SetGameSpeed(param_speed) -- Set game speed to specific value
	wb(Addr_GameSpeed, param_speed) end
function GameRoutine.RefillPlayers() -- Refill HP & meters
	local Refill = {P1Health, P2Health, P1SuperMeter, P2SuperMeter = 0}
	Refill.P1Health = PlayerMaxHealth
	Refill.P2Health = PlayerMaxHealth
	Refill.P1SuperMeter = Config.P1RefillSuperMeter
	Refill.P2SuperMeter = PlayerMaxSuperMeter
	-- If trial has specified values for player 1's meter, use those
	if (Trial.CurrentTrial ~= nil and Trial.CurrentTrial.p1meter ~= nil) then Refill.P1SuperMeter = Trial.CurrentTrial.p1meter end
	Write_PlayerHealth(P1, Refill.P1Health)
	Write_PlayerHealth(P2, Refill.P2Health)
	Write_PlayerSuperMeter(P1, Refill.P1SuperMeter)
	Write_PlayerSuperMeter(P2, Refill.P2SuperMeter)
end
function GameRoutine.RefillHandler() -- Control timer & conditions for refills
	-- Refill on a timer if following things happen:
	if 
	(
		-- If either player took damage or spent meter
		P1.CurrState.Health < P1.PrevState.Health or
		P2.CurrState.Health < P2.PrevState.Health or
		P1.CurrState.SuperMeter < P1.PrevState.SuperMeter or
		P2.CurrState.SuperMeter < P2.PrevState.SuperMeter
	) then RefillTimer = Config.MaxRefillTimer end
	-- Refill instantly if following things happen
	if
	(	-- If switched trial or dropped the combo
		Trial.CurrState.TrialID ~= Trial.PrevState.TrialID or
		P1.CurrState.ComboCounter < P1.PrevState.ComboCounter or
		IsPlayerInState(P2, P2.StateTable.Basic.Knockdown) or
		IsPlayerInState(P2, P2.StateTable.Basic.Recovery)
	) then RefillTimer = 0 end
	if (RefillTimer > 0) then RefillTimer = RefillTimer-1 end
	if (RefillTimer == 0) then GameRoutine.RefillPlayers() end
end
function GameRoutine.UpdateGameVars()
	-- Update player values
	PlayerFuncs =
	{
		Health = Read_PlayerHealth,
		RedHealth = Read_PlayerRedHealth,
		SuperMeter = Read_PlayerSuperMeter,
		ComboCounter = Read_PlayerComboCounter,
		Stun = Read_PlayerStun,
		StunTimer = Read_PlayerStunTimer,
		FacingLeft = Read_PlayerFacingLeft,
		IsAirborne = Read_PlayerIsAirborne,
		CharState = Read_PlayerCharState,
		SpecialID = Read_PlayerSpecialID,
		AtkStr = Read_PlayerAtkStr,
		AtkType = Read_PlayerAtkType,
		InHitstun = Read_PlayerInHitstun,
		ProjActive = Read_PlayerProjActive,
		CCActive = Read_PlayerCCActive,
		RoseClones = Read_PlayerRoseClones,
	}
	
	for k,v in pairs(PlayerFuncs) do
		P1.CurrState[k] = v(P1)
		P2.CurrState[k] = v(P2)
	end
	-- Update projectile detection values
	if (P1.PrevState.ProjActive == false and P1.CurrState.ProjActive == true) then
		P1.CurrState.ProjID = P1.CurrState.SpecialID
		P1.CurrState.ProjStr = P1.CurrState.AtkStr
	end
	if (P1.PrevState.ProjActive == true and P1.CurrState.ProjActive == false) then
		P1.CurrState.ProjID = -1
		P1.CurrState.ProjStr = -1
	end
	-- Update match values
	Match.CurrState.Timer = Read_MatchTimer()
end
------------------------------------------------------Execution-------------------------------------------------------
function InitRoutine.GameInit()
	GameRoutine.RefillPlayers()
end
function ExecRoutine.GameExec()
	GameRoutine.UpdateGameVars()
	GameRoutine.SetInfiniteTime()
	GameRoutine.SetInfiniteStun()
	GameRoutine.RemoveGenCountdown()
	GameRoutine.SetGameSpeed(SlowestGameSpeed)
	GameRoutine.RefillHandler()
end
function GuiRoutine.DebugGui()
	gui.text(Config.DebugTextPosX,Config.DebugTextPosY,"HitCount: " .. Trial.HitCount)
	gui.text(Config.DebugTextPosX,Config.DebugTextPosY+CharIntervalY,"AtkStarted: " .. tostring(Trial.IsAtkStarted))
	gui.text(Config.DebugTextPosX,Config.DebugTextPosY+CharIntervalY*2,"EnemyAtkTimer: " .. Trial.EnemyAtkTimer)
end

return GameRoutine