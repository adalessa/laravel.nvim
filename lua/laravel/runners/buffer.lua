--- Runs in a buffers as a job
---@param cmd table
---@param opts table
---@return table
return function(cmd, opts)
  opts = opts or {}
  local options = require("laravel.application").get_options()
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
    vim.api.nvim_buf_set_name(bufnr, opts.buf_name)
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
