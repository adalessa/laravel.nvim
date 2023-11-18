return function(done)
  local routes = require "laravel.routes"

  local candidates = {}

  if vim.tbl_isempty(routes.list) then
    if not routes.load() then
      return
    end
  end

  for _, route in pairs(routes.list) do
    if route.name then
      table.insert(candidates, {
        label = string.format("%s (route)", route.name),
        insertText = string.format("'%s'", route.name),
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = string.format("[%s] %s", route.name, route.uri),
      })
    end
  end

  done { { items = candidates, isIncomplete = false } }
end
