local Class = require("laravel.utils.class")

local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_history

local history_picker = Class({
  history_service = "laravel.services.history",
  runner = "laravel.services.runner",
})

function history_picker:run(opts)
  opts = opts or {}

  local history = self.history_service:get()
  local history_names, history_table = format_entry(history)

  fzf_exec(history_names, {
    actions = {
      ["default"] = function(selected)
        local command = history_table[selected[1]]
        self.runner:run(command.name, command.args, command.opts)
      end,
    },
    prompt = "History > ",
  })
end

return history_picker
