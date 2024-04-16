local resolvers = require "laravel.resolvers.cache"

return function(done, should_quote)
  resolvers.views.resolve(function(views)
    done {
      {
        items = vim.tbl_map(function(view)
          return {
            label = string.format("%s (view)", view.name),
            insertText = should_quote and string.format("'%s'", view.name) or view.name,
            kind = vim.lsp.protocol.CompletionItemKind["Value"],
            documentation = view.path,
          }
        end, views),
        isIncomplete = false,
      },
    }
  end)
end
