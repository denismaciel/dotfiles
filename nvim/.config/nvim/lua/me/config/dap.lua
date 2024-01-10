require('mason-nvim-dap').setup()
local wk = require('which-key')
local dap = require('dap')
local dapui = require('dapui')
local dap_go = require('dap-go')
local dap_python = require('dap-python')

dap.set_log_level('TRACE')
dapui.setup()

dap_go.setup()
dap_python.setup('~/venvs/debugpy/bin/python')
dap_python.test_runner = 'pytest'

dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open({})
end
dap.listeners.before.event_terminated['dapui_config'] = function()
    dapui.close({})
end
dap.listeners.before.event_exited['dapui_config'] = function()
    dapui.close({})
end

require('telescope').load_extension('dap')
-- nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
-- nnoremap <silent> <Leader>lp <Cmd>lua
-- nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
-- nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
wk.register({
    d = {
        name = 'DAP',
        c = { dap.continue, 'Continue' },
        b = { dap.toggle_breakpoint, 'Breakpoint' },
        B = {
            function()
                dap.set_breakpoint(
                    nil,
                    nil,
                    vim.fn.input('Log point message: ')
                )
            end,
            'Breakpoint with Message',
        },
        t = {
            function()
                local ft = vim.bo.filetype
                if ft == 'python' then
                    dap_python.test_method()
                elseif ft == 'go' then
                    dap_go.debug_test()
                else
                    print('unkown file type', ft)
                end
            end,
            'Debug Test',
        },
        i = { dap.step_into, 'Step Into' },
        o = { dap.step_out, 'Step Out' },
        v = { dap.step_over, 'Step Over' },
    },
}, { prefix = '<leader>' })
