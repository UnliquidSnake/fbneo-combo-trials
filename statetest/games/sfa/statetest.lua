local function copyTable(t_src, t_dst) -- Copy all values from one table to another
	if (type(t_src) ~= "table" or type(t_dst) ~= "table") then return false end
	for k,v in pairs(t_src) do t_dst["" .. k] = v end
	return true
end
-------------------------------------------------------Tables & Variables-------------------------------------------------------
-- Tables for player values
local P1State = {}
local P2State = {}
P1State.CurrState = {}
P2State.CurrState = {}
P1State.PrevState = {}
P2State.PrevState = {}
-- Addresses
local addr_p1charstate = 0xFF8422
local addr_p2charstate = 0xFF8822
local addr_p1specialid = 0xFF8533
local addr_p2specialid = 0xFF8933
local addr_p1atkstr = 0xFF8502
local addr_p2atkstr = 0xFF8902
local addr_gamespeed = 0xFFAE14
-- Constants
	-- Game speed
local GameSpeed_Slowest = 0x00
local GameSpeed_Normal = 0x02
local GameSpeed_Turbo = 0x06
	-- GUI settings
local P1TextPosX = 104
local P1TextPosY = 32
local P2TextPosX = 215
local P2TextPosY = 32
-- State variables
local FrameCount = 0
-- Player state variables
P1State.CurrState.CharState = 0 -- word
P1State.CurrState.SpecialID = 0 -- byte
P1State.CurrState.AtkStr = 0 -- byte
-- Copy everything for player 2 state values
copyTable(P1State.CurrState, P2State.CurrState)
-- Copy everything for previous frame values
copyTable(P1State.CurrState, P1State.PrevState)
copyTable(P2State.CurrState, P2State.PrevState)
-------------------------------------------------------Functions-------------------------------------------------------
local function readPlayerOneCharState()
	return rw(addr_p1charstate) end
local function readPlayerTwoCharState()
	return rw(addr_p2charstate) end
local function readPlayerOneSpecialID()
	return rb(addr_p1specialid)/2 end
local function readPlayerTwoSpecialID()
	return rb(addr_p2specialid)/2 end
local function readPlayerOneAtkStr()
	return rb(addr_p1atkstr)/2 end
local function readPlayerTwoAtkStr()
	return rb(addr_p2atkstr)/2 end
local function setGameSpeed(param_speed)
	wb(addr_gamespeed, param_speed) end

local function updateStateVars()
	-- Update framecount
	FrameCount = FrameCount + 1
	-- Update previous frame values
	copyTable(P1State.CurrState, P1State.PrevState)
	copyTable(P2State.CurrState, P2State.PrevState)
	-- Update current frame values
	P1State.CurrState.CharState = readPlayerOneCharState()
	P2State.CurrState.CharState = readPlayerTwoCharState()
	P1State.CurrState.SpecialID = readPlayerOneSpecialID()
	P2State.CurrState.SpecialID = readPlayerTwoSpecialID()
	P1State.CurrState.AtkStr = readPlayerOneAtkStr()
	P2State.CurrState.AtkStr = readPlayerTwoAtkStr()
	-- Update text
	P1CharStateText = string.format("CharState: 0x%x", P1State.CurrState.CharState)
	P1SpecialIDText = string.format("SpecialID: %d", P1State.CurrState.SpecialID)
	P1AtkStrText = string.format("AtkStr: %d", P1State.CurrState.AtkStr)
	P2CharStateText = string.format("CharState: 0x%x", P2State.CurrState.CharState)
	P2SpecialIDText = string.format("SpecialID: %d", P2State.CurrState.SpecialID)
	P2AtkStrText = string.format("AtkStr: %d", P2State.CurrState.AtkStr)
end

local function drawStateText()
	gui.text(P1TextPosX,P1TextPosY,P1CharStateText)
	gui.text(P1TextPosX,P1TextPosY+10,P1SpecialIDText)
	gui.text(P1TextPosX,P1TextPosY+20,P1AtkStrText)
	gui.text(P2TextPosX,P2TextPosY,P2CharStateText)
	gui.text(P2TextPosX,P2TextPosY+10,P2SpecialIDText)
	gui.text(P2TextPosX,P2TextPosY+20,P2AtkStrText)
end
local function writeStateText(file)
	if (P1CurrState == P1PrevState) then P1CurrStateText = "prev" end
	if (P2CurrState == P2PrevState) then P2CurrStateText = "prev" end
	if (P1CurrState ~= P1PrevState or P2CurrState ~= P2PrevState) then file:write(FrameCount .. ":" .. P1CurrStateText .. ";" .. P2CurrStateText .. "\n") end
end
-------------------------------------------------------Main execution loop-------------------------------------------------------
function runStateTest() -- runs every frame
	setGameSpeed(GameSpeed_Slowest)
	updateStateVars()
	drawStateText()
	--writeStateText(statefile)
end