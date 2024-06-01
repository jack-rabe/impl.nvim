local picker = require("picker")
local interfaces = require("interfaces")

-- TODO don't set any keybinds by default (only work in .go files?)
vim.keymap.set("n", "<leader>si", function()
	picker.implement_interface()
end)

local function impl_command(args)
	local subcommand = args.fargs[1]

	if subcommand == "project" then
		interfaces.generate_interfaces_for_project()
	elseif subcommand == "stdlib" then
		interfaces.generate_interfaces_for_stdlib()
	else
		error("Unknown ImplGenerate subcommand")
	end
end

vim.api.nvim_create_user_command("ImplGenerate", impl_command, {
	nargs = 1,
	complete = function(_, _, _)
		return { "stdlib", "project" }
	end,
})

vim.api.nvim_create_user_command("ImplSearch", function()
	picker.implement_interface()
end, {})
