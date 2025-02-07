local snacks = require("snacks").picker
local format_entry = require("laravel.pickers.snacks.format_entry")
local common_actions = require("laravel.pickers.common.actions")

local related_picker = {}

function related_picker:new(related)
  local instance = {
    related = related,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related_picker:run(opts)
  return self.related:get(vim.api.nvim_get_current_buf()):thenCall(function(related)
    snacks.pick(vim.tbl_extend("force", {
      title = "Related",
      items = vim
        .iter(related)
        :map(function(item)
          return {
            value = item,
            text = string.format("%s %s %s", item.class_name, item.type, item.extra_information),
          }
        end)
        :totable(),

      format = format_entry.related,
      layout = {
        preview = false,
      },
      confirm = function(picker, item)
        picker:close()
        if item then
          common_actions.open_relation(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return related_picker
