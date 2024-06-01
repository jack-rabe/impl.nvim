local M = {}

local bit = require("bit")

M.impl_data_path = vim.fn.stdpath("data") .. "/impl/"

M.hash = function(str)
	local h = 5381
	for c in str:gmatch(".") do
		h = bit.lshift(h, 5) + h + string.byte(c)
	end
	return h
end

return M
