local M = {}

-- keep a cache of last passed arguments.
local last_args = ""
local vertical_split = true
local next = next

local lv = require("lasts").var or nil

local function create_buffer()
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_buf_set_name(buf, "*compilation*")
    return buf
end

local buf = nil

local function is_buffer_open(buffer_id)
    local windows = vim.api.nvim_tabpage_list_wins(0)

    for _, win_id in ipairs(windows) do
        if vim.api.nvim_win_get_buf(win_id) == buffer_id then
            return win_id
        end
    end

    return nil
end

local function savetolv()
    if lv then
        lv["compile_args"] = last_args
        print("I did something!")
        require("lasts").save()
    end
end

M.compile = function()
    if last_args == "" then
        -- prompt user if no argument has been saved yet.
        print("compile-mode: compile command not set.")
        return
    end

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
        vim.api.nvim_buf_set_keymap(buf, "n", "q", ":quit<CR>", { noremap = true, silent = true })
    end

    local start_date = vim.fn.strftime("%c")
    local append_data = function(_, data, event)
        local end_date = vim.fn.strftime("%c")
        if event == "stdout" then
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end
        if event == "stderr" then
            if data then
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
            end
        end
        if event == "exit" then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Compilation finished at " .. end_date })
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "-*- compile-mode; directory: '" .. vim.fn.getcwd() .. "' -*-" })
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Compilation started at " .. start_date })
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "command: " .. last_args })
    vim.fn.jobstart(last_args, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = append_data,
        on_stderr = append_data,
        on_exit = append_data,
    })

    vim.api.nvim_win_set_buf(win, buf)
end

M.compile_setup = function(opts)
    -- sets the arguments to be executed.
    if next(opts.fargs) == nil then
        last_args = vim.fn.input({
            prompt = "Compile command: ",
            default = last_args,
        })

        if last_args == "" then
            return
        end
        savetolv()
    else
        last_args = opts.args
    end

    M.compile()
end

M.setup = function()
    vim.api.nvim_create_user_command("Compile", M.compile_setup, { nargs = "*" })
    vim.api.nvim_create_user_command("Recompile", M.compile, {})
    vim.api.nvim_create_user_command("ToggleCompileSplit", function()
        vertical_split = not vertical_split
    end, {})
    -- give the buffer a local mapping to quit with `q`.
    --vim.api.nvim_buf_set_keymap(buf, "n", "<leader>g", ":Recompile<CR>", { noremap = true, silent = true })
    --vim.keymap.set("n", "<leader>c", ":Recompile<CR>", { noremap = true, silent = true })
end

return M
