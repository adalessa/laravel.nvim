local promise = require("promise")
local utils = require("laravel.utils.init")

local action = {}

function action:new(model, tinker)
  local instance = {
    tinker = tinker,
    model = model,
    info = nil,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function action:check(bufnr)
  return self.model
    :getByBuffer(bufnr)
    :thenCall(function(info)
      self.info = info
      return true
    end)
    :catch(function()
      return promise.resolve(false)
    end)
end

function action:format()
  return "Go To Migration of " .. self.info.class
end

function action:run()
  return self.tinker:text(string.format([[echo (new %s())->getTable();]], self.info.class)):thenCall(function(res)
    local table_name = vim.trim(res)
    local matches = utils.runRipgrep(string.format("Schema::(?:create|table)\\('%s'", table_name))

    if #matches == 0 then
      vim.notify("No migration found", vim.log.levels.WARN)
    elseif #matches == 1 then
      vim.cmd("edit " .. matches[1].file)
    else
      vim.ui.select(matches, {
        prompt = "File: ",
        format_entry = function(item)
          return item.file
        end,
      }, function(item)
        if not item then
          return
        end
        vim.cmd("edit " .. item.file)
      end)
    end
  end)
end

return action
