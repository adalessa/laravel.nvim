local Split = require "nui.split"
local notify = require "laravel.notify"
local config = require "laravel.config"

---@param cmd table
---@return string
local function sanetize_cmd(cmd)
  -- this is to escape namespaces
  for index, value in ipairs(cmd) do
    cmd[index] = value:gsub("\\", "\\\\")
  end

  return vim.fn.join(cmd, " ")
end

local function splitStrings(strings)
  local result = {}

  for _, str in ipairs(strings) do
    local parts = {}
    local stop
    local start = 1
    if str == "" then
      table.insert(result, "")
    else
      while start <= #str do
        local index = string.find(str, "\r", start + 1)

        if index then
          stop = index
          table.insert(parts, string.sub(str, start, stop))
          start = stop + 1
        else
          table.insert(parts, string.sub(str, start))
          break
        end
      end

      for _, part in ipairs(parts) do
        table.insert(result, part)
      end
    end
  end

  return result
end

--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  local default = {
    open = true,
    focus = true,
    buf_name = nil,
    split = config.options.split,
  }

  opts = vim.tbl_deep_extend("force", default, opts or {})

  local job_id = 0

  local bufnr = vim.api.nvim_create_buf(opts.listed or false, true)

  if opts.buf_name then
    if vim.fn.bufexists(opts.buf_name) == 1 then
      notify("Buffer Run", {
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
    local lines = splitStrings(data)
    vim.fn.chansend(channel_id, lines)
  end

  if opts.open then
    if opts.focus then
      opts.split.enter = true
    end

    local split = Split(opts.split)

    -- mount/open the component
    split:mount()

    vim.api.nvim_win_set_buf(split.winid, bufnr)

    vim.api.nvim_win_call(split.winid, function()
      -- vim.cmd "stopinsert"
      vim.cmd "startinsert"
    end)
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
    width = config.options.split.width,
  })

  require("laravel._jobs").register(job_id, bufnr)

  return {
    job = job_id,
    buff = bufnr,
  }, true
end
