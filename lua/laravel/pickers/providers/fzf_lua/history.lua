local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_history

local history_picker = {}

function history_picker.run(opts, history_items)
  local history_names, history_table = format_entry(history_items)

  fzf_exec(
    history_names,
    vim.tbl_extend("force", {
      actions = {
        ["default"] = function(selected)
          local command = history_table[selected[1]]
          Laravel.run(command.name, command.args, command.opts)
        end,
      },
      prompt = "History > ",
    }, opts or {})
  )
end

return history_picker
