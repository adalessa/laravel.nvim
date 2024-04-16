local resolvers = require("laravel.resolvers.cache")

return function(done, should_quote)
  resolvers.routes.resolve(function(routes)
    done({
      {
        items = vim.tbl_map(function(route)
          return {
            label = route.name,
            insertText = should_quote and string.format("'%s'", route.name) or route.name,
            kind = vim.lsp.protocol.CompletionItemKind["Value"],
            documentation = string.format("[%s] %s", route.method, route.uri),
          }
        end, routes),
        isIncomplete = false,
      },
    })
  end)
end
