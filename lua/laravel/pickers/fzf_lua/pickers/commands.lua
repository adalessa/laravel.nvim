local Class = require("laravel.utils.class")

local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_commands
local fzf_exec = require("fzf-lua").fzf_exec

---@class laravel.pickers.fzf_lua.commands
---@field runner laravel.services.runner
---@field commands_loader laravel.loaders.user_commands_loader
local commands_picker = Class({
  runner = "laravel.services.runner",
  commands_loader = "laravel.loaders.user_commands_loader",
})

function commands_picker:run(opts)
  local commands = self.commands_loader:load()
  local command_names, command_table = format_entry(commands)

  vim.schedule(function()
    fzf_exec(
      command_names,
      vim.tbl_extend("force", {
        actions = {
          ["default"] = function(selected)
            local command = command_table[selected[1]]
            self.runner:run(command.executable, command.cmd, command.opts)
          end,
        },
        prompt = "User Commands > ",
        fzf_opts = {
          ["--preview-window"] = "nohidden,70%",
          ["--preview"] = function(selected)
            local command = command_table[selected[1]]

            return command.desc
          end,
        },
      }, opts or {})
    )
  end)
end

return commands_picker
