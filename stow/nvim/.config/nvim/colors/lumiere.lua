-- ============================================================================
-- LUMIERE COLORSCHEME - Simplified & Hackable
-- A clean, light colorscheme that's easy to customize
-- ============================================================================

-- Reset existing highlights
-- vim.cmd('highlight clear')
-- if vim.fn.exists('syntax_on') then
--     vim.cmd('syntax reset')
-- end
vim.g.colors_name = 'lumiere'

-- ============================================================================
-- COLOR PALETTE - Modify these to change the entire theme
-- ============================================================================
local colors = {
    -- Base colors
    bg = '#F1F1F1', -- Main background
    fg = '#424242', -- Main foreground text

    -- Grays (light to dark)
    gray1 = '#e4e4e4', -- Light gray
    gray2 = '#d3d3d3', -- Medium light gray
    gray3 = '#b8b8b8', -- Medium gray
    gray4 = '#9e9e9e', -- Medium dark gray
    gray5 = '#727272', -- Dark gray

    -- UI colors
    ui_bg = '#dfddd7', -- UI background (statusline, etc)
    ui_border = '#cac7bd', -- Borders and separators
    cursor_line = '#dfddd7', -- Current line highlight

    -- Semantic colors
    red = '#800013', -- Errors, deletions
    green = '#00802c', -- Success, additions
    blue = '#001280', -- Info, links
    yellow = '#ffda40', -- Warnings, search
    orange = '#cc4c00', -- Modified, special
    magenta = '#410080', -- Keywords, constants

    -- Highlight backgrounds (subtle)
    red_bg = '#faf1f1', -- Error background
    green_bg = '#f1faf4', -- Success background
    blue_bg = '#f1f4fa', -- Info background
    yellow_bg = '#fff7d8', -- Warning background

    -- Special
    none = 'NONE',
    black = '#000000',
    white = '#ffffff',
}

-- ============================================================================
-- CORE EDITOR HIGHLIGHTS
-- ============================================================================
local highlights = {
    -- Basic editor
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.gray1 },

    -- Cursor and lines
    Cursor = { fg = colors.bg, bg = colors.fg },
    CursorLine = { bg = colors.cursor_line },
    CursorColumn = { bg = colors.cursor_line },
    CursorLineNr = { fg = colors.gray5, bg = colors.none, bold = true },
    LineNr = { fg = colors.gray3, bg = colors.none },

    -- Selection and search
    Visual = { bg = colors.gray2 },
    VisualNOS = { bg = colors.gray2 },
    Search = { fg = colors.black, bg = colors.yellow },
    IncSearch = { fg = colors.black, bg = colors.yellow, bold = true },

    -- Matching
    MatchParen = { fg = colors.blue, bg = colors.blue_bg, bold = true },

    -- Folds and signs
    Folded = { fg = colors.gray4, bg = colors.gray1 },
    FoldColumn = { fg = colors.gray3, bg = colors.none },
    SignColumn = { fg = colors.gray3, bg = colors.none },

    -- Messages and prompts
    ErrorMsg = { fg = colors.red, bg = colors.red_bg },
    WarningMsg = { fg = colors.orange, bg = colors.yellow_bg },
    ModeMsg = { fg = colors.fg, bg = colors.none },
    MoreMsg = { fg = colors.green, bg = colors.none },
    Question = { fg = colors.blue, bg = colors.none },

    -- Completion menu
    Pmenu = { fg = colors.fg, bg = colors.gray1 },
    PmenuSel = { fg = colors.bg, bg = colors.blue },
    PmenuSbar = { bg = colors.gray2 },
    PmenuThumb = { bg = colors.gray4 },

    -- Splits and windows
    VertSplit = { fg = colors.ui_border, bg = colors.none },
    WinSeparator = { fg = colors.ui_border, bg = colors.none },

    -- Tabs
    TabLine = { fg = colors.gray4, bg = colors.gray1 },
    TabLineFill = { fg = colors.none, bg = colors.gray1 },
    TabLineSel = { fg = colors.fg, bg = colors.bg, bold = true },

    -- Status line
    StatusLine = { fg = colors.fg, bg = colors.ui_bg },
    StatusLineNC = { fg = colors.gray4, bg = colors.gray1 },

    -- Special characters
    NonText = { fg = colors.gray2, bg = colors.none },
    SpecialKey = { fg = colors.gray3, bg = colors.none },
    Whitespace = { fg = colors.gray2, bg = colors.none },
}

