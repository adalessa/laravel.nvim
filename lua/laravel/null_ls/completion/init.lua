local M = {}

local completions = {
  view = require "laravel.null_ls.completion.view",
  route = require "laravel.null_ls.completion.route",
}

local function get_function_node(param_node)
  local node = param_node
  while node ~= nil and node.type(node) ~= "function_call_expression" do
    node = node:parent()
  end

  return node
end

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    vim.notify(
      "Null ls feature is enable but null ls is not installed please install to have this feature enable",
      vim.log.levels.ERROR
    )
    return
  end

  null_ls.deregister "Laravel"

  local laravel = {
    name = "Laravel",
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local node = vim.treesitter.get_node()
        if not node then
          return
        end

        local func_node = get_function_node(node)
        if not func_node then
          return
        end

        if func_node:child_count() > 0 then
          local node_text = vim.treesitter.get_node_text(func_node:child(0), params.bufnr, {})

          -- encapsed_string initial node it means is in double quotes
          -- string initial node it means single quotes
          -- arguments does not have quotes
          local have_quotes = node.type(node) == "encapsed_string" or node.type(node) == "string"
          local completion = completions[node_text]
          if not completion then
            return
          end
          completion(done, not have_quotes)
        end
      end,
      async = true,
    },
  }

  null_ls.register(laravel)
end

return M
