local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local M = {}

local HOME = os.getenv('HOME') .. '/'
local NOTES_FOLDER = HOME .. 'Sync/notes/'

M.is_url = function(text)
    if text == nil then
        return false
    end
    local url_pattern = '^https?://[%w-_%.%?%.:/%+=&;,@]+$'
    return string.match(text, url_pattern) ~= nil
end

M.create_weekly_note = function()
    -- Get current date information
    local current_time = os.time()
    local date_table = os.date('*t', current_time)

    -- Calculate the Monday of current week
    -- TODO: this is not Monday, but rather Sunday
    local days_since_monday = (date_table.wday + 6) % 7 -- Convert to Monday=0, Sunday=6
    local monday_timestamp = current_time - (days_since_monday * 24 * 60 * 60)
    local monday_date = os.date('%Y-%m-%d', monday_timestamp)

    local target_folder = NOTES_FOLDER .. 'current/private'

    local file_path_week = target_folder .. '/weekly/' .. monday_date .. '.md'

    -- Change to notes folder
    vim.fn.chdir(NOTES_FOLDER)

    -- Check if file exists, if not create it with header
    local file = io.open(file_path_week, 'r')
    if not file then
        file = io.open(file_path_week, 'w')
        if file then
            file:write('# ' .. monday_date)
            file:close()
        end
    else
        file:close()
    end

    -- Create daily note path and file
    local today_date = os.date('%Y-%m-%d', current_time)
    local file_path_day = target_folder .. '/daily/' .. today_date .. '.md'

    -- Check if daily file exists, if not create it with header
    local file_day = io.open(file_path_day, 'r')
    if not file_day then
        file_day = io.open(file_path_day, 'w')
        if file_day then
            file_day:write(
                '# ' .. today_date .. ' (' .. os.date('%A', current_time) .. ')'
            )
            file_day:close()
        end
    else
        file_day:close()
    end

    vim.cmd('edit ' .. vim.fn.fnameescape(file_path_day))
end

M.open_todo_note = function()
    vim.fn.chdir(NOTES_FOLDER)
    vim.cmd('edit todo.md')
end

local function scandir(directory)
    local i, t = 0, {}
    -- Use ls -p to append / to directories, then grep to exclude them
    local pfile = io.popen('ls -ap "' .. directory .. '" | grep -v "/$"')

    if pfile == nil then
        return
    end

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end

    pfile:close()
    return t
end

M.highlight_markdown_titles = function()
    local palette = require('no-clown-fiesta.palette')
    vim.api.nvim_set_hl(0, '@markup.heading.1', { fg = palette.blue })
    vim.api.nvim_set_hl(0, '@markup.heading.2', { fg = palette.green })
    vim.api.nvim_set_hl(0, '@markup.heading.3', { fg = palette.red })
    vim.api.nvim_set_hl(0, '@markup.heading.4', { fg = palette.orange })
    vim.api.nvim_set_hl(0, '@markup.heading.5', { fg = palette.yellow })
end

---@alias RoutineItem { text: string, condition: function }
---@return string[]
local routine = function()
    local always = function()
        return true
    end

    local is_weekday = function()
        -- return false
        local day = os.date('*t').wday
        return day >= 2 and day <= 6
    end

    -- Define items with their conditions
    ---@type RoutineItem[]
    local items = {
        { text = '- [ ] #routine Anki', condition = always },
        -- { text = '- [ ] #routine Gather', condition = always },
        { text = '- [ ] #routine Creatina', condition = always },
        { text = '- [ ] #routine #home Inbox Zero', condition = always },
        { text = '- [ ] #routine Clean up for 5 min', condition = always },
        { text = '- [ ] #routine Chores for 10 min', condition = always },
        { text = '- [ ] #routine Curate todo list', condition = always },
        { text = '- [ ] #routine Check Kinderpedia', condition = is_weekday },
        { text = '- [ ] #routine 15 push-ups', condition = always },
        { text = '- [ ] #routine 10 pull-ups', condition = always },
        { text = '- [ ] #routine #recap Notion BOD', condition = is_weekday },
        { text = '- [ ] #routine #recap Inbox Zero', condition = is_weekday },
        { text = '- [ ] #routine Plan the day', condition = always },
        { text = '- [ ] #routine Magnésio', condition = always },
    }

    -- Filter items based on their conditions and extract text
    local result = {}
    for _, item in ipairs(items) do
        if item.condition() then
            table.insert(result, item.text)
        end
    end

    return result
