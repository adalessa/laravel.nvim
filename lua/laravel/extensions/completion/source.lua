local nio = require("nio")
local Class = require("laravel.utils.class")

---@class laravel.extensions.completion.source
---@field env laravel.core.env
---@field templates laravel.utils.templates
---@field environment_vars_loader laravel.loaders.environment_variables_loader
---@field views_loader laravel.loaders.views_cache_loader
---@field routes_loader laravel.loaders.routes_cache_loader
---@field configs_loader laravel.loaders.configs_loader
---@field inertia_loader laravel.loaders.inertia_cache_loader
local source = Class({
  env = "laravel.core.env",
  templates = "laravel.utils.templates",
  environment_vars_loader = "laravel.loaders.environment_variables_cache_loader",
  views_loader = "laravel.loaders.views_cache_loader",
  routes_loader = "laravel.loaders.routes_cache_loader",
  configs_loader = "laravel.loaders.configs_loader",
  inertia_loader = "laravel.loaders.inertia_cache_loader",
})

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  return self.env:isActive()
end

---Return the debug name of this source (optional).
---@return string
function source:get_debug_name()
  return "laravel"
end

function source:get_keyword_pattern()
  return [[\k\+]]
end

---Return trigger characters for triggering completion (optional).
function source:get_trigger_characters()
  return { '"', "'" }
end

function source:complete(params, callback)
  if vim.tbl_contains({ "php", "blade", "tinker" }, params.context.filetype, {}) then
    callback({ items = {} })
  end

  local text = params.context.cursor_before_line

  nio.run(function()
    local views_completion = require("laravel.extensions.completion.views_completion")
    if views_completion.shouldComplete(text) then
      return views_completion.complete(self.views_loader, self.templates, params, callback)
    end

    local inertia_completion = require("laravel.extensions.completion.inertia_completion")
    if inertia_completion.shouldComplete(text) then
      return inertia_completion.complete(self.inertia_loader, self.templates, params, callback)
    end

    local configs_completion = require("laravel.extensions.completion.configs_completion")
    if configs_completion.shouldComplete(text) then
      return configs_completion.complete(self.configs_loader, self.templates, params, callback)
    end

    local routes_completion = require("laravel.extensions.completion.routes_completion")
    if routes_completion.shouldComplete(text) then
      return routes_completion.complete(self.routes_loader, self.templates, params, callback)
    end

    local env_completion = require("laravel.extensions.completion.env_vars_completion")
    if env_completion.shouldComplete(text) then
      return env_completion.complete(self.environment_vars_loader, self.templates, params, callback)
    end

    local model_completion = require("laravel.extensions.completion.model_completion")
    if model_completion.shouldComplete(text) then
      return model_completion.complete(self.templates, params, callback)
    end
  end)

  callback({ items = {} })
end

return source
