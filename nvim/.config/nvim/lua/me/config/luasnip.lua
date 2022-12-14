-- setup is run in cmp.lua
local luasnip = require("luasnip")

vim.keymap.set({ "i", "s" }, "<C-S>", function()
	if luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	end
end, { silent = true })
