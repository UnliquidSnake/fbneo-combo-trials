-- Module for universal helper functions; all manner of stuff that has nothing to do with the trials specifically

local helper = {}

function helper.GetCurrentTimestamp()
	return os.date("%Y-%m-%d %H:%M:%S", os.time()) end
function helper.GetCWD() -- Get current working directory of Lua interpreter
	local cwd = ""
	-- Check what directory separator is used by the environment, used to determine user's OS
	local separator = package.config:sub(1,1)
	-- Use specific shell command to get CWD depending on user's OS. '\' symbol is used for Windows, '/' symbol is used for Unix-based systems
	if (separator == '\\') then cwd = io.popen("cd"):read()
	else cwd = io.popen("pwd"):read() 
	end
	return cwd
end
function helper.IsInteger(param_number) -- Use for Lua versions prior to 5.4 where math.type() doesn't exist
	return (tostring(param_number) == string.format("%i", param_number)) end
function helper.BCD(param_number) -- Takes a number as though it were hexadecimal and converts it to BCD
	if not (type(param_number) == "number") then return nil end
	local bcdtable = {}
	local dec = param_number
	repeat
		local digit = dec % 16
		if (digit > 9) then return nil end
		table.insert(bcdtable, 1, digit)
		dec = math.floor(dec / 16)
	until dec == 0
	for i = 1, #bcdtable do dec = dec + (bcdtable[#bcdtable + 1 - i] * 10^(i-1)) end
	return dec
end
function helper.IsValidMD5(param_string)
	return (#param_string == 32 and param_string:match("^%x+$")) end
function helper.IsValidSHA1(param_string)
	return (#param_string == 40 and param_string:match("^%x+$")) end
function helper.IsValidCRC32(param_string)
	return (#param_string == 8 and param_string:match("^%x+$")) end
function helper.IsValidTimestamp(param_string)
	local y, m, d, h, min, s = param_string:match("^(%d%d%d%d)%-(%d%d)%-(%d%d) (%d%d):(%d%d):(%d%d)$")
	if not y then return false end
	-- Convert everything into numbers
	y, m, d, h, min, s = tonumber(y), tonumber(m), tonumber(d), tonumber(h), tonumber(min), tonumber(s)
	-- Check for valid timestamp with os.time() function
	local date_table = { year = y, month = m, day = d, hour = h, min = min, sec = s }
	local converted_time = os.time(date_table)
	if not converted_time then return false end
	-- Double-check for normalization issues
	local normalized = os.date("*t", converted_time)

	return 
	(
		normalized.year == y and 
		normalized.month == m and 
		normalized.day == d and 
		normalized.hour == h and 
		normalized.min == min and 
		normalized.sec == s
	)
end
-- Scroll to the previous or next element in a sequence of elements of specific length. Will also cycle between first and last element
function helper.SelectNext(param_i, param_len)
	return param_i % param_len + 1 end
function helper.SelectPrevious(param_i, param_len)
	return (param_i + param_len - 2) % param_len + 1 end
-- Table functions
function helper.CopyTable(param_table) -- Copy all values from one table to another
	if (type(param_table) ~= "table") then return param_table end
	local t_copy = {}
	for k,v in pairs(param_table) do t_copy[k] = v end
	return t_copy
end
function helper.DeepCopy(param_table) -- Copy all values recursively from one table to another, will also copy nested tables
	-- If passed argument is not a table, return it as is
	if (type(param_table) ~= "table") then return param_table end
	local t_copy = {}
	for k,v in pairs(param_table) do t_copy[k] = helper.DeepCopy(v) end
	return t_copy
end
function helper.AddTable(param_t1, param_t2) -- Add one table to another provided both have numeric indices, return combined table
	if (type(param_t1) ~= "table" or type(param_t2) ~= "table") then return nil end
	local t1_size = 0
	local t2_size = 0
	-- Check that both tables contain only numeric indices with no holes
	for _, v in pairs(param_t1) do t1_size = t1_size + 1 end
	for _, v in pairs(param_t2) do t2_size = t2_size + 1 end
	if not (t1_size == #param_t1 and t2_size == #param_t2) then return nil end
	-- Construct combined table
	local t_comb = {}
	for _, v in pairs(param_t1) do table.insert(t_comb, v) end
	for _, v in pairs(param_t2) do table.insert(t_comb, v) end
	return t_comb
end
function helper.CombineTable(param_t1, param_t2) -- Combine two tables into one, return combined table. Any shared values will be overwritten by second table's values
	if (type(param_t1) ~= "table" or type(param_t2) ~= "table") then return nil end
	local t_comb = {}
	for k,v in pairs(param_t1) do t_comb[k] = v end
	for k,v in pairs(param_t2) do t_comb[k] = v end
	return t_comb
end
function helper.DeepCombine(param_t1, param_t2) -- Same thing for nested tables
	if (type(param_t1) ~= "table" or type(param_t2) ~= "table") then return nil end
	local t_comb = {}
	for k,v in pairs(param_t1) do t_comb[k] = helper.DeepCopy(v) end
	for k,v in pairs(param_t2) do t_comb[k] = helper.DeepCopy(v) end
	return t_comb
end
-- File loading functions
function helper.IsFileExists(param_filepath) -- Check for opening file, taken from peon2's training script
	local fs = io.open(param_filepath,"r")
	local res = fs~=nil
	if (res) then fs:close() end
	return res
end
function helper.LoadModule(param_filepath, param_errormsg) -- Try to load module via require function, throw up error if unsuccessful
	if not helper.IsFileExists(param_filepath) then error(param_errormsg) end
	return require(param_filepath:match("(.+)%.[^.]+$"))
end
function helper.DoFile(param_filepath, param_errormsg) -- Try to load script, throw up error if unsuccessful
	if not helper.IsFileExists(param_filepath) then error(param_errormsg) end
	return dofile(param_filepath)
end
function helper.ReadLinesFromFile(param_filepath, param_errorname)
	if not helper.IsFileExists(param_filepath) then error("ERROR: Cannot find " .. param_errorname) end
	local file = io.open(param_filepath, "rb")
	if (file == nil) then error("ERROR: Cannot open " .. param_errorname) end
	local lines = {}
	while true do
		nxtline = file:read()
		if (nxtline == nil) then break end -- Stop reading at eof
		-- Ignore comments that span the whole line
		if not (nxtline:find("^%s*%-%-")) then
			nxtline = nxtline:gsub("[\n\r]", "") -- Remove endline symbols from line
			table.insert(lines, nxtline)
		end
	end
	file:close()
	if not (#lines > 0) then error("ERROR: " .. param_errorname .. " is empty") end
	return lines
end
function helper.ParseIniFile(param_filepath, param_errorname)
	-- Read lines
	local lines = helper.ReadLinesFromFile(param_filepath, param_errorname)
	local data = {}
    local current_section = "default"

    for _, line in ipairs(lines) do
        -- Remove whitespace and empty lines, ignore everything after comment symbols (; or #)
        line = line:match("^%s*(.-)%s*$"):gsub("[;#].*", "")
        if line ~= "" then
            -- Match sections
            local section = line:match("^%[(.-)%]$")
            if section then
                current_section = section
                data[current_section] = data[current_section] or {}
            else
                -- Match key-value pairs
                local key, value = line:match("^([^=]+)=(.-)$")
                if key and value then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    
                    data[current_section][key] = value
                    -- Do not auto-convert numbers and booleans inside this function, that can come later
                end
            end
        end
    end

    return data
end

return helper