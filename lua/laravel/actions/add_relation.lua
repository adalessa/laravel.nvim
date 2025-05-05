local promise = require("promise")
local templates = require("laravel.templates")

local action = {}

function action:new(model)
  local instance = {
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
  return "Add relation"
end

function action:run(bufnr)
  -- TODO
  -- ask type of relation
  -- ask Model
  -- check if Model in same namespace
  -- check if type of relation already there

  vim.lsp.util.apply_text_edits({
    {
      range = {
        start = { line = self.info.class_info.end_, character = 0 },
        ["end"] = { line = self.info.class_info.end_, character = 0 },
      },
      newText = templates:build("relation", "user", "BelongsTo", "belongsTo(User::class)"),
    },
  }, bufnr, "utf-8")
end

return action
