local M = {}

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    error "Completition view requires null ls"
  end

  local scan = require "plenary.scandir"
  local ts_utils = require "nvim-treesitter.ts_utils"
  local api = require "laravel.api"

  null_ls.deregister "Laravel Views"

  local laravel_view = {
    name = "Laravel Views",
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local node = ts_utils.get_node_at_cursor()
        node = node:parent()
        while node ~= nil and node.type(node) ~= "function_call_expression" do
          node = node:parent()
        end
        if node == nil then
          return
        end
        if node:child_count() > 0 then
          local node_text = vim.treesitter.get_node_text(node:child(0), params.bufnr, {})

          if node_text ~= "view" then
            return
          end
        end

        local candidates = {}

        local res = api.sync("artisan", { "tinker", "--execute", "echo resource_path('views')" })
        local view_path = res.stdout[1]
        local rule = string.format("^%s/(.*).blade.php$", view_path:gsub("-", "%%-"))
        local finds = scan.scan_dir(view_path, { hidden = false, depth = 4 })
        for _, value in pairs(finds) do
          local name = value:match(rule):gsub("/", ".")
          table.insert(candidates, {
            label = name,
            insertText = string.format('"%s"', name),
            kind = vim.lsp.protocol.CompletionItemKind["Value"],
            documentation = value,
          })
        end

        done { { items = candidates, isIncomplete = false } }
      end,
      async = true,
    },
  }

  null_ls.register(laravel_view)
end

return M
