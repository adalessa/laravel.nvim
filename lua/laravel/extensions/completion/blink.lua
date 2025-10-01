--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = opts
  return self
end

function source:enabled()
  return Laravel("laravel.core.env"):isActive() and vim.tbl_contains({ "tinker", "blade", "php" }, vim.bo.filetype)
end

function source:get_trigger_characters()
  return { "'", '"', ":", ">" }
end

function source:get_completions(ctx, callback)
  -- could get the line with normal
  local line = ctx.get_line()
  local col = ctx.get_cursor()[2]
  -- check how do I want to identified the completions.
  -- Need to get the hole line and the column
  return function() end
end

function source:resolve(item, callback) end

function source:execute(ctx, item, callback, default_implementation)
  -- When you provide an `execute` function, your source must handle the execution
  -- of the item itself, but you may use the default implementation at any time
  default_implementation()

  -- The callback _MUST_ be called once
  callback()
end

return source
