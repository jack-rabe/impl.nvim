local picker = require("picker")

-- TODO don't set any keybinds by default (only work in .go files?)
vim.keymap.set("n", "<leader>si", function()
	picker.implement_interface()
end)

vim.api.nvim_create_user_command("ImplGenerate", function()
	local filepath = vim.fn.stdpath("data") .. "/interfaces.json"
	local response = vim.fn.system("impl -output " .. filepath)
	print(response)
end, {})

vim.api.nvim_create_user_command("ImplSearch", function()
	picker.implement_interface()
end, {})
