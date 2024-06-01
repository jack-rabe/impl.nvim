local M = {}

local utils = require("utils")

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

---@param path string
---@return Go_Interface[]
local get_interfaces_for_path = function(path)
	local result = {}
	local content = ""
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok then
		return {}
	end
	for _, line in ipairs(lines) do
		content = content .. line
	end
	---@type Go_Interface[]
	local interfaces = require("json"):decode(content)

	for _, i in ipairs(interfaces) do
		if #i.methods > 0 then
			table.insert(result, i)
		end
	end

	return result
end

---@return Go_Interface[]
M.get_interfaces = function()
	-- add stdlib interfaces
	local stdlib_path = utils.impl_data_path .. "interfaces.json"
	local interfaces = get_interfaces_for_path(stdlib_path)

	-- add project interfaces
	local git_root_dir = vim.fn.system("git rev-parse --show-toplevel")
	git_root_dir = git_root_dir:gsub("[\n\r]", " ")
	local success = vim.api.nvim_eval("v:shell_error") == 0
	if not success then
		error("Failed to run ImplSearch, must be inside a Git directory")
	end
	local current_repo_path = utils.impl_data_path .. utils.hash(git_root_dir) .. ".json"
	local project_interfaces = get_interfaces_for_path(current_repo_path)
	for _, value in ipairs(project_interfaces) do
		table.insert(interfaces, value)
	end

	return interfaces
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

M.generate_interfaces_for_project = function()
	local git_root_dir = vim.fn.system("git rev-parse --show-toplevel")
	git_root_dir = git_root_dir:gsub("[\n\r]", " ")
	local success = vim.api.nvim_eval("v:shell_error") == 0
	if not success then
		error("Failed to run ImplGenerate, must be inside a Git directory")
	end

	local output_path = utils.impl_data_path .. utils.hash(git_root_dir) .. ".json"
	local response = vim.fn.system("impl -path " .. git_root_dir .. " -output " .. output_path)
	print(response)
end

M.generate_interfaces_for_stdlib = function()
	vim.fn.system("mkdir -p " .. utils.impl_data_path)
	local output_path = utils.impl_data_path .. "interfaces.json"
	local response = vim.fn.system("impl -output " .. output_path)
	print(response)
end

return M
