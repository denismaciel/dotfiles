vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition)
vim.keymap.set("n", "gD", vim.lsp.buf.implementation)
vim.keymap.set("n", "gtd", vim.lsp.buf.type_definition)
vim.keymap.set("n", "grn", vim.lsp.buf.rename)

vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>xl", "<cmd>Trouble loclist<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>xq", "<cmd>Trouble quickfix<cr>", { silent = true, noremap = true })

function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "' .. directory .. '"')
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end

function cycle_notes(direction)
	local idx
	local buf_dir = vim.fn.expand("%:p:h")
	local f_name = vim.fn.expand("%:t")
	local files = scandir(buf_dir)
	for i, f in ipairs(files) do
		if f == f_name then
			idx = i
		end
	end

	if direction == "up" then
		next_f = files[idx + 1]
	elseif direction == "down" then
		next_f = files[idx - 1]
	else
		print("Unkown direction")
	end

	cbuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_command("edit " .. buf_dir .. "/" .. next_f)
	vim.api.nvim_buf_delete(cbuf, { force = false })
end
