local M = {}

local themes = require("telescope.themes")
local previewers = require("telescope.previewers")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local treesitter = require("impl.treesitter")
local interfaces = require("impl.interfaces")

M.implement_interface = function(opts)
	local node, node_type, row_idx = treesitter.get_node_under_cursor()
	if node_type ~= "type_identifier" then
		error("Treesitter node_type is " .. node_type .. ", must be type_identifier")
		return
	end

	opts = opts or themes.get_cursor()
	pickers
		.new(opts, {
			prompt_title = "Interfaces",
			finder = finders.new_table({
				results = interfaces.get_interfaces(),
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
					interfaces.add_methods(selected_interface, node, row_idx)
				end)
				return true
			end,
			previewer = previewers.new_buffer_previewer({
				title = "Interface preview",
				define_preview = function(self, entry, _status)
					local lines = interfaces.get_formatted_methods(entry.value, node, false)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					require("telescope.previewers.utils").highlighter(self.state.bufnr, "go")
				end,
			}),
		})
		:find()
end

return M
