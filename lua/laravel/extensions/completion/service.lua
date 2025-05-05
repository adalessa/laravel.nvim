---@class LaravelCompletionSource
---@field env laravel.services.environment
---@field views_repository ViewsRepository
---@field routes_repository RoutesRepository
---@field configs_repository ConfigsRespository
---@field templates laravel.templates
local source = {}

function source:new(env, cache_views_repository, cache_configs_repository, cache_routes_repository, env_vars, templates)
  local instance = {
    env = env,
    views_repository = cache_views_repository,
    configs_repository = cache_configs_repository,
    routes_repository = cache_routes_repository,
    env_vars = env_vars,
    templates = templates,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

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
  local text = params.context.cursor_before_line

  if text:match("view%([%'|%\"]") or text:match("View::make%([%'|%\"]") then
    self.views_repository:all():thenCall(function(views)
      callback({
        items = vim
          .iter(views)
          :map(function(view)
            return {
              label = self.templates:build("view_label", view.name),
              insertText = view.name,
              kind = vim.lsp.protocol.CompletionItemKind["Value"],
              documentation = view.path,
            }
          end)
          :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  if text:match("config%([%'|%\"]") then
    self.configs_repository:all():thenCall(function(configs)
      callback({
        items = vim
          .iter(configs)
          :map(function(config)
            return {
              label = self.templates:build("config_label", config),
              insertText = config,
              kind = vim.lsp.protocol.CompletionItemKind["Value"],
              documentation = config,
            }
          end)
          :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  if text:match("route%([%'|%\"]") then
    self.routes_repository:all():thenCall(function(routes)
      callback({
        items = vim
          .iter(routes)
          :filter(function(route)
            return route.name ~= nil
          end)
          :map(function(route)
            return {
              label = self.templates:build("route_label", route.name),
              insertText = route.name,
              kind = vim.lsp.protocol.CompletionItemKind["Value"],
              documentation = self.templates:build(
                "route_documentation",
                route.name,
                table.concat(route.methods, " | "),
                route.uri,
                table.concat(route.middlewares or { "None" }, " | ")
              ),
            }
          end)
          :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  if text:match("env%([%'|%\"]") then
    self.env_vars:get():thenCall(function(variables)
      callback({
        items = vim
          .iter(variables)
          :map(function(variable)
            return {
              label = self.templates:build("env_var", variable.key),
              insertText = variable.key,
              kind = vim.lsp.protocol.CompletionItemKind["Value"],
              documentation = string.format("%s = %s", variable.key, variable.value),
            }
          end)
          :totable(),
        isIncomplete = false,
      })
    end)

    return
  end

  callback({ items = {} })
end

return source
