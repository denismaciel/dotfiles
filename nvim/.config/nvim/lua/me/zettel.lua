local M = {}

M.create_new_note = function()
	local note_name = vim.fn.input("New note > ")
	if note_name == "" then
		return
	end
	local full_path = "/home/denis/Sync/Notes/Current/" .. note_name .. ".md"
	vim.cmd("e " .. full_path)
end

M.open_anki_note = function()
	vim.cmd([[ edit /home/denis/Sync/Notes/Current/anki.md ]])
end

return M
