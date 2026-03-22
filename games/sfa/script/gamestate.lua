-------------------------------------------------------Constants-------------------------------------------------------
GameMessage = {} -- Message when loading script
-- Menu values
Button_Confirm = "Weak Punch"
Button_Back = "Medium Punch"
InputHelperText = "LP - Confirm, MP - Back"
-- Player & game values
PlayerMaxHealth = 0x90 -- byte
PlayerMaxSuperMeter = 0x90 -- byte
MaxTimeCount = 0x6300 -- word
SlowestGameSpeed = 0x00 -- byte
NormalGameSpeed = 0x06 -- byte
-- Char ID's
T_CharID = 
{
	Ryu = 0,
	Ken = 1,
	Akuma = 2,
	Charlie = 3,
	ChunLi = 4,
	Adon = 5,
	Sodom = 6,
	Guy = 7,
	Birdie = 8,
	Rose = 9,
	Dictator = 10,
	Sagat = 11,
	Dan = 12,
}
-- Char name tables
T_CharShortname = 
{
	[0] = "ryu",
	[1] = "ken",
	[2] = "akuma",
	[3] = "charlie",
	[4] = "chunli",
	[5] = "adon",
	[6] = "sodom",
	[7] = "guy",
	[8] = "birdie",
	[9] = "rose",
	[10] = "dictator",
	[11] = "sagat",
	[12] = "dan",
}
T_CharName = 
{
	[0] = "Ryu",
	[1] = "Ken",
	[2] = "Akuma",
	[3] = "Charlie",
	[4] = "Chun-Li",
	[5] = "Adon",
	[6] = "Sodom",
	[7] = "Guy",
	[8] = "Birdie",
	[9] = "Rose",
	[10] = "M.Bison (Dictator)",
	[11] = "Sagat",
	[12] = "Dan",
}
-- Attack strength table
T_AtkStr =
{
	L = 0,
	M = 1,
	H = 2,
	Lv1 = 0,
	Lv2 = 1,
	Lv3 = 2,
	Lv4 = 3,
	Lv5 = 4,
	Lv6 = 5,
}
-------------------------------------------------------Addresses-------------------------------------------------------
	-- Player state addresses
Addr_PlayerChar = function(param_player) -- byte address
	return 0xFF84D1 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerHealth = function(param_player) -- byte address
	return 0xFF8441 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerRedHealth = function(param_player) -- byte address
	return 0xFF8443 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSuperMeter = function(param_player) -- byte address
	return 0xFF84BF + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerStun = function(param_player) -- byte address
	return 0xFF8537 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerStunTimer = function(param_player) -- byte address
	return 0xFF8536 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSideFacing = function(param_player) -- byte address
	return 0xFF840B + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerIsAirborne = function(param_player) -- byte address
	return 0xFF842F + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerComboCounter = function(param_player) -- byte address
	return 0xFF8857 - 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerCharState = function(param_player) -- word address
	return 0xFF8422 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSpecialID = function(param_player) -- word address
	return 0xFF8533 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerAtkStr = function(param_player) -- byte address
	return 0xFF8502 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerProjActive = function(param_player) -- byte address
	return 0xFF8524 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerRoseClones = function(param_player) -- byte address
	return 0xFF863E + 0x400*(param_player == P1 and 0 or 1) end
	-- Match state addresses
Addr_MatchTimer = 0xFFAE09 -- word address
Addr_GameSpeed = 0xFFAE14 -- byte address
-------------------------------------------------------State Variables-------------------------------------------------------
	-- Player 1 state values
P1.CurrState.Health = 0 -- byte
P1.CurrState.RedHealth = 0 -- byte
P1.CurrState.SuperMeter = 0 -- byte
P1.CurrState.ComboCounter = 0 -- byte
P1.CurrState.Stun = 0 -- byte
P1.CurrState.StunTimer = 0 -- byte
P1.CurrState.FacingLeft = false -- bool
P1.CurrState.IsAirborne = false -- bool
P1.CurrState.CharState = 0 -- word
P1.CurrState.SpecialID = 0 -- byte
P1.CurrState.AtkStr = 0 -- byte
P1.CurrState.InHitstun = false -- bool
P1.CurrState.ProjActive = false -- bool
P1.CurrState.ProjID = -1 -- int
P1.CurrState.ProjStr = -1 -- int
P1.CurrState.RoseClones = 0 -- bool
	-- Copy everything for player 2 state values
	CopyTable(P1.CurrState, P2.CurrState)
	-- Copy everything for previous frame values.
	CopyTable(P1.CurrState, P1.PrevState)
	CopyTable(P2.CurrState, P2.PrevState)
	-- Match state values
Match.CurrState.Timer = 0x0000 -- word
Match.CurrState.GameSpeed = 0 -- byte
-- Helper variables
RefillTimer = 0
-------------------------------------------------------Functions-------------------------------------------------------
	-- Basic read operations
function Read_PlayerCharID(param_player)
	return rb(Addr_PlayerChar(param_player)) end
function Read_PlayerHealth(param_player)
	return rb(Addr_PlayerHealth(param_player)) end
function Read_PlayerRedHealth(param_player)
	return rb(Addr_PlayerRedHealth(param_player)) end
function Read_PlayerSuperMeter(param_player)
	return rb(Addr_PlayerSuperMeter(param_player)) end
function Read_PlayerComboCounter(param_player)
	return rb(Addr_PlayerComboCounter(param_player)) end
function Read_PlayerStun(param_player)
	return rb(Addr_PlayerStun(param_player)) end
function Read_PlayerStunTimer(param_player)
	return rb(Addr_PlayerStunTimer(param_player)) end
function Read_PlayerFacingLeft(param_player)
	return rb(Addr_PlayerSideFacing(param_player))==0 end
function Read_PlayerIsAirborne(param_player)
	return rb(Addr_PlayerIsAirborne(param_player))~=0 end
function Read_PlayerCharState(param_player)
	return rw(Addr_PlayerCharState(param_player)) end
function Read_PlayerSpecialID(param_player)
	return rb(Addr_PlayerSpecialID(param_player))/2 end
function Read_PlayerAtkStr(param_player)
	return rb(Addr_PlayerAtkStr(param_player))/2 end
function Read_PlayerProjActive(param_player)
	return rb(Addr_PlayerProjActive(param_player))~=0 end
function Read_PlayerRoseClones(param_player)
	if (Read_PlayerCharID(param_player) == T_CharID.Rose) then return rb(Addr_PlayerRoseClones(param_player)) end
	return 0
end
function Read_PlayerInHitstun(param_player) -- Check if combo's still going
	return rb(Addr_PlayerComboCounter(param_player == P1 and P2 or P1))~=0 end
function Read_MatchTimer()
	return rw(Addr_MatchTimer) end
	-- Basic write operations
function Write_PlayerHealth(param_player, param_health)
	wb(Addr_PlayerHealth(param_player), param_health)
	wb(Addr_PlayerRedHealth(param_player), param_health)
end
function Write_PlayerSuperMeter(param_player, param_meter)
	wb(Addr_PlayerSuperMeter(param_player), param_meter)
end