local M = {}

local RETURN_MAP = {
	string = '""',
	bool = "true",
	any = "nil",
	error = "nil",
	int = 0,
	int8 = 0,
	int16 = 0,
	int32 = 0,
	int64 = 0,
	uint = 0,
	uint8 = 0,
	uint16 = 0,
	uint32 = 0,
	uint64 = 0,
	uintptr = 0,
	byte = 0,
	rune = 0,
	float32 = 0,
	float64 = 0,
	complex64 = 0,
	complex128 = 0,
}

---@alias Go_Interface { name: string, package: string, methods: {content: string, return_type: string}[], filename: string }

---@return Go_Interface[]
M.get_interfaces = function()
	local file_path = vim.fn.stdpath("data") .. "/interfaces.json"
	local content = ""
	local lines = vim.fn.readfile(file_path)
	for _, line in ipairs(lines) do
		content = content .. line
	end
	---@type Go_Interface[]
	local interfaces = require("json"):decode(content)
	local filtered_interfaces = {}

	-- skip interfaces with 0 methods
	for _, i in ipairs(interfaces) do
		if #i.methods > 0 then
			table.insert(filtered_interfaces, i)
		end
	end
	return filtered_interfaces
end

---@param interface Go_Interface
---@param node string
---@param with_brackets boolean
M.get_formatted_methods = function(interface, node, with_brackets)
	local lines = {}
	for _, method in ipairs(interface.methods) do
		local lower_first_char = string.lower(string.sub(node, 1, 1))
		local formatted_method = string.format("func (%s %s) %s", lower_first_char, node, method.content)
		if with_brackets then
			formatted_method = formatted_method .. " {"
		end
		table.insert(lines, formatted_method)
		if with_brackets then
			-- TODO lists? definitely parameter types, errors
			local return_type = RETURN_MAP[method.return_type] or ""
			table.insert(lines, "    return " .. return_type)
			table.insert(lines, "}")
		end
	end
	return lines
end

---@param interface Go_Interface
---@param node string
---@param row_idx integer
M.add_methods = function(interface, node, row_idx)
	local lines = M.get_formatted_methods(interface, node, true)
	vim.api.nvim_buf_set_lines(0, row_idx, row_idx, false, lines)
end

return M
