-- Memory addresses & values for Street Fighter Alpha 2

-------------------------------------------------------Constants-------------------------------------------------------
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
	Sakura = 13,
	Rolento = 14,
	Dhalsim = 15,
	Zangief = 16,
	Gen_Mantis = 17,
	ChunLi_EX = 18,
	Gen_Crane = 19,
	Akuma_Shin = 20,
	Zangief_EX = 21,
	Dhalsim_EX = 22,
	Ryu_Evil = 23,
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
	[13] = "sakura",
	[14] = "rolento",
	[15] = "dhalsim",
	[16] = "zangief",
	[17] = "gen",
	[18] = "chunli_ex",
	[19] = "gen",
	[20] = "akuma",
	[21] = "zangief_ex",
	[22] = "dhalsim_ex",
	[23] = "ryu_ex",
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
	[13] = "Sakura",
	[14] = "Rolento",
	[15] = "Dhalsim",
	[16] = "Zangief",
	[17] = "Gen",
	[18] = "Classic Chun-Li",
	[19] = "Gen",
	[20] = "Shin Akuma",
	[21] = "Old Zangief",
	[22] = "Old Dhalsim",
	[23] = "Evil Ryu",
}
-- Attack strength table
T_AtkStr =
{
	L = 0,
	M = 1,
	H = 2,
	MaxCC = 3,
	Lv1 = 0,
	Lv2 = 1,
	Lv3 = 2,
	Lv4 = 3,
	Lv5 = 4,
	Lv6 = 5,
}
T_AtkType =
{
	P = 0,
	K = 1,
}
-------------------------------------------------------Addresses-------------------------------------------------------
	-- Player state addresses
Addr_PlayerChar = function(param_player) -- byte address
	return 0xFF8482 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerHealth = function(param_player) -- byte address
	return 0xFF8451 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerRedHealth = function(param_player) -- byte address
	return 0xFF8453 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSuperMeter = function(param_player) -- byte address
	return 0xFF849F + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerStun = function(param_player) -- byte address
	return 0xFF8537 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerStunTimer = function(param_player) -- byte address
	return 0xFF8536 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerCCTimer = function(param_player) -- byte address
	return 0xFF869A + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSideFacing = function(param_player) -- byte address
	return 0xFF840B + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerIsAirborne = function(param_player) -- byte address
	return 0xFF8431 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerComboCounter = function(param_player) -- byte address
	return 0xFF885E - 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerCharState = function(param_player) -- word address
	return 0xFF841E + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerSpecialID = function(param_player) -- word address
	return 0xFF8533 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerAtkStr = function(param_player) -- byte address
	return 0xFF8502 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerAtkType = function(param_player) -- byte address
	return 0xFF8501 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerProjActive = function(param_player) -- byte address
	return 0xFF8638 + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerRoseClones = function(param_player) -- byte address
	return 0xFF863E + 0x400*(param_player == P1 and 0 or 1) end
Addr_PlayerGenCountdown = function(param_player) -- word address
	return 0xFF8684 + 0x400*(param_player == P1 and 0 or 1) end
	-- Match state addresses
Addr_MatchTimer = 0xFF8109 -- word address
Addr_GameSpeed = 0xFF8116 -- byte address
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
P1.CurrState.AtkType = 0 -- byte
P1.CurrState.InHitstun = false -- bool
P1.CurrState.ProjActive = false -- bool
P1.CurrState.ProjID = -1 -- int
P1.CurrState.ProjStr = -1 -- int
P1.CurrState.CCActive = false -- bool
P1.CurrState.RoseClones = 0 -- bool
	-- Copy everything for player 2 state values
	P2.CurrState = Helper.CopyTable(P1.CurrState)
	-- Copy everything for previous frame values.
	P1.PrevState = Helper.CopyTable(P1.CurrState)
	P2.PrevState = Helper.CopyTable(P2.CurrState)
	-- Match state values
Match.CurrState.Timer = 0x0000 -- word
Match.CurrState.GameSpeed = 0 -- byte
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
function Read_PlayerAtkType(param_player)
	return rb(Addr_PlayerAtkType(param_player))/2 end
function Read_PlayerProjActive(param_player)
	return rb(Addr_PlayerProjActive(param_player))~=0 end
function Read_PlayerCCActive(param_player)
	return rb(Addr_PlayerCCTimer(param_player))~=0 end
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