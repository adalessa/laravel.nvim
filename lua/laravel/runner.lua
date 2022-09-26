local Job = require'plenary.job'
local utils = require("laravel.utils")

local runner = {}

function runner.terminal(cmd)
    vim.cmd(string.format("%s new term://%s", LaravelConfig.split_cmd, table.concat(cmd, ' ')))
    vim.cmd("startinsert")
end

function runner.buffer(cmd)
    vim.cmd(LaravelConfig.split_cmd .. ' new')
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, LaravelConfig.split_width + 5)
    local new_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(new_window, new_buffer)
    local channel_id = vim.api.nvim_open_term(new_buffer, {})

    local function handle_output(_, data)
        vim.fn.chansend(channel_id, data)
    end

	vim.fn.jobstart(cmd, {
        stdeout_buffered = true,
        on_stdout = handle_output,
        on_exit = function ()
            vim.fn.chanclose(channel_id)
            vim.cmd("startinsert")
        end,
        pty = true,
        width = LaravelConfig.split_width,
	})
end


function runner.sync(cmd)
  if type(cmd) ~= "table" then
    utils.notify("get_os_command_output", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return {}
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

return runner
