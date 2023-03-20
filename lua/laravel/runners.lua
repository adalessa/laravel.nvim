local Job = require "plenary.job"
local utils = require "laravel.utils"

---@class LaravelRunner
---@field terminal function Opens a terminal and execute the given command
---@field buffer function Executes the command in a new buffer and shows the result on it
---@field sync function Executes and returns the result of the execution
---@field async function Executes and returns immediately and will call the callback when done
local runners = {}

--- Runs in a new terminal and can operate in the terminal
---@param cmd table
---@param opts table
runners.terminal = function(cmd, opts)
  local options = require("laravel").app.options
  local default = {
    split = {
      cmd = options.split.cmd,
    },
  }

  opts = vim.tbl_deep_extend("force", default, opts or {})
  vim.cmd(string.format("%s new term://%s", opts.split.cmd, table.concat(cmd, " ")))
  vim.cmd "startinsert"
end

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table
runners.buffer = function(cmd, opts)
  opts = opts or {}
  local options = require("laravel").app.options
  local default = {
    open = true,
    split = {
      cmd = options.split.cmd,
      width = options.split.width,
    },
  }

  opts = vim.tbl_deep_extend("force", default, opts or {})

  local bufnr = vim.api.nvim_create_buf(opts.listed or false, true)
  if opts.buf_name then
    vim.api.nvim_buf_set_name(bufnr, opts.buf_name);
  end
  local channel_id = vim.api.nvim_open_term(bufnr, {})

  if opts.open then
    vim.cmd(opts.split.cmd .. " new")
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, opts.split.width + 5)
    vim.api.nvim_win_set_buf(new_window, bufnr)
  end

  local function handle_output(_, data)
    vim.fn.chansend(channel_id, data)
  end

  local job_id = vim.fn.jobstart(vim.fn.join(cmd, " "), {
    stdeout_buffered = true,
    on_stdout = handle_output,
    on_exit = function(job_id)
      require("laravel._jobs").unregister(job_id)
      vim.fn.chanclose(channel_id)
      if opts.on_exit ~= nil then
        opts.on_exit()
      end
    end,
    pty = true,
    width = options.split.width,
  })

  require("laravel._jobs").register(job_id)
  vim.api.nvim_create_autocmd({ "BufUnload" }, {
    buffer = bufnr,
    callback = function()
      require("laravel._jobs").terminate(job_id)
    end,
  })

  return {
    job = job_id,
    buff = bufnr,
  }
end

--- Runs and returns the command immediately
---@param cmd table
---@return table
runners.sync = function(cmd)
  if type(cmd) ~= "table" then
    utils.notify("runners.sync", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return {
      out = {},
      exit_code = 1,
      err = { "cmd is not a table" },
    }
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

  return {
    out = stdout,
    exit_code = ret,
    err = stderr,
  }
end

--- Runs and returns the command inmediately
---@param cmd table
---@param opts table
---@return table
runners.async = function(cmd, opts)
  opts = opts or {}
  if type(cmd) ~= "table" then
    utils.notify("runner.async", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return { err = { "cmd is not a table" } }
  end

  if type(opts.callback) ~= "function" then
    utils.notify("runner.async", {
      msg = "callback not pass",
      level = "ERROR",
    })
    return { err = { "callback is not a function" } }
  end

  local command = table.remove(cmd, 1)
  local stderr = {}
  Job:new({
    command = command,
    args = cmd,
    on_exit = vim.schedule_wrap(opts.callback),
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):start()

  return {}
end

return runners
