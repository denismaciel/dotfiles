return {
    dir = '~/mine/obsidian.nvim',
    -- "epwalsh/obsidian.nvim",
    config = function()
        require('obsidian').setup {
            dir = '~/Sync/Notes/Current',
            completion = {
                nvim_cmp = true,
            },
            note_id_func = function(title)
                -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
                local suffix = ''
                if title ~= nil then
                    -- If title is given, transform it into valid file name.
                    suffix =
                        title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
                else
                    -- If title is nil, just add 4 random uppercase letters to the suffix.
                    for _ = 1, 4 do
                        suffix = suffix .. string.char(math.random(65, 90))
                    end
                end
                local prefix = os.date('%Y-%m-%dT%H:%M', os.time())
                return prefix .. '-' .. suffix
            end,
        }
    end,
}
