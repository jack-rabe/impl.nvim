local M = {}

local parsers = require("nvim-treesitter.parsers")

---@return string, string, integer
M.get_node_under_cursor = function()
	local parser = parsers.get_parser()
	if not parser then
		error("Parser not available for current buffer")
	end
	local root = parser:parse()[1]:root()

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row, col = cursor[1] - 1, cursor[2]
	local node = root:named_descendant_for_range(row, col, row, col)

	if node then
		local _, parent = pcall(node.parent, node)
		if parent == nil then
			error("Operation not permitted on top-level Treesitter node")
		end
		local _, _, end_row, _ = parent:range()
		local start_row, start_col, _, end_col = node:range()
		local node_text = vim.api.nvim_buf_get_text(0, start_row, start_col, start_row, end_col, {})[1]
		return node_text, node:type(), end_row + 2
	else
		error("No Treesitter node found under cursor")
	end
end

return M
