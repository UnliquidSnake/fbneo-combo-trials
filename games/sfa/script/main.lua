-------------------------------------------------------Loading routine-------------------------------------------------------
local Path_HelperScript = "games/" .. GameFolder .. "/script/gamestate.lua"
LoadScript(Path_HelperScript, "ERROR: Cannot find gamestate file for " .. GameFolder)
Path_TrialFunctions = "script/trial_funcs/cps2-functions.lua"
-------------------------------------------------------Functions-------------------------------------------------------
function CheckSecondaryConfigErrors() -- Error handling of game-specific config values
	-- Read values from config file
	local config_p1meter = Config.P1RefillSuperMeter
	-- Check integrity of config values
	if not(type(config_p1meter) == "number" and IsInteger(config_p1meter) and config_p1meter >= 0 and config_p1meter <= PlayerMaxSuperMeter) then
		error("ERROR: Config parameter P1RefillSuperMeter has incorrect value") end
end
local function LoadCharData() -- Get character data for trials & filepaths for loading rest of the script
	P1.CharID = Read_PlayerCharID(P1)
	P2.CharID = Read_PlayerCharID(P2)
	P1.CharShortname = T_CharShortname[P1.CharID]
	P2.CharShortname = T_CharShortname[P2.CharID]
	P1.CharName = T_CharName[P1.CharID]
	P2.CharName = T_CharName[P2.CharID]
	print ("Detected chars: " .. P1.CharName .. " vs. " .. P2.CharName)
	-- Set paths for char-specific files
	Path_P1StateData = "games/" .. GameFolder .. "/char_data/" .. P1.CharShortname .. ".chr"
	Path_P2StateData = "games/" .. GameFolder .. "/char_data/" .. P2.CharShortname .. ".chr"
	Path_TrialData = "games/" .. GameFolder .. "/trial_data/" .. P1.CharShortname .. ".tr"
	-- Load character state data
	LoadScript(Path_P1StateData, "ERROR: Cannot find character data for player 1")
	P1.StateTable = CharStateTable
	LoadScript(Path_P2StateData, "ERROR: Cannot find character data for player 2")
	P2.StateTable = CharStateTable
	if not (type(P1.StateTable) == "table") then error("ERROR: Empty or missing state table for player 1") end
	if not (type(P2.StateTable) == "table") then error("ERROR: Empty or missing state table for player 2") end
end
local SetInfiniteTime = function() -- Freeze timer
	ww(Addr_MatchTimer, MaxTimeCount) end
local SetInfiniteStun = function() -- Freeze stun values
	wb(Addr_PlayerStun(P1), 0)
	wb(Addr_PlayerStun(P2), 0)
end
local SetGameSpeed = function(param_speed) -- Set game speed to specific value
	wb(Addr_GameSpeed, param_speed) end
local RefillPlayers = function() -- Refill HP & meters
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
local RefillHandler = function() -- Control timer & conditions for refills
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
	if (RefillTimer == 0) then RefillPlayers() end
end
local UpdateLocalVars = function()
	-- Update previous frame values
	CopyTable(P1.CurrState, P1.PrevState)
	CopyTable(P2.CurrState, P2.PrevState)
	CopyTable(Match.CurrState, Match.PrevState)
	-- Update current frame values
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
		InHitstun = Read_PlayerInHitstun,
		ProjActive = Read_PlayerProjActive,
		RoseClones = Read_PlayerRoseClones,
	}
	-- Update player values
	for k,v in pairs(PlayerFuncs) do
		P1.CurrState["" .. k] = v(P1)
		P2.CurrState["" .. k] = v(P2)
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
------------------------------------------------------Main execution loop-------------------------------------------------------
function UpdateGameGUI()
	if (Config.DisplayDebugText == true) then DisplayDebugText() end
end
function GameHandler()
	UpdateLocalVars()
	SetInfiniteTime()
	SetInfiniteStun()
	SetGameSpeed(SlowestGameSpeed)
	RefillHandler()
end
-------------------------------------------------------First run routine-------------------------------------------------------
LoadConfig()
LoadCharData()
print ("Loaded character state data")
RefillPlayers()