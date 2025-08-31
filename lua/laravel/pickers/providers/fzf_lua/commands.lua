local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_commands
local fzf_exec = require("fzf-lua").fzf_exec

local commands_picker = {}

function commands_picker.run(opts, commands)
  local command_names, command_table = format_entry(commands)

  fzf_exec(
    command_names,
    vim.tbl_extend("force", {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          Laravel.run(command.executable, command.cmd, command.opts)
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
end

return commands_picker
