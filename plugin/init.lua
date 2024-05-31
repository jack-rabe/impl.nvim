local M = {}

-- telescope
local themes = require("telescope.themes")
local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- treesitter
local treesitter = require("treesitter")

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
local get_interfaces = function()
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
local get_formatted_methods = function(interface, node, with_brackets)
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
local add_methods = function(interface, node, row_idx)
	local lines = get_formatted_methods(interface, node, true)
	vim.api.nvim_buf_set_lines(0, row_idx, row_idx, false, lines)
end

M.implement_interface = function(opts)
	local node, node_type, row_idx = treesitter.get_node_under_cursor()
	-- TODO make it be part of a type declaration
	if node_type ~= "type_identifier" then
		error("Treesitter node_type is " .. node_type .. ", must be type_identifier")
		return
	end

	opts = opts or {}
	local tmp_opts = themes.get_cursor()
	for k, v in pairs(opts) do
		tmp_opts[k] = v
	end
	opts = tmp_opts
	pickers
		.new(opts, {
			prompt_title = "Interfaces",
			finder = finders.new_table({
				results = get_interfaces(),
				---@param entry Go_Interface
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.package .. "." .. entry.name,
						ordinal = entry.package .. "." .. entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, _map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selected_interface = action_state.get_selected_entry().value
					add_methods(selected_interface, node, row_idx)
				end)
				return true
			end,
			previewer = previewers.new_buffer_previewer({
				title = "Interface preview",
				define_preview = function(self, entry, _status)
					local lines = get_formatted_methods(entry.value, node, false)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					require("telescope.previewers.utils").highlighter(self.state.bufnr, "go")
				end,
			}),
		})
		:find()
end

vim.keymap.set("n", "<leader>si", function()
	M.implement_interface()
end)

return M
