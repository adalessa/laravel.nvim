local Class = require("laravel.utils.class")
local is_make_command = require("laravel.utils.init").is_make_command
local find_class = require("laravel.utils.init").find_class_from_make_output

---@class laravel.services.runner
---@field config laravel.services.config
---@field ui_handler LaravelUIHandler
---@field command_generator laravel.services.command_generator
local runner = Class({
  config = "laravel.services.config",
  ui_handler = "laravel.services.ui_handler",
  command_generator = "laravel.services.command_generator",
})

---@param program string
---@param args string[]
---@param opts table|nil
function runner:run(program, args, opts)
  args = args or {}
  opts = opts or {}
  local command = self.command_generator:generate(program, args)
  if not command then
    return {}, string.format("Command %s not found", program)
  end

  local subCommand = args[1] or vim.split(program, " ")[2] or nil

  if subCommand then
    opts = vim.tbl_extend("force", self.config("commands_options")[subCommand] or {}, opts)
  end

  local instance = self.ui_handler:handle(opts)

  instance:mount()

  local job_id = vim.fn.jobstart(table.concat(command, " "), { term = true })

  instance:on("TermClose", function()
    if is_make_command(args[1]) then
      local lines = vim.api.nvim_buf_get_lines(instance.bufnr, 0, -1, false)
      local class = find_class(table.concat(lines, ""))
      if class ~= nil and class ~= "" then
        instance:unmount()
        vim.schedule(function()
          vim.cmd("e " .. class)
        end)
      end
    end

    vim.api.nvim_exec_autocmds("User", {
      pattern = "LaravelCommandRun",
      data = {
        cmd = program,
        args = args,
        options = opts,
        job_id = job_id,
      },
    })
  end)

  vim.cmd("startinsert")
end

return runner
