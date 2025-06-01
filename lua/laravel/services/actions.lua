local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local nio = require("nio")

--TODO should not be a service
---@class laravel.services.actions
---@field actions laravel.actions.action[]
local service = Class({ actions = "laravel.actions" })

function service:run()
  nio.run(function()
    local bufnr = vim.api.nvim_get_current_buf()

    local actions = nio.gather(vim
      .iter(self.actions)
      :map(function(action)
        return function()
          if action:check(bufnr) then
            return action
          end
          return nil
        end
      end)
      :totable())
    actions = vim.tbl_filter(function(action)
      return action ~= nil
    end, actions)

    if #actions == 0 then
      notify.info("No actions available for this buffer")
      return
    end

    vim.schedule(function()
      vim.ui.select(actions, {
        prompt = "Select a Laravel action",
        format_item = function(item)
          return item:format(bufnr)
        end,
      }, function(action)
        if action then
          nio.run(function()
            action:run(bufnr)
          end)
        end
      end)
    end)
  end)
end

return service