end

M.insert_text = function(opts)
    local cb = vim.api.nvim_get_current_buf()
    local cline = vim.api.nvim_win_get_cursor(0)[1]
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Insert Block',
            finder = finders.new_table({
                results = {
                    {
                        title = 'Routine',
                        content = routine(),
                    },
                    {
                        title = 'Text editor: 0. Language-only',
                        content = [[
You are a veteran, no‑nonsense copy editor. This pass is **language-only**: fix objective mechanical errors and nothing else.

SCOPE (allowed):
- Spelling and typos.
- Grammar and syntax (agreement, tense, pronouns).
- Punctuation and capitalization.
- Article/determiner use, prepositions, basic word forms.
- Keep existing dialect (US/UK). If mixed, choose the majority and note it.

HARD GUARDRAILS (forbidden):
- No stylistic rewrites or “stronger verbs.”
- No clarity edits beyond what’s required to fix grammar.
- No adding/removing ideas, examples, or facts.
- No splitting/merging sentences; preserve one-sentence-per-line.
- No reordering, no title tweaks.
- Do not edit code/inline code/fenced blocks, URLs, file paths, emails, hashtags, or numbers/units.

OUTPUT RULES:
- XML only. For each changed line, output exactly:

<correction>
    <type>language</type>
    <description>Brief reason (e.g., "Comma splice").</description>
    <oldLine>Original line here.</oldLine>
    <newLine>Corrected line here.</newLine>
</correction>

- Keep <oldLine>/<newLine> to exactly one sentence each.
- If a line is unfixable without rewriting, do not rewrite—just list its line number in the summary.
- After the last <correction>, output:

<feedback>
    <summary>
        • Dialect used: US or UK (state which and why if mixed).
        • Error patterns (3–6 bullets).
        • Lines requiring a later clarity/style pass (list line numbers only).
        • Counts: total lines changed = N.
    </summary>
</feedback>

WHEN THERE ARE NO ERRORS:
<feedback>
    <summary>No language errors found. Dialect appears consistent: [US|UK].</summary>
</feedback>

INPUT:
Provide the draft inside:
<draft>
...one sentence per Markdown line...
</draft>
                        ]],
                    },
                    {
                        title = 'Text editor: 1. Clarity & Concision',
                        content = [[
You are a precision editor. This pass is **clarity & concision only**: make each sentence convey the same idea with fewer, clearer words.

SCOPE (allowed):
- Remove filler and redundancies.
- Resolve vague references; tighten weak clauses.
- Break needlessly complex phrasing into simpler equivalents **within the same sentence**.
- Prefer concrete, plain language over abstractions—without changing meaning.

HARD GUARDRAILS (forbidden):
- No voice/tone changes (no punch-up).
- No new information, examples, or claims.
- No changing the intended stance.
- No splitting/merging sentences; preserve one-sentence-per-line.
- No section reordering or structural edits.
- Do not edit code/inline code/fenced blocks, URLs, file paths, emails, hashtags, or numbers/units (except obvious clarity in surrounding text).

OUTPUT RULES:
- XML only. For each changed line:

<correction>
    <type>clarity</type>
    <description>Brief reason (e.g., "Remove filler," "Tighten clause").</description>
    <oldLine>Original line here.</oldLine>
    <newLine>Rewritten for clarity (same meaning, fewer words).</newLine>
</correction>

- One <correction> per changed line; one sentence in <oldLine>/<newLine>.
- After the last <correction>, output:

<feedback>
    <summary>
        • Top clarity issues (3–6 bullets).
        • Average words per sentence (before→after, estimated).
        • Lines that still feel ambiguous and need author input (list line numbers).
        • Counts: total lines changed = N.
    </summary>
</feedback>

INPUT:
<draft>
...one sentence per Markdown line...
</draft>
                        ]],
                    },
                    {

                        title = 'Text editor: 2. Voice & Punch',
                        content = [[
You are a precision editor. This pass is **clarity & concision only**: make each sentence convey the same idea with fewer, clearer words.

SCOPE (allowed):
- Remove filler and redundancies.
- Resolve vague references; tighten weak clauses.
- Break needlessly complex phrasing into simpler equivalents **within the same sentence**.
- Prefer concrete, plain language over abstractions—without changing meaning.

HARD GUARDRAILS (forbidden):
- No voice/tone changes (no punch-up).
- No new information, examples, or claims.
- No changing the intended stance.
- No splitting/merging sentences; preserve one-sentence-per-line.
- No section reordering or structural edits.
- Do not edit code/inline code/fenced blocks, URLs, file paths, emails, hashtags, or numbers/units (except obvious clarity in surrounding text).

OUTPUT RULES:
- XML only. For each changed line:

<correction>
    <type>clarity</type>
    <description>Brief reason (e.g., "Remove filler," "Tighten clause").</description>
    <oldLine>Original line here.</oldLine>
    <newLine>Rewritten for clarity (same meaning, fewer words).</newLine>
</correction>

- One <correction> per changed line; one sentence in <oldLine>/<newLine>.
- After the last <correction>, output:

<feedback>
    <summary>
        • Top clarity issues (3–6 bullets).
        • Average words per sentence (before→after, estimated).
        • Lines that still feel ambiguous and need author input (list line numbers).
        • Counts: total lines changed = N.
    </summary>
</feedback>

INPUT:
<draft>
...one sentence per Markdown line...
</draft>
                        ]],
                    },
                    {
                        title = 'Text editor: 3. Rhythm & Flow',
                        content = [[
You are an editor focused on **rhythm & flow**: fix clunky cadence and weak transitions so the piece reads smoothly out loud.

SCOPE (allowed):
- Vary sentence openings and lengths.
- Replace awkward phrasing that trips read‑aloud cadence.
- Add or replace lightweight transition cues within the affected sentence (e.g., "However," "So," "Then").
- Reorder clauses inside the sentence for smoother cadence.

HARD GUARDRAILS (forbidden):
- No voice “punch-up” (that’s a later pass).
- No new facts or examples.
- No paragraph/section reordering.

OUTPUT RULES:
- XML only. For each changed part:

<correction>
    <type>rhythm</type>
    <description>Brief reason (e.g., "Monotonous cadence," "Jarring transition").</description>
    <oldPart>Original part here.</oldPart>
    <newPart>Smoother, natural cadence here.</newPart>
</correction>

- After the last <correction>, output:

INPUT:
<draft> </draft>]],
                    },
                    {
                        title = 'Text editor: 5. Structure & Completeness',
                        content = [[
You are a structural editor. This pass is **structure & completeness**: ensure the piece has a compelling arc and covers essential angles.

SCOPE (allowed):
- Diagnose intro promise, section order, progression, and conclusion strength.
- Identify gaps: missing examples, counter-arguments, data points, definitions.
- Propose a tighter outline and supply targeted rewrites by paragraph/section.

HARD GUARDRAILS (forbidden):
- Do not invent facts or data; suggest placeholders if needed.
- Minimal line-level edits; focus on holistic moves.
- Preserve the author’s stance and core message.
- Do not modify code blocks, URLs, or quantitative details.

OUTPUT RULES:
- XML only. Prefer holistic feedback with targeted rewrites.
- Use <correction> blocks ONLY for trivial fixes you can’t avoid (rare). Otherwise, provide structured feedback:

<feedback>
    <summary>
        • Big-picture issues (3–6 bullets).
        • Current outline (as inferred) → Proposed outline (concise).
        • Gaps to fill (bulleted list with the purpose of each gap).
    </summary>
    <rewriteSuggestions>
        <rewrite target="paragraph X">Proposed replacement paragraph text…</rewrite>
        <rewrite target="section: [Name]">Proposed replacement or expansion…</rewrite>
        <rewrite target="bridge: after line Y">One-sentence transition proposal…</rewrite>
    </rewriteSuggestions>
    <verdict>
        Brief, blunt call: e.g., “Solid structure, add examples and publish,” or “Reorder sections 2↔4 and rewrite conclusion.”
    </verdict>
</feedback>

INPUT:
<draft>

</draft>
                        ]],
                    },
                    {
                        title = 'Text editor',
                        content = [[
You are a veteran, no‑nonsense blog editor whose only goal is to make every post more readable, engaging, and share‑worthy.
Forget legal fine print and nit‑picky technical specs.
Your job is to fix the prose and, when necessary, call out junk that belongs in the trash.

1. What to Improve

Rhythm & Flow Flag clunky cadence, monotonous sentence lengths, weak transitions, or anything that “sounds off” aloud.
Clarity & Concision Cut fluff, kill filler phrases, choose vivid verbs.
Voice & Punch Amp up personality without losing professionalism; maintain a consistent tone.
Structure & Momentum Ensure paragraphs land with impact and each section pulls the reader forward.
Completeness Point out glaring angles, counter‑arguments, or examples that are missing.
Reality Check If a line or whole draft is hopeless, say so plainly: “Toss this and start over.”

2. Your Output (strictly follow this structure)

A. Line‑by‑Line Corrections

For every individual line that needs tweaking, produce an XML block exactly like this:

<correction>
    <type>language|clarity|style|rhythm</type>
    <description>Brief description of the issue (e.g., "The sentence is too long and convoluted.")</description>
    <oldLine>Original line here.</oldLine>
    <newLine>Revised line here.</newLine>
</correction>

One <correction> per line change.
Keep <oldLine> / <newLine> to a single sentence (my drafts are one sentence per Markdown line).
Valid <type> values: language, clarity, style, rhythm.

B. Holistic Feedback & Rewrites

After the last <correction> block, output a single <feedback> element covering big‑picture issues:

<feedback>
    <summary>
        • Bullet list of the 3‑6 most critical problems (e.g., sagging intro, missing data, uneven tone).
    </summary>
    <rewriteSuggestions>
        <rewrite target="paragraph 3">
            Proposed replacement paragraph text…
        </rewrite>
        <rewrite target="section: Conclusion">
            Suggested new angle or expansion…
        </rewrite>
    </rewriteSuggestions>
    <verdict>
        “Looks solid, polish and publish” •OR• “Needs a full rewrite—scrap it” •OR• any blunt truth.
    </verdict>
</feedback>

3. Output Rules

XML first, nothing else. No Markdown, no commentary outside tags.
Give thorough, candid feedback.
Focus on making the blog post successful with real readers (clarity, rhythm, engagement).
Finally, here's the draft you need to edit:

<draft>

</draft>

                        ]],
                    },
                    {
                        title = 'Confirm assumptions',
                        content = 'Please ask questions and confirm assumptions before generating code.',
                    },
                    {
                        title = 'uv script',
                        content = [[
You write Python tools as single files. They always start with this comment:

# /// script
# requires-python = ">=3.12"
# ///
These files can include dependencies on libraries such as Click.
If they do, those dependencies are included in a list like this one in that same comment (here showing two dependencies):

# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "click",
#     "sqlite-utils",
# ]
# ///
                    ]],
                    },
                    {
                        title = 'LLM prompt engineer',
                        content = [[
I am using you as a prompt generator.
I've dumped the entire context of my code base, and I have a specific problem.
Please come up with a proposal to my problem - including the code and general approach.

<Problem>

Please make sure that you leave no details out, and follow my requirements specifically.
I know what I am doing, and you can assume that there is a reason for my arbitrary requirements.

When generating the full prompt with all of the details, keep in mind that the model you are sending this to is not as intelligent as you.
It is great at very specific instructions, so please stress that they are specific.

Come up with discrete steps such that the sub-llm i am passing this to can build intermediately; as to keep it on the rails.
Make sure to stress that it stops for feedback at each discrete step.
                    ]],
                    },
                    {
                        title = 'LLM: code only, command only',
                        content = {
                            'Output only the command/code, do not write any explanation.',
                        },
                    },
                },
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.title,
                        ordinal = entry.title,
                    }
                end,
            }),
            -- previewer = conf.file_previewer(opts), -- TODO: implement a previewr
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.api.nvim_buf_set_lines(
                        cb,
                        cline,
                        cline,
                        false,
                        type(selection.value.content) == 'string'
                                and vim.split(selection.value.content, '\n')
                            or selection.value.content
                    )
                end)
                return true
            end,
        })
        :find()
