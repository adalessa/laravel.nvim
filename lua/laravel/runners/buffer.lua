local utils = require "laravel.utils"

---@param cmd table
---@return string
local function sanetize_cmd(cmd)
  -- this is to escape namespaces
  for index, value in ipairs(cmd) do
    cmd[index] = value:gsub("\\", "\\\\")
  end

  return vim.fn.join(cmd, " ")
end

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  local options = require("laravel.application").get_options()
  local default = {
    open = true,
    focus = true,
    buf_name = nil,
    split = {
      cmd = options.split.cmd,
      width = options.split.width,
    },
  }

  opts = vim.tbl_deep_extend("force", default, opts or {})

  local job_id = 0

  local bufnr = vim.api.nvim_create_buf(opts.listed or false, true)

  if opts.buf_name then
    if vim.fn.bufexists(opts.buf_name) == 1 then
      utils.notify("Buffer Run", {
        msg = string.format("Buffer with the name `%s` already exists", opts.buf_name),
        level = "ERROR",
      })
      return {}, false
    end
    vim.api.nvim_buf_set_name(bufnr, opts.buf_name)
  end

  local channel_id = vim.api.nvim_open_term(bufnr, {
    on_input = function(_, _, _, data)
      vim.api.nvim_chan_send(job_id, data)
    end,
  })

  local function handle_output(_, data)
    vim.fn.chansend(channel_id, data)
  end

  if opts.open then
    local cur_window = vim.api.nvim_get_current_win()
    vim.cmd(opts.split.cmd .. " new")
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, opts.split.width + 5)
    vim.api.nvim_win_set_buf(new_window, bufnr)

    vim.cmd "stopinsert"
    if opts.focus then
      vim.api.nvim_win_call(new_window, function ()
        vim.cmd "startinsert"
      end)
    else
      vim.api.nvim_set_current_win(cur_window)
    end
  end

  job_id = vim.fn.jobstart(sanetize_cmd(cmd), {
    stdeout_buffered = true,
    on_stdout = handle_output,
    on_exit = function(id)
      require("laravel._jobs").unregister(id)
      vim.fn.chanclose(channel_id)
      if opts.on_exit ~= nil then
        opts.on_exit()
      end
    end,
    pty = true,
    width = options.split.width,
  })

  require("laravel._jobs").register(job_id, bufnr)

  return {
    job = job_id,
    buff = bufnr,
  }, true
end
