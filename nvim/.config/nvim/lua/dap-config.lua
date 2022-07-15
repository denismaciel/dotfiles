local dap = require("dap")
local dapui = require("dapui")
local dap_go = require("dap-go")
local dap_python = require("dap-python")

dap_go.setup()
dapui.setup()
dap_python.setup("~/venvs/debugpy/bin/python")
dap_python.test_runner = "pytest"

vim.keymap.set("n", "<F5>", dap.continue)
vim.keymap.set("n", "<F6>", dap_go.debug_test)
vim.keymap.set("n", "<F10>", dap.step_over)
vim.keymap.set("n", "<F11>", dap.step_into)
vim.keymap.set("n", "<F12>", dap.step_out)

vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint)
vim.keymap.set("n", "<Leader>B", function()
	dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end)

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
-- nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
-- nnoremap <silent> <Leader>lp <Cmd>lua
-- nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
-- nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
