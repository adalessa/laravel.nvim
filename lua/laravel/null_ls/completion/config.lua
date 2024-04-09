local resolvers = require "laravel.resolvers.cache"

return function(done, should_quote)
  resolvers.configs.resolve(function(configs)
    done {
      {
        items = vim.tbl_map(function(config)
          return {
            label = string.format("%s (config)", config),
            insertText = should_quote and string.format("'%s'", config) or config,
            kind = vim.lsp.protocol.CompletionItemKind["Value"],
          }
        end, configs),
        isIncomplete = false
      }
    }
  end)
end
