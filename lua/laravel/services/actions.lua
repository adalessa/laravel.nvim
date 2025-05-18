local promise = require("promise")
local Class = require("laravel.class")

---@class laravel.services.actions
---@field actions laravel.actions.action[]
local service = Class({ actions = "laravel.actions" })

function service:run()
  local bufnr = vim.api.nvim_get_current_buf()

  promise
    .all(vim
      .iter(self.actions)
      :map(function(action)
        return action:check(bufnr):thenCall(function(res)
          if res then
            return action
          end
          return nil
        end, function()
          return nil
        end)
      end)
      :totable())
    :thenCall(function(actions_results)
      local valid_actions = vim.tbl_filter(function(action_result)
        return action_result ~= nil
      end, actions_results)

      if #valid_actions == 0 then
        vim.notify("No actions available for this buffer", vim.log.levels.INFO)
        return
      end

      -- want to use snacks or telescope or picker
      vim.ui.select(valid_actions, {
        prompt = "Select a Laravel action",
        format_item = function(item)
          return item:format(bufnr)
        end,
      }, function(action)
        if action then
          action:run(bufnr)
        end
      end)
    end)
end

return service
