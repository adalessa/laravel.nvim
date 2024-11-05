local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_commands
local fzf_exec = require("fzf-lua").fzf_exec

local commands_picker = {}

function commands_picker:new(runner, options)
  local instance = {
    runner = runner,
    options = options,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function commands_picker:run(opts)
  opts = opts or {}

  local commands = {}

  for command_name, group_commands in pairs(self.options:get().user_commands) do
    for name, details in pairs(group_commands) do
      table.insert(commands, {
        executable = command_name,
        name = name,
        display = string.format("[%s] %s", command_name, name),
        cmd = details.cmd,
        desc = details.desc,
        opts = details.opts or {},
      })
    end
  end

  if vim.tbl_isempty(commands) then
    vim.notify("No user command defined in the config", vim.log.levels.WARN, {})
    return
  end

  local command_names, command_table = format_entry(commands)

  fzf_exec(command_names, {
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
      end
    },
  })
end

return commands_picker
