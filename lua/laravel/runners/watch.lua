---@param cmd table
---@param opts table
---@return table
return function(cmd, opts)
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

  local pattern = opts.pattern or { "*.php" }
  local buf_name = opts.buf_name or ("[Watched] " .. vim.fn.join(cmd, " "))

  local bufnr = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_buf_set_name(bufnr, buf_name)

  if opts.open then
    vim.cmd(opts.split.cmd .. " new")
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, opts.split.width + 5)
    vim.api.nvim_win_set_buf(new_window, bufnr)
  end

  local run = function()
    local windows = vim.fn.win_findbuf(bufnr)
    local new_window = windows[1]

    local channel_id = vim.api.nvim_open_term(bufnr, {})
    if new_window ~= nil then
      vim.api.nvim_win_set_cursor(new_window, { 1, 0 })
    end

    vim.fn.jobstart(vim.fn.join(cmd, " "), {
      stdeout_buffered = true,
      on_stdout = function(_, data)
        vim.fn.chansend(channel_id, data)
      end,
      on_exit = function()
        if new_window ~= nil then
          local row = vim.api.nvim_buf_line_count(bufnr)
          vim.api.nvim_win_set_cursor(new_window, { row, 0 })
        end
      end,
      pty = true,
      width = options.split.width,
    })
  end

  run()

  local group = vim.api.nvim_create_augroup("laravel", {})

  local au_cmd_id = vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = pattern,
    group = group,
    callback = function()
      run()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    buffer = bufnr,
    group = group,
    callback = function()
      vim.api.nvim_del_autocmd(au_cmd_id)
    end,
  })

  return {
    buff = bufnr,
  }
end
