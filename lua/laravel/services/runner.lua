local combine_tables = require("laravel.utils").combine_tables
local is_make_command = require("laravel.utils").is_make_command
local find_class = require("laravel.utils").find_class_from_make_output

---@class LaravelRunner
---@field env LaravelEnvironment
---@field options LaravelOptionsService
---@field ui_handler LaravelUIHandler
local runner = {}

---@param env LaravelEnvironment
---@param options LaravelOptionsService
function runner:new(env, options, ui_handler)
  local instance = {
    env = env,
    ui_handler = ui_handler,
    options = options,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param cmd string
---@param args string[]
---@param opts table|nil
function runner:run(cmd, args, opts)
  local executable = self.env:get_executable(cmd)
  if not executable then
    error(string.format("Executable %s not found", cmd), vim.log.levels.ERROR)
    return
  end

  opts = vim.tbl_extend("force", self.options:get().commands_options[args[1]] or {}, opts or {})

  local command = combine_tables(executable, args)

  local instance = self.ui_handler:handle(opts)

  instance:mount()

  local job_id = vim.fn.termopen(table.concat(command, " "))

  if is_make_command(args[1]) then
    instance:on("TermClose", function()
      local lines = vim.api.nvim_buf_get_lines(instance.bufnr, 0, -1, false)
      local class = find_class(table.concat(lines, "\n"))
      if class ~= nil and class ~= "" then
        instance:unmount()
        vim.schedule(function()
          vim.cmd("e " .. class)
        end)
      end
    end)
  end

  instance:on("TermClose", function()
    vim.api.nvim_exec_autocmds("User", {
      pattern = "LaravelCommandRun",
      data = {
        cmd = cmd,
        args = args,
        options = opts,
        job_id = job_id,
      },
    })
  end)

  vim.cmd("startinsert")
end

return runner
