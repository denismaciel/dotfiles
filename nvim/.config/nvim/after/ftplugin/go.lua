local group = vim.api.nvim_create_augroup('CustomizeGo', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
        vim.b.EditorConfig_disable = 1
        vim.bo.shiftwidth = 6
        vim.bo.expandtab = false
        vim.bo.tabstop = 6
        vim.opt.list = true
        vim.opt.listchars =
            'tab:▸ ,trail:·,nbsp:␣,extends:❯,precedes:❮'
    end,
    group = group,
})

local function org_imports()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { 'source.organizeImports' } }
    local result =
        vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, nil)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, 'utf-16')
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

local format_go_group =
    vim.api.nvim_create_augroup('FormatGo', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.go' },
    callback = org_imports,
    group = format_go_group,
})
