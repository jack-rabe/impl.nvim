local M = {}

M.setup = function(config)
	M.config = config
end

M.get_config = function()
	return M.config
end

return M