end

M.center_and_change_colorscheme = function()
    vim.cmd([[ normal Gzz ]])
end

M.cycle_notes = function(direction)
    local buf_dir = vim.fn.expand('%:p:h')
    local f_name = vim.fn.expand('%:t')
    local files = scandir(buf_dir)

    files = vim.tbl_filter(function(path)
        if path == '.' or path == '..' then
            return false
        end
        return true
    end, files)

    local idx
    for i, f in ipairs(files) do
        if f == f_name then
            idx = i
        end
    end

    local next_f
    if direction == 'up' then
        next_f = files[idx + 1]
    elseif direction == 'down' then
        next_f = files[idx - 1]
    else
        print('Unknown direction')
    end

    if next_f == nil then
        print('You reached the last note.')
        return
    end

    local cbuf = vim.api.nvim_get_current_buf()
    vim.api.nvim_command('edit ' .. buf_dir .. '/' .. next_f)

    -- Don't delete buffer if it has unsaved changes.
    if vim.api.nvim_buf_get_option(cbuf, 'modified') then
        return
    end

    vim.api.nvim_buf_delete(cbuf, { force = false })
end

local function parse_anki_note_id(str)
    local pattern = '%d%d%d%d%d%d%d%d%d%d%d%d%d'
    local number = string.match(str, pattern)

    if number then
        return tonumber(number)
    else
        return nil
    end
