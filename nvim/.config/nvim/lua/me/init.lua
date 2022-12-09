local M = {}

local function scandir(directory)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "' .. directory .. '"')
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end

M.center_and_change_colorscheme = function()
	vim.api.nvim_command("normal Gzz")
	vim.api.nvim_command("colorscheme tokyonight")
end

M.cycle_notes = function(direction)
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

	local cbuf = vim.api.nvim_get_current_buf()
	vim.api.nvim_command("edit " .. buf_dir .. "/" .. next_f)
	vim.api.nvim_buf_delete(cbuf, { force = false })
end



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

function get_current_commit_sha(directory)
	local i, t, popen = 0, {}, io.popen
	local result = popen('git -C "' .. directory .. '" ' .. "rev-parse HEAD")
	for line in result:lines() do
		return line
	end
end

function get_github_permalink()
	local sha = get_current_commit_sha(vim.fn.getcwd())
	local linenr = vim.api.nvim_win_get_cursor(0)[1]
	local file = vim.fn.expand("%:p")

	local _, j = string.find(file, "core")

	-- We want to get rid of: `.../core{0,1,2}/`. That's why j + 3.
	file = file:sub(j + 3, nil)
	local permalink = ("https://github.com/recap-technologies/core/blob/" .. sha .. "/" .. file .. "#L" .. linenr)
	vim.cmd("let @+ = '" .. permalink .. "'")
end

P = function(v)
	print(vim.inspect(v))
	return v
end


M.create_new_note = function()
	local note_name = vim.fn.input("New note > ")
	local full_path = "/home/denis/Sync/Notes/Current/" .. note_name .. ".md"
    vim.cmd("e " .. full_path)
end

return M
