local Job = require("plenary.job")
local utils = require("laravel.utils")


---@class LaravelRunner
---@field terminal function Opens a terminal and execute the given command
---@field buffer function Executes the command in a new buffer and shows the result on it
---@field sync function Executes and returns the result of the execution
---@field async function Executes and returns immediately and will call the callback when done
local runners = {}

--- Runs in a new terminal and waits for the imput
---@param cmd table
runners.terminal = function(cmd)
    vim.cmd(string.format("%s new term://%s", require("laravel.app").options.split.cmd, table.concat(cmd, " ")))
    vim.cmd("startinsert")
end

--- Runs in a buffers as a job
---@param cmd table
runners.buffer = function(cmd)
    local options = require("laravel.app").options
    vim.cmd(options.split.cmd .. " new")
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, options.split.width + 5)
    local new_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(new_window, new_buffer)
    local channel_id = vim.api.nvim_open_term(new_buffer, {})

    local function handle_output(_, data)
        vim.fn.chansend(channel_id, data)
    end

    vim.fn.jobstart(cmd, {
        stdeout_buffered = true,
        on_stdout = handle_output,
        on_exit = function()
            vim.fn.chanclose(channel_id)
            vim.cmd("startinsert")
        end,
        pty = true,
        width = options.split.width,
    })
end

--- Runs and returns the command immediately
---@param cmd table
---@return table, number, table
runners.sync = function(cmd)
    if type(cmd) ~= "table" then
        utils.notify("runner_sync", {
            msg = "cmd has to be a table",
            level = "ERROR",
        })
        return {}, 1, {}
    end
    local command = table.remove(cmd, 1)
    local stderr = {}
    local stdout, ret = Job:new({
        command = command,
        args = cmd,
        on_stderr = function(_, data)
            table.insert(stderr, data)
        end,
    }):sync()

    return stdout, ret, stderr
end

--- Runs and returns the command inmediately
---@param cmd table
runners.async = function(cmd, callback)
    if type(cmd) ~= "table" then
        utils.notify("runner_async", {
            msg = "cmd has to be a table",
            level = "ERROR",
        })
        return {}
    end
    local command = table.remove(cmd, 1)
    local stderr = {}
    Job:new({
        command = command,
        args = cmd,
        on_exit = vim.schedule_wrap(callback),
        on_stderr = function(_, data)
            table.insert(stderr, data)
        end,
    }):start()
end

return runners
