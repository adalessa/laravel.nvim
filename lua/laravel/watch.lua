local Split = require("nui.split")
local event = require("nui.utils.autocmd").event
local app = require("laravel.app")

---@param name string
---@param args string[]
---@param opts table|nil
return function(name, args, opts)
  opts = opts or {}
  local executable = app("env"):get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
    return
  end
  local cmd = { unpack(executable), unpack(args) }

  local command_option = app("options"):get().commands_options[args[1]] or {}

  opts = vim.tbl_extend("force", command_option, opts)

  local nui_opts = opts.nui_opts or app("options"):get().options.ui.nui_opts.split
  nui_opts.enter = false
  local instance = Split(nui_opts)

  instance:mount()

  local bufnr = instance.bufnr

  local run = function()
    local chan_id = vim.api.nvim_open_term(bufnr, {})
    vim.fn.jobstart(table.concat(cmd, " "), {
      stdeout_buffered = true,
      on_stdout = function(_, data)
        vim.fn.chansend(chan_id, data)
        local row = vim.api.nvim_buf_line_count(bufnr)
        vim.api.nvim_win_set_cursor(instance.winid, { row, 0 })
      end,
      pty = true,
    })
  end
  run()

  local group = vim.api.nvim_create_augroup("laravel.watch", {})

  local au_cmd_id = vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = opts.pattern or { "*.php" },
    group = group,
    callback = function()
      run()
    end,
  })

  instance:on(event.BufHidden, function()
    vim.api.nvim_del_autocmd(au_cmd_id)
    vim.notify("AutoCmd for watch deleted", vim.log.levels.INFO, {})
  end)
end
