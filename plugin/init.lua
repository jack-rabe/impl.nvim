-- telescope
local themes = require("telescope.themes")
local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- treesitter
local parsers = require("nvim-treesitter.parsers")
-- other
local json = require("json")

---@alias Go_Interface { name: string, package: string, methods: {content: string, return_type: string}[], filename: string }

local return_map = {
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

---@return Go_Interface[]
local get_interfaces = function()
	local file_path = vim.fn.stdpath("data") .. "/interfaces.json"
	local content = ""
	local lines = vim.fn.readfile(file_path)
	for _, line in ipairs(lines) do
		content = content .. line
	end
	---@type Go_Interface[]
	local interfaces = json:decode(content)
	local filtered_interfaces = {}
	for _, i in ipairs(interfaces) do
		-- TODO - right now, I filter out interfaces with no methods
		if #i.methods > 0 then
			table.insert(filtered_interfaces, i)
		end
	end
	return filtered_interfaces
end

-- TODO in general, handle errors better
-- TODO rework this function to make more clear
---@return string, string, integer
local function get_node_under_cursor()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	local parser = parsers.get_parser()
	if not parser then
		error("Parser not available for current buffer")
	end
	local root = parser:parse()[1]:root()
	local node = root:named_descendant_for_range(row, col, row, col)
	local parent = node.parent(node)
	local _, _, end_row, _ = parent:range()

	if node then
		local start_row, start_col, _, end_col = node:range()
		local node_text = vim.api.nvim_buf_get_text(0, start_row, start_col, start_row, end_col, {})[1]
		return node_text, node:type(), end_row + 2
	else
		error("No Treesitter node found under cursor")
	end
end

---@param interface Go_Interface
---@param node string
---@param with_brackets boolean
local get_formatted_methods = function(interface, node, with_brackets)
	local lines = {}
	for _, method in ipairs(interface.methods) do
		-- TODO insert after by using treesitter
		local lower_first_char = string.lower(string.sub(node, 1, 1))
		local formatted_method = string.format("func (%s %s) %s", lower_first_char, node, method.content)
		if with_brackets then
			formatted_method = formatted_method .. " {"
		end
		table.insert(lines, formatted_method)
		if with_brackets then
			-- TODO lists? definitely parameter types, errors
			local return_type = return_map[method.return_type] or ""
			table.insert(lines, "    return " .. return_type)
			table.insert(lines, "}")
		end
	end
	return lines
end

---@param interface Go_Interface
---@param node string
---@param node_type string
---@param row_idx integer
local add_methods = function(interface, node, node_type, row_idx)
	local lines = get_formatted_methods(interface, node, true)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row_to_insert = (cursor[1] - 1) - 1
	vim.api.nvim_buf_set_lines(0, row_idx, row_idx, false, lines)
end

-- TODO get opts from telescope
local go_interfaces = function(opts)
	local node, node_type, row_idx = get_node_under_cursor()
	-- TODO make treesitter checks that it's a type_identifier __for a struct__
	if node_type ~= "type_identifier" then
		print("got node_type == " .. node_type .. ", expected type_identifier")
		return
	end

	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Interfaces",
			finder = finders.new_table({
				results = get_interfaces(),
				---@param entry Go_Interface
				entry_maker = function(entry)
					return {
						-- TODO make this a fucntion for performance
						value = entry,
						display = entry.package .. "." .. entry.name,
						ordinal = entry.package .. "." .. entry.name,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selected_interface = action_state.get_selected_entry().value
					add_methods(selected_interface, node, node_type, row_idx)
				end)
				return true
			end,
			previewer = previewers.new_buffer_previewer({
				title = "Interface preview",
				define_preview = function(self, entry, status)
					local lines = get_formatted_methods(entry.value, node, false)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					-- TODO fix go syntax so we can highlight it
					require("telescope.previewers.utils").highlighter(self.state.bufnr, "go")
				end,
			}),
		})
		:find()
end

vim.keymap.set("n", "<leader>si", function()
	go_interfaces(themes.get_cursor())
end)
