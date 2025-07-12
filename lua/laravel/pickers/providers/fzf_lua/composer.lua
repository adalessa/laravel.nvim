local actions = require("laravel.pickers.common.actions")
local CommandPreviewer = require("laravel.pickers.providers.fzf_lua.previewer").ComposerPreviewer
local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_composer
local fzf_exec = require("fzf-lua").fzf_exec

local composer_picker = {}

function composer_picker.run(opts, commands)
  local command_names, command_table = format_entry(commands)

  fzf_exec(
    command_names,
    vim.tbl_extends("force", {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          actions.composer_run(command)
        end,
      },
      prompt = "Composer > ",
      previewer = CommandPreviewer(command_table),
      fzf_opts = {
        ["--preview-window"] = "nohidden,70%",
      },
    }, opts or {})
  )
end

return composer_picker
