local M = {}

local completions = {
  view = require "laravel.null_ls.completion.view",
  route = require "laravel.null_ls.completion.route",
}

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    error "Completition requires null ls"
  end

  null_ls.deregister "Laravel"

  local laravel = {
    name = "Laravel",
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local ts_utils = require "nvim-treesitter.ts_utils"
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

          local completion = completions[node_text]
          if not completion then
            return
          end
          completion(done)
        end
      end,
      async = true,
    },
  }

  null_ls.register(laravel)
end

return M
