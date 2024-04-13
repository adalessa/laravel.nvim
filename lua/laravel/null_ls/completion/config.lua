local resolvers = require "laravel.resolvers.cache"

return function(done, should_quote)
  resolvers.configs.resolve(function(config)
    done {
      {
        items = vim.tbl_map(function(key)
          return {
            label = string.format("%s (config)", key),
            insertText = should_quote and string.format("'%s'", key) or key,
            kind = vim.lsp.protocol.CompletionItemKind["Value"],
          }
        end, vim.tbl_keys(config)),
        isIncomplete = false
      }
    }
  end)
end
