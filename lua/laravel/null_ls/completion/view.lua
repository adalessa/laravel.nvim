return function(done)
  local scan = require "plenary.scandir"
  local api = require "laravel.api"

  local candidates = {}

  local res = api.sync("artisan", { "tinker", "--execute", "echo resource_path('views')" })
  local view_path = res.stdout[1]
  local rule = string.format("^%s/(.*).blade.php$", view_path:gsub("-", "%%-"))
  local finds = scan.scan_dir(view_path, { hidden = false, depth = 4 })
  for _, value in pairs(finds) do
    local name = value:match(rule):gsub("/", ".")
    table.insert(candidates, {
      label = string.format("%s (view)", name),
      insertText = string.format("'%s'", name),
      kind = vim.lsp.protocol.CompletionItemKind["Value"],
      documentation = value,
    })
  end

  done { { items = candidates, isIncomplete = false } }
end