local routes_completion = {}

function routes_completion.complete(routes_loader, templates, params, callback)
  local routes, err = routes_loader:load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  return callback({
    items = vim
      .iter(routes)
      :filter(function(route)
        return route.name ~= nil
      end)
      :map(function(route)
        return {
          label = templates:build("route_label", route.name),
          insertText = route.name,
          kind = vim.lsp.protocol.CompletionItemKind["Value"],
          documentation = templates:build(
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
end

function routes_completion.shouldComplete(text)
  return text:match("route%([%'|%\"]")
end

return routes_completion
