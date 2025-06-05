local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local actions = require("laravel.pickers.common.actions")
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_related
local fzf_exec = require("fzf-lua").fzf_exec

---@class laravel.pickers.fzf_lua.related
---@field related laravel.services.related
local related_picker = Class({
  related = "laravel.services.related",
})

function related_picker:run()
  local relations, err = self.related:get(vim.api.nvim_get_current_buf())
  if err then
    return notify.error("Error loading related items: " .. err)
  end

  local command_names, command_table = format_entry(relations)

  vim.schedule(function()
    fzf_exec(command_names, {
      actions = {
        ["default"] = function(selected)
          local command = command_table[selected[1]]
          actions.open_relation(command)
        end,
      },
      prompt = "Related Files > ",
    })
  end)
end

return related_picker