-- ============================================================================
-- SYNTAX HIGHLIGHTING - Language elements
-- ============================================================================
local syntax = {
    -- Comments
    Comment = { fg = colors.gray4, italic = true },

    -- Constants and literals
    Constant = { fg = colors.magenta },
    String = { fg = colors.green },
    Character = { fg = colors.green },
    Number = { fg = colors.magenta },
    Boolean = { fg = colors.magenta },
    Float = { fg = colors.magenta },

    -- Identifiers and functions
    Identifier = { fg = colors.fg },
    Function = { fg = colors.blue, bold = true },

    -- Statements and keywords
    Statement = { fg = colors.red, bold = true },
    Conditional = { fg = colors.red, bold = true },
    Repeat = { fg = colors.red, bold = true },
    Label = { fg = colors.red, bold = true },
    Operator = { fg = colors.fg },
    Keyword = { fg = colors.red, bold = true },
    Exception = { fg = colors.red, bold = true },

    -- Preprocessor
    PreProc = { fg = colors.orange },
    Include = { fg = colors.orange },
    Define = { fg = colors.orange },
    Macro = { fg = colors.orange },
    PreCondit = { fg = colors.orange },

    -- Types
    Type = { fg = colors.blue, bold = true },
    StorageClass = { fg = colors.blue, bold = true },
    Structure = { fg = colors.blue, bold = true },
    Typedef = { fg = colors.blue, bold = true },

    -- Special
    Special = { fg = colors.orange },
    SpecialChar = { fg = colors.orange },
    Tag = { fg = colors.blue },
    Delimiter = { fg = colors.fg },
    SpecialComment = { fg = colors.gray4, bold = true },
    Debug = { fg = colors.red },

    -- Underlined and errors
    Underlined = { fg = colors.blue, underline = true },
    Error = { fg = colors.red, bg = colors.red_bg, bold = true },
    Todo = { fg = colors.orange, bg = colors.yellow_bg, bold = true },
}

-- ============================================================================
-- TREESITTER HIGHLIGHTS - Modern syntax highlighting
-- ============================================================================
local treesitter = {
    -- Literals
    ['@string'] = { link = 'String' },
    ['@number'] = { link = 'Number' },
    ['@boolean'] = { link = 'Boolean' },
    ['@constant'] = { link = 'Constant' },
    ['@constant.builtin'] = { fg = colors.magenta, bold = true },

    -- Functions and methods
    ['@function'] = { link = 'Function' },
    ['@function.builtin'] = { fg = colors.blue, bold = true },
    ['@method'] = { link = 'Function' },
    ['@constructor'] = { fg = colors.blue, bold = true },

    -- Variables and parameters
    ['@variable'] = { fg = colors.fg },
    ['@variable.builtin'] = { fg = colors.magenta },
    ['@parameter'] = { fg = colors.fg },

    -- Keywords and operators
    ['@keyword'] = { link = 'Keyword' },
    ['@operator'] = { link = 'Operator' },
    ['@conditional'] = { link = 'Conditional' },
    ['@repeat'] = { link = 'Repeat' },

    -- Types and classes
    ['@type'] = { link = 'Type' },
    ['@type.builtin'] = { fg = colors.blue, bold = true },
    ['@class'] = { fg = colors.blue, bold = true },

    -- Punctuation
    ['@punctuation.delimiter'] = { fg = colors.fg },
    ['@punctuation.bracket'] = { fg = colors.fg },
    ['@punctuation.special'] = { fg = colors.orange },

    -- Comments and documentation
    ['@comment'] = { link = 'Comment' },
    ['@comment.documentation'] = {
        fg = colors.gray4,
        italic = true,
        bold = true,
    },

    -- Markdown headings - different color for each level
    ['@markup.heading.1.markdown'] = { fg = colors.red, bold = true },
    ['@markup.heading.2.markdown'] = { fg = colors.blue, bold = true },
    ['@markup.heading.3.markdown'] = { fg = colors.green, bold = true },
    ['@markup.heading.4.markdown'] = { fg = colors.orange, bold = true },
    ['@markup.heading.5.markdown'] = { fg = colors.magenta, bold = true },
    ['@markup.heading.6.markdown'] = { fg = colors.gray5, bold = true },
}

