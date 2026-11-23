local nio = require("nio")

---@class laravel.extensions.completion.cmp_source
---@field completion laravel.extensions.completion
local source = {}

---@param completion laravel.extensions.completion|nil
---@return laravel.extensions.completion.cmp_source
function source.new(completion)
  -- The container factory always calls constructors as methods. For a
  -- dot-style constructor that means the module itself arrives as the first
  -- argument; treat it as "no dependency supplied" and use the dispatcher.
  if completion == source then
    completion = nil
  end

  return setmetatable({
    completion = completion or require("laravel.extensions.completion"),
  }, { __index = source })
end

---@return boolean
function source:is_available()
  return self.completion.is_enabled(vim.bo.filetype)
end

---@return string
function source:get_debug_name()
  return "laravel"
end

---@return string
function source:get_keyword_pattern()
  return [[\k\+]]
end

---@return string[]
function source:get_trigger_characters()
  return self.completion.trigger_characters()
end

---@param params table
---@param callback fun(response: table)
function source:complete(params, callback)
  local ctx = self.completion.from_cmp(params)

  if not self.completion.is_enabled(ctx.filetype) then
    callback({ items = {}, isIncomplete = false })
    return
  end

  nio.run(function()
    local ok, items = pcall(self.completion.resolve, ctx)
    callback({
      items = ok and items or {},
      isIncomplete = false,
    })
  end)
end

return source
