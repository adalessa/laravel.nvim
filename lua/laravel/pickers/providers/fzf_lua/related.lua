local actions = require("laravel.pickers.common.actions")
local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_related
local fzf_exec = require("fzf-lua").fzf_exec

local related_picker = {}

function related_picker.run(opts, relations)
  local command_names, command_table = format_entry(relations)

  fzf_exec(
    command_names,
    vim.tbl_extend("force", {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          actions.open_relation(command)
        end,
      },
      prompt = "Related Files > ",
    }, opts or {})
  )
end

return related_picker
