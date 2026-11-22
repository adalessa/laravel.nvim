local nio = require("nio")

---@class laravel.extensions.completion.blink_source
---@field completion laravel.extensions.completion
local source = {}

---@param opts table|nil
---@return laravel.extensions.completion.blink_source
function source.new(opts)
  opts = opts or {}

  return setmetatable({
    completion = opts.completion or require("laravel.extensions.completion"),
  }, { __index = source })
end

---@return boolean
function source:enabled()
  return self.completion.is_enabled(vim.bo.filetype)
end

---@return string[]
function source:get_trigger_characters()
  return self.completion.trigger_characters()
end

---@param ctx blink.cmp.Context
---@param callback fun(response: table)
---@return fun()|nil cancel
function source:get_completions(ctx, callback)
  local completion_ctx = self.completion.from_blink(ctx)

  if not self.completion.is_enabled(completion_ctx.filetype) then
    callback({
      items = {},
      is_incomplete_backward = false,
      is_incomplete_forward = false,
    })
    return function() end
  end

  local cancelled = false

  nio.run(function()
    local ok, items = pcall(self.completion.resolve, completion_ctx)
    if cancelled then
      return
    end

    callback({
      items = ok and items or {},
      is_incomplete_backward = false,
      is_incomplete_forward = false,
    })
  end)

  return function()
    cancelled = true
  end
end

return source