end

M.anki_edit_note = function()
    -- Open a tmux popup running apy in order to review a note.
    local filename = vim.fn.expand('%:t')
    local note_id = parse_anki_note_id(filename)
    if note_id then
        local apy_cmd = '"apy review nid:' .. note_id .. '"'
        local bash_cmd = 'tmux display-popup -h 90% -w 90% -E ' .. apy_cmd
        os.execute(bash_cmd)
    else
        print(filename)
        print('No 13-digit number found.')
    end
end

local function load_json_file(path)
    local file = io.open(path, 'r')
    if not file then
        print('Error opening file at', path)
        return nil
    end
    local content = file:read('*all')
    local json = vim.json.decode(content)
    file:close()
    return json
end

M.find_anki_notes = function(opts)
    opts = opts or {}
    pickers
        .new(opts, {
            prompt_title = 'Anki Notes',
            finder = finders.new_table({
                results = (function()
                    local notes_index = load_json_file(
                        '/home/denis/Sync/notes/current/anki/index.json'
                    )
                    local notes = {}
                    for _, note in ipairs(notes_index.notes) do
                        if not note.is_code_only then
                            table.insert(notes, note)
                        end
                    end
                    return notes
                end)(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.title,
                        ordinal = entry.title,
                        filename = entry.file_path,
                    }
                end,
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    vim.cmd('e ' .. selection.value.file_path)
                end)
                return true
            end,
        })
        :find()
end

M.slugify = function(text)
    if not text then
        return ''
    end

    local function trim(s)
        return s:match('^%s*(.-)%s*$')
    end

    local slug = text
    -- Remove Markdown headers
    slug = slug:gsub('#', '')
    slug = trim(slug)
    slug = slug:gsub('[^%w%s%-]', '') -- Remove special characters except spaces and hyphens
    slug = slug:gsub('%s+', '-') -- Replace one or more spaces with a single hyphen
    slug = slug:gsub('%-+', '-') -- Replace multiple hyphens with a single hyphen
    return slug:lower()
end

-- local slugify = M.slugify
-- -- Test case 1: Basic text
-- assert(slugify("Hello World") == "hello-world", "Test case 1 failed")
-- -- Test case 2: Text with numbers
-- assert(slugify("Lua 2024 version") == "lua-2024-version", "Test case 2 failed")
-- -- Test case 3: Text with special characters
-- assert(slugify("Special@#Characters!") == "specialcharacters", "Test case 3 failed")
-- -- Test case 4: Text with leading and trailing spaces
-- assert(slugify("  Space around  ") == "space-around", "Test case 4 failed")
-- -- Test case 5: Text with multiple consecutive spaces
-- assert(slugify("Multiple   spaces") == "multiple-spaces", "Test case 5 failed")
-- -- Test case 6: Empty string
-- assert(slugify("") == "", "Test case 6 failed")
-- -- Test case 7: Text with only special characters
-- assert(slugify("@#$%^&*()") == "", "Test case 7 failed")
-- -- Test case 8: Text with mixed case
-- assert(slugify("Mixed CASE text") == "mixed-case-text", "Test case 8 failed")
-- -- Test case 9: Numeric only string
-- assert(slugify("12345") == "12345", "Test case 9 failed")
-- -- Test case 10: String with hyphens
-- assert(slugify("Already-Has-Hyphens") == "already-has-hyphens", "Test case 10 failed")
-- print("All test cases passed!")

M.python_test_file = function()
    -- Get relative path of the current file
    local current_file_path = vim.fn.expand('%:p')
    -- Find the Python project folder by:
    --  - splitting the file path on `/`
    --  - finding the position of `src`
    --  - the project folder is the right above `src`.
    -- Then remove from the path everything that's before the file path
    local parts = vim.fn.split(current_file_path, '/')
    local src_index = vim.fn.index(parts, 'src')
    if src_index == -1 then
        print('Error: \'src\' directory not found in the file path.')
        return
    end
    local project_path = '/' .. table.concat(parts, '/', 1, src_index)

    local fpath = string.gsub(current_file_path, project_path, '')
    parts = vim.fn.split(fpath, '/')
    table.remove(parts, 1) -- remove src
    table.remove(parts, 1) -- remove pkg_name

    parts[#parts] = string.gsub(parts[#parts], '.py', '_test.py')

    -- create directory structure if it doesn't exist
    local test_file_path = project_path .. '/src/tests'
    for i = 1, #parts - 1 do
        test_file_path = test_file_path .. '/' .. parts[i]
        vim.fn.mkdir(test_file_path, 'p')
    end
    test_file_path = test_file_path .. '/' .. parts[#parts]
    vim.cmd('edit ' .. test_file_path)
end

M.copy_file_path_to_clipboard = function()
    local determine_file_path = function()
        local cfile = vim.api.nvim_buf_get_name(0)
        local relative_path = vim.fn.fnamemodify(cfile, ':.')

        if vim.bo.filetype ~= 'python' then
            return relative_path
        end

        local path_parts = vim.split(relative_path, '/')
        local src_index = vim.fn.index(path_parts, 'src')

        -- If `src` is not found, we return the relative path as is.
        if src_index == -1 then
            return relative_path
        end
        -- If `src` is the first part, we are already at the root of the project.
        if src_index == 0 then
            return relative_path
        end

        -- If `src` is found, we remove everything before it.
        return table.concat(path_parts, '/', src_index + 1)
    end

    local result = determine_file_path()
    vim.fn.setreg('+', result)
    print('Copying to clipboard: ' .. result)
    return result
end

M.copy_full_file_path_to_clipboard = function()
    local cfile = vim.api.nvim_buf_get_name(0)
    local full_path = vim.fn.fnamemodify(cfile, ':p')
    vim.fn.setreg('+', full_path)
    print('Copying to clipboard: ' .. full_path)
    return full_path
end

M.copy_file_path_with_line_to_clipboard = function()
    local determine_file_path = function()
        local cfile = vim.api.nvim_buf_get_name(0)
        local relative_path = vim.fn.fnamemodify(cfile, ':.')

        if vim.bo.filetype ~= 'python' then
            return relative_path
        end

        local path_parts = vim.split(relative_path, '/')
        local src_index = vim.fn.index(path_parts, 'src')

        -- If `src` is not found, we return the relative path as is.
        if src_index == -1 then
            return relative_path
        end
        -- If `src` is the first part, we are already at the root of the project.
        if src_index == 0 then
            return relative_path
        end

        -- If `src` is found, we remove everything before it.
        return table.concat(path_parts, '/', src_index + 1)
    end

    local file_path = determine_file_path()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local result = file_path .. ':' .. line_num
    vim.fn.setreg('+', result)
    print('Copying to clipboard: ' .. result)
    return result
end

local function sort_markdown_list()
    local query = vim.treesitter.query.parse(
        'markdown',
        [[
    (list) @list
  ]]
    )

    local bufnr = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(bufnr, 'markdown')
    local tree = parser:parse()[1]
    local root = tree:root()

    local function get_list_item_text(node)
        local start_row, start_col, end_row, end_col = node:range()
        local lines =
            vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
        local text = table.concat(lines, '\n')
        return text:match('%-%s*(.+)')
    end

    local function sort_list(list_node)
        local items = {}
        print(vim.inspect(list_node))
        for child in list_node:iter_children() do
            if child:type() == 'list_item' then
                local item_text = get_list_item_text(child)
                local nested_list = child:child(1)
                        and child:child(1):type() == 'list'
                        and child:child(1)
                    or nil
                table.insert(items, {
                    node = child,
                    text = item_text,
                    nested_list = nested_list,
                })
            end
        end

        table.sort(items, function(a, b)
            return a.text:lower() < b.text:lower()
        end)

        local start_row, start_col, end_row, end_col = list_node:range()
        local sorted_text = {}
        for _, item in ipairs(items) do
            local item_start, _, item_end, _ = item.node:range()
            local item_lines = vim.api.nvim_buf_get_lines(
                bufnr,
                item_start,
                item_end + 1,
                false
            )
            for _, line in ipairs(item_lines) do
                table.insert(sorted_text, line)
            end
            if item.nested_list then
                sort_list(item.nested_list)
            end
        end

        vim.api.nvim_buf_set_lines(
            bufnr,
            start_row,
            end_row + 1,
            false,
            sorted_text
        )
    end

    for _, match in query:iter_matches(root, bufnr) do
        print(vim.inspect(match))
        for id, node in pairs(match) do
            if query.captures[id] == 'list' then
                sort_list(node)
            end
        end
    end
end

-- Create a command to call the function
vim.api.nvim_create_user_command('SortMarkdownList', sort_markdown_list, {})

M.telescope_insert_relative_file_path = function(selected)
    print('Inserting relative file path...')
    print(vim.inspect(selected))
    local selection = selected[1]
    print(vim.inspect(selection))
    if selection then
        local full_path = selection.value
        if selection.path then
            full_path = selection.path
        end
        -- Convert to relative path
        local relative_path = vim.fn.fnamemodify(full_path, ':.')

        -- Now get current buffer and cursor position after closing telescope
        local current_buf = vim.api.nvim_get_current_win()
        local cursor_pos = vim.api.nvim_win_get_cursor(current_buf)
        local row, col = cursor_pos[1], cursor_pos[2]

        -- Insert the path with @ prefix at cursor position
        local text_to_insert = '@' .. relative_path
        vim.api.nvim_buf_set_text(
            0,
            row - 1,
            col,
            row - 1,
            col,
            { text_to_insert }
        )

        -- Notify user
        print('Inserted: ' .. text_to_insert)
    end
end

M.fzf_lua_insert_relative_file_path = function(selected)
    local selection = selected[1]

    if selection == nil then
        print('No selection made.')
        return
    end

    -- We need to remove the filetype utf-8 symbols from the selection
    -- 1. Split the selection by `/`. The symbols are always at the beginning.
    -- 2. Remove non-alphanumeric characters from the first part.
    -- 3. Join the parts back together.
    local parts = vim.split(selection, '/')
    local first_part = parts[1]
    local ascii_only = first_part:gsub('[^%w%s%.%-]', '')
    parts[1] = ascii_only
    local relative_path = table.concat(parts, '/')

    -- Ready to write it back to the current buffer.
    local current_buf = vim.api.nvim_get_current_win()
    local cursor_pos = vim.api.nvim_win_get_cursor(current_buf)
    local row, col = cursor_pos[1], cursor_pos[2]

    local text_to_insert = '@' .. relative_path
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { text_to_insert })
    -- Notify user
    print('Inserted: ' .. text_to_insert)
end

local get_track_md_path = function()
    local is_git_repo =
        vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1]

    if is_git_repo ~= 'true' then
        print('Not inside a Git repository.')
        return nil
    end

    local root_dir = vim.fn.systemlist('git rev-parse --show-toplevel')[1]

    if not root_dir or root_dir == '' then
        print('Could not determine Git repository root.')
        return nil
    end

    -- For some repos, I don't or can't commit the track.md file.
    -- In those cases, I name the file track-{git-repo-name}.md
    -- and add it in the global gitignore.
    local repo_name = vim.fn.fnamemodify(root_dir, ':t')
    local track_file = root_dir .. '/track-' .. repo_name .. '.md'
    if vim.fn.filereadable(track_file) == 1 then
        return track_file
    end

    -- Path to the track.md inside the repo root
    return root_dir .. '/track.md'
end

M.open_track_md = function()
    local track_md_path = get_track_md_path()
    if not track_md_path then
        return
    end

    -- Check if the track file is already open in any window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name == track_md_path then
            -- File is already open, close the window
            vim.api.nvim_win_close(win, false)
            return
        end
    end

    -- File is not open, open it
    vim.api.nvim_command('leftabove vsplit ' .. track_md_path)
    vim.api.nvim_command('vertical resize 80')
end

M.run = function()
    print('here')

    M.open_track_md()

    print('there')
end

return M
