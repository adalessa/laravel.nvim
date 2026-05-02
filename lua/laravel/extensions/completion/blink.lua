local nio = require("nio")
local app = require("laravel.core.app")

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
  -- local line = ctx.get_line()
  -- local col = ctx.get_cursor()[2]
  -- check how do I want to identified the completions.
  -- Need to get the hole line and the column
  local a = ctx.get_bounds("prefix")
  -- to work the same need the

  local text = a.line:sub(1, a.start_col)

  nio.run(function()
    local views_completion = require("laravel.extensions.completion.views_completion")
    if views_completion.shouldComplete(text) then
      return views_completion.complete(
        app("laravel.loaders.views_loader"),
        app("laravel.utils.templates"),
        {},
        callback
      )
    end

    local inertia_completion = require("laravel.extensions.completion.inertia_completion")
    if inertia_completion.shouldComplete(text) then
      return inertia_completion.complete(app("laravel.loaders.inertia_cache_loader"), {}, {}, callback)
    end

    local configs_completion = require("laravel.extensions.completion.configs_completion")
    if configs_completion.shouldComplete(text) then
      return configs_completion.complete(
        app("laravel.loaders.configs_loader"),
        app("laravel.utils.templates"),
        {},
        callback
      )
    end

    local routes_completion = require("laravel.extensions.completion.routes_completion")
    if routes_completion.shouldComplete(text) then
      return routes_completion.complete(
        app("laravel.loaders.routes_cache_loader"),
        app("laravel.utils.templates"),
        {},
        callback
      )
    end

    local env_completion = require("laravel.extensions.completion.env_vars_completion")
    if env_completion.shouldComplete(text) then
      return env_completion.complete(
        app("laravel.loaders.environment_variables_cache_loader"),
        app("laravel.utils.templates"),
        {},
        callback
      )
    end

    -- local model_completion = require("laravel.extensions.completion.model_completion")
    -- if model_completion.shouldComplete(text) then
    --   return model_completion.complete(self.templates, params, callback)
    -- end

    callback({ items = {} })
  end)

  -- local items = {}

  -- table.insert(items, {
  --   label = "laravel",
  --   kind = require('blink.cmp.types').CompletionItemKind.Text,
  --   documentation = "A simple function that returns 'blink'",
  --   -- insertText = "laravel",
  --   -- textEdit = {
  --   --   newText = "laravel",
  --   --   range = {
  --   --     start = { line = ctx.get_cursor()[1] - 1, character = col - 1 },
  --   --     ["end"] = { line = ctx.get_cursor()[1] - 1, character = col },
  --   --   },
  --   -- },
  -- })
  --
  -- callback({
  --   items = items,
  --   is_incomplete_backward = false,
  --   is_incomplete_forward = false,
  -- })
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
