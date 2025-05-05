local promise = require("promise")

---@class laravel.services.actions
---@field actions laravel.actions.action[]
local service = {
  _inject = {
    actions = "laravel.actions"
  }
}

---@param actions laravel.actions.action[]
function service:new(actions)
  local instance = {
    actions = actions or {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

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
