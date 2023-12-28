local paths = require "laravel.paths"
local scan = require "plenary.scandir"

return function(done, should_quote)
  local candidates = {}
  local view_path = paths.resource_path "views"
  local rule = string.format("^%s/(.*).blade.php$", view_path:gsub("-", "%%-"))
  local finds = scan.scan_dir(view_path, { hidden = false, depth = 4 })
  for _, value in pairs(finds) do
    local name = value:match(rule):gsub("/", ".")

    local insert = name
    if should_quote then
      insert = string.format("'%s'", name)
    end
    table.insert(candidates, {
      label = string.format("%s (view)", name),
      insertText = insert,
      kind = vim.lsp.protocol.CompletionItemKind["Value"],
      documentation = value,
    })
  end

  done { { items = candidates, isIncomplete = false } }
end
