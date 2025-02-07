local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_commands
local fzf_exec = require("fzf-lua").fzf_exec

local commands_picker = {}

function commands_picker:new(runner, user_commands_repository)
  local instance = {
    runner = runner,
    user_commands_repository = user_commands_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  self.user_commands_repository:all():thenCall(function(commands)
    local command_names, command_table = format_entry(commands)

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
