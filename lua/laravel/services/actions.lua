local promise = require("promise")

local service = {}

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
        return action:check(bufnr)
      end)
      :totable())
    :thenCall(function(results)
      local valid_actions = vim.tbl_filter(function(result)
        return result
      end, results)

      if #valid_actions == 0 then
        return
      end

      vim.ui.select(valid_actions, {
        prompt = "Select an action",
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
