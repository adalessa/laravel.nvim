local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local nio = require("nio")

--TODO should not be a service
---@class laravel.services.actions
---@field actions laravel.actions.action[]
local service = Class({ actions = "laravel.actions" })

---@async
function service:run()
  local bufnr = vim.api.nvim_get_current_buf()
  local actions = vim
    .iter(self.actions)
    :filter(function(action)
      return action:check(bufnr)
    end)
    :totable()

  if #actions == 0 then
    notify.info("No actions available for this buffer")
    return
  end

  local action = nio.ui.select(actions, {
    prompt = "Select a Laravel action",
    format_item = function(item)
      return item:format(bufnr)
    end,
  })

  if action then
    action:run(bufnr)
  end
end

return service