-- ============================================================================
-- LSP HIGHLIGHTS - Language server integration
-- ============================================================================
local lsp = {
    -- Diagnostics
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.orange },
    DiagnosticInfo = { fg = colors.blue },
    DiagnosticHint = { fg = colors.gray4 },

    -- Diagnostic backgrounds
    DiagnosticVirtualTextError = { fg = colors.red, bg = colors.red_bg },
    DiagnosticVirtualTextWarn = { fg = colors.orange, bg = colors.yellow_bg },
    DiagnosticVirtualTextInfo = { fg = colors.blue, bg = colors.blue_bg },
    DiagnosticVirtualTextHint = { fg = colors.gray4, bg = colors.gray1 },

    -- Underlines
    DiagnosticUnderlineError = { undercurl = true, sp = colors.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = colors.orange },
    DiagnosticUnderlineInfo = { undercurl = true, sp = colors.blue },
    DiagnosticUnderlineHint = { undercurl = true, sp = colors.gray4 },

    -- References and definitions
    LspReferenceText = { bg = colors.gray2 },
    LspReferenceRead = { bg = colors.gray2 },
    LspReferenceWrite = { bg = colors.gray2, bold = true },
}

-- ============================================================================
-- COMMON PLUGINS - Popular plugin integrations
-- ============================================================================
local plugins = {
    -- Git (gitsigns.nvim, fugitive, etc.)
    DiffAdd = { fg = colors.green, bg = colors.green_bg },
    DiffChange = { fg = colors.orange, bg = colors.yellow_bg },
    DiffDelete = { fg = colors.red, bg = colors.red_bg },
    DiffText = { fg = colors.orange, bg = colors.yellow_bg, bold = true },

    GitSignsAdd = { fg = colors.green },
    GitSignsChange = { fg = colors.orange },
    GitSignsDelete = { fg = colors.red },

    -- Telescope
    TelescopeNormal = { fg = colors.fg, bg = colors.gray1 },
    TelescopeBorder = { fg = colors.ui_border, bg = colors.gray1 },
    TelescopeSelection = { fg = colors.fg, bg = colors.gray2, bold = true },
    TelescopeMatching = { fg = colors.blue, bold = true },

    -- NvimTree / File explorers
    NvimTreeNormal = { fg = colors.fg, bg = colors.gray1 },
    NvimTreeFolderName = { fg = colors.blue },
    NvimTreeOpenedFolderName = { fg = colors.blue, bold = true },
    NvimTreeSpecialFile = { fg = colors.orange },
    NvimTreeExecFile = { fg = colors.green },

    -- Which-key
    WhichKey = { fg = colors.blue, bold = true },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeyGroup = { fg = colors.orange },
    WhichKeySeparator = { fg = colors.gray4 },
}

-- ============================================================================
-- APPLY ALL HIGHLIGHTS
-- ============================================================================
local function apply_highlights(groups)
    for group, opts in pairs(groups) do
        vim.api.nvim_set_hl(0, group, opts)
    end
end

-- Apply all highlight groups
apply_highlights(highlights)
apply_highlights(syntax)
apply_highlights(treesitter)
apply_highlights(lsp)
apply_highlights(plugins)

-- ============================================================================
-- CUSTOMIZATION TIPS
-- ============================================================================
--[[
To customize this colorscheme:

1. CHANGE COLORS: Modify the `colors` table at the top
   - colors.bg = "#your_background_color"
   - colors.fg = "#your_text_color"
   - etc.

2. MODIFY HIGHLIGHTS: Edit any highlight group
   - highlights.Normal = { fg = colors.fg, bg = colors.bg }
   - syntax.Comment = { fg = colors.gray4, italic = false }

3. ADD NEW HIGHLIGHTS: Just add to any section
   - plugins.YourPlugin = { fg = colors.blue }

4. RELOAD: After changes, run `:colorscheme lumiere` to see updates

5. COMMON MODIFICATIONS:
   - Make background darker: colors.bg = "#E8E8E8"
   - Change comment style: syntax.Comment = { fg = colors.gray4, italic = false }
   - Adjust cursor line: highlights.CursorLine = { bg = colors.gray2 }
--]]
