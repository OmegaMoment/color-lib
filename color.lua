-- i was too lazy for comments on this one

local Color3 = Color3
local typeof = typeof
local string = string

local color_main = {}
color_main.__type = 'color'
color_main.__index = color_main

-- mainly utility stuff

local function is_hsv(values)
	if typeof(values[1]) ~= "number" or values[1] < 0 or values[1] > 360 then
		return false
	end

	for i = 2, 3 do -- no need to copy and paste the same line over and over again
		if typeof(values[i]) ~= "number" or values[i] < 0 or values[i] > 1 then
			return false
		end
	end

	return true
end

local function is_rgb(values)
	for _, value in ipairs(values) do
		if typeof(value) ~= "number" or value < 0 or value > 1 then
			return false
		end
	end

	return true
end

local function is_hex(str)
	return string.match(str,'^#?%x%x%x%x%x%x$') ~= nil
end

local function hex_to_rgb(str)
	str = str:gsub("#","")
	return tonumber("0x"..str:sub(1,2)) / 255, tonumber("0x"..str:sub(3,4)) / 255, tonumber("0x"..str:sub(5,6)) / 255
end

-- main

function color_main.new(color_type, ...)
	local color_value = {...}
	color_type = string.lower(color_type)
	local hex_value = nil

	if color_type == 'rgb' then
		if #color_value ~= 3 or not is_rgb(color_value) then
			error('invalid RGB values, expected 3 values in the range of [0, 1]')
		end
	elseif color_type == 'hsv' then
		if #color_value ~= 3 or not is_hsv(color_value) then
			error('invalid HSV values, expected 3 values (H: [0, 360], S: [0, 1], V: [0, 1])')
		end
	elseif color_type == 'hex' then
		if #color_value ~= 1 or not is_hex(color_value[1]) then
			error("invalid HEX value, expected a string ('#RRGGBB' or 'RRGGBB')")
		end
		hex_value = color_value[1]
		color_value = {hex_to_rgb(color_value[1])}
	else
		error('invalid color type (RGB, HSV, HEX)')
	end

	local data = {
		color_type = color_type,
		color_value = color_value,
		hex_value = color_type == 'hex' and hex_value or nil
	}

	return setmetatable(data, color_main)
end

function color_main:set(color_type, ...) -- copy and paste :money:
	local color_value = {...}
	color_type = string.lower(color_type)
	local hex_value = nil

	if color_type == 'rgb' then
		if #color_value ~= 3 or not is_rgb(color_value) then
			error('invalid RGB values, expected 3 values in the range of [0, 1]')
		end
	elseif color_type == 'hsv' then
		if #color_value ~= 3 or not is_hsv(color_value) then
			error('invalid HSV values, expected 3 values (H: [0, 360], S: [0, 1], V: [0, 1])')
		end
	elseif color_type == 'hex' then
		if #color_value ~= 1 or not is_hex(color_value[1]) then
			error("invalid HEX value, expected a string ('#RRGGBB' or 'RRGGBB')")
		end
		hex_value = color_value[1]
		color_value = {hex_to_rgb(color_value[1])}
	else
		error('invalid color type (RGB, HSV, HEX)')
	end

	self.color_type = color_type
	self.color_value = color_value
	self.hex_value = color_type == 'hex' and hex_value or nil
end

function color_main:get_color()
	return self.color_value
end

function color_main:to_color3() -- i love roblox, best platform!
	if self.color_type == 'rgb' or self.color_type == 'hex' then
		return Color3.new(table.unpack(self.color_value))
	elseif self.color_type == 'hsv' then
		local h, s, v = table.unpack(self.color_value)
		return Color3.fromHSV(h / 360, s, v)
	end

	return nil
end

function color_main:__tostring()
	return string.format('%s color: %s', string.upper(self.color_type), self.hex_value or table.concat(self.color_value, ', '))
end

-- other metamethods

function color_main.__eq(a, b)
	if a.color_type ~= b.color_type then
		return false
	end

	for i = 1, #a.color_value do
		if a.color_value[i] ~= b.color_value[i] then
			return false
		end
	end

	return true
end

function color_main.__sub(a, b)
	assert(a.color_type == b.color_type, "color types must match for subtraction")
	local result = {}

	for i = 1, #a.color_value do
		result[i] = math.max(a.color_value[i] - b.color_value[i], 0)
	end

	return color_main.new(a.color_type, table.unpack(result))
end

function color_main.__add(a, b)
	assert(a.color_type == b.color_type, "color types must match for addition")
	local result = {}

	for i = 1, #a.color_value do
		result[i] = math.min(a.color_value[i] + b.color_value[i], 1)
	end

	return color_main.new(a.color_type, table.unpack(result))
end

return color_main
