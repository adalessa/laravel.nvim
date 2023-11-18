local failed_last_time = false

return function(done)
  local routes = require "laravel.routes"

  local candidates = {}

  if vim.tbl_isempty(routes.list) then
    if failed_last_time then
      return
    end

    local ok, res = pcall(routes.load)
    if not ok or not res then
      failed_last_time = true
      return
    end
  end
  failed_last_time = false

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
