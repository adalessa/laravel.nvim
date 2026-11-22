---@type laravel.extensions.completion.Provider
local routes_completion = {
  name = "routes",
  trigger_characters = { "'", '"' },
  dependencies = {
    routes_loader = "laravel.loaders.routes_loader",
    templates = "laravel.utils.templates",
  },
}

function routes_completion.matches(ctx)
  return ctx.before:match("%f[%a]route%s*%(%s*[\"']") ~= nil
end

function routes_completion.complete(_, deps)
  local routes, err = deps.routes_loader:load()
  if err then
    return {}, err
  end

  return vim
    .iter(routes)
    :filter(function(route)
      return route.name ~= nil
    end)
    :map(function(route)
      return {
        label = deps.templates:build("route_label", route.name),
        insertText = route.name,
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = deps.templates:build(
          "route_documentation",
          route.name,
          table.concat(route.methods, " | "),
          route.uri,
          table.concat(route.middlewares or { "None" }, " | ")
        ),
      }
    end)
    :totable()
end

return routes_completion
