-------------------------------------------------------Variables-------------------------------------------------------
P1.FreezeGameInputs = false -- bool
P2.FreezeGameInputs = false -- bool
-- Input arrays
P1.CurrInputs = {}
P1.PrevInputs = {}
P2.CurrInputs = {}
P2.PrevInputs = {}
P1.CurrGameInputs = {}
P1.PrevGameInputs = {}
P2.CurrGameInputs = {}
P2.PrevGameInputs = {}
EnemyInputs = {} -- Buffer for enemy inputs in trial settings
-------------------------------------------------------Functions-------------------------------------------------------
function IsPressed(param_player, param_button)
	if not (param_player == P1 or param_player == P2) then return false end
	if (param_player.PrevInputs[param_button] == false and param_player.CurrInputs[param_button] == true) then return true end
	return false
end
function IsReleased(param_player, param_button)
	if not (param_player == P1 or param_player == P2) then return false end
	if (param_player.PrevInputs[param_button] == true and param_player.CurrInputs[param_button] == false) then return true end
	return false
end
local function SetGameInput(param_p1table, param_p2table)
	if not (type(param_p1table) == "table" and type(param_p2table) == "table") then return end
	local GameInput = {}
	for k,v in pairs(param_p1table) do GameInput["P1 " .. k] = v end
	for k,v in pairs(param_p2table) do GameInput["P2 " .. k] = v end
	joypad.set(GameInput)
end
local function CheckLuaHotkeys() -- Register Lua hotkey inputs
	input.registerhotkey(1, ToggleMenu)
	input.registerhotkey(2, OpenTrialMenu)
end
-------------------------------------------------------Main execution loop-------------------------------------------------------
function InputHandler()
	CheckLuaHotkeys()
	-- Freeze P2's inputs to prevent uncalled for situations
	P2.FreezeGameInputs = true
	-- Update deltas
	CopyTable(P1.CurrInputs,P1.PrevInputs)
	CopyTable(P2.CurrInputs,P2.PrevInputs)
	CopyTable(P1.CurrGameInputs,P1.PrevGameInputs)
	CopyTable(P2.CurrGameInputs,P2.PrevGameInputs)
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
			if (P1.FreezeGameInputs == true) then P1.CurrGameInputs[InputStr] = false end
		end
		if PlayerStr == "P2" then
			P2.CurrInputs[InputStr] = v
			-- If button is pressed, carry over to game inputs
			if (P2.CurrInputs[InputStr] == true) then P2.CurrGameInputs[InputStr] = true end
			if (P2.FreezeGameInputs == true) then P2.CurrGameInputs[InputStr] = false end
		end
		-- Add enemy settings to P2 inputs
		P2.CurrGameInputs = CombineTable(P2.CurrGameInputs, EnemyInputs)
	end
	SetGameInput(P1.CurrGameInputs, P2.CurrGameInputs)
end