local function create_buffer()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buf, "*compilation*")
	return buf
end

local vertical_split = true
local buf = create_buffer()
local last_args = {}
-- keep a cache of last passed arguments to main.

local function is_buffer_open(buffer_id)
	local windows = vim.api.nvim_tabpage_list_wins(0)

	for _, win_id in ipairs(windows) do
		if vim.api.nvim_win_get_buf(win_id) == buffer_id then
			return win_id
		end
	end

	return nil
end

local function compile()
	local start_date = vim.fn.strftime("%c")
	local append_data = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
		end
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Compilation started at " .. start_date })
	vim.fn.jobstart(last_args, {
		stdout_buffered = true,
		on_stdout = append_data,
		on_stderr = append_data,
		on_exit = function()
			local end_date = vim.fn.strftime("%c")
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Compilation finished at " .. end_date })
		end,
	})
	-- wait for job to finish.
end

local function main(opts)
	if next(opts.fargs) == nil then
		print("compile-mode: arguments not found.")
		return
	end
	last_args = opts.args

	local win = is_buffer_open(buf)
	if win == nil then
		if vertical_split then
			vim.cmd("botright vnew")
		else
			vim.cmd("botright new")
		end
		win = vim.api.nvim_get_current_win()
	end
	if buf == nil then
		buf = create_buffer()
	end

	compile()
	vim.api.nvim_win_set_buf(win, buf)
end

local function setup()
	vim.api.nvim_create_user_command("Compile", main, { nargs = "*" })
	vim.api.nvim_create_user_command("Recompile", compile, {})
	vim.api.nvim_create_user_command("ToggleCompileSplit", function()
		vertical_split = not vertical_split
	end, {})

	-- give the buffer a local mapping to quit the buffer with `q`.
	vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q<CR>", { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(buf, "n", "<leader>g", ":Recompile<CR>", { noremap = true, silent = true })
end

return { setup = setup }
