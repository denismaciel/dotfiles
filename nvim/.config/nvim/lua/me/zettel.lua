local M = {}

local zk = require 'zk'
local commands = require 'zk.commands'

local function make_edit_fn(defaults, picker_options)
    return function(options)
        options = vim.tbl_extend('force', defaults, options or {})
        zk.edit(options, picker_options)
    end
end

-- commands.add(
--     'ZkOrphans',
--     make_edit_fn({ orphan = true }, { title = 'Zk Orphans' })
-- )
commands.add(
    'ZkRecents',
    make_edit_fn(
        { createdAfter = '1 weeks ago', exclude = 'Anki' },
        { title = 'Zk Recents' }
    )
)

M.create_new_note = function()
    local note_name = vim.fn.input 'New note > '
    if note_name == '' then
        return
    end
    local full_path = '/home/denis/Sync/Notes/Current/' .. note_name .. '.md'
    vim.cmd('e ' .. full_path)
end

return M
