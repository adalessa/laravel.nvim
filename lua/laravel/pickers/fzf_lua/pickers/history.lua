local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_history
local app = require("laravel").app

local history_picker = {}

function history_picker:new(history)
  local instance = {
    history_provider = history,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function history_picker:run(opts)
  opts = opts or {}

  local history = self.history_provider:get()
  local history_names, history_table = format_entry(history)

  fzf_exec(history_names, {
    actions = {
      ["default"] = function(selected)
        local command = history_table[selected[1]]
        app("runner"):run(command.name, command.args, command.opts)
      end,
    },
    prompt = "History > ",
  })
end

return history_picker
