local null_ls = require "null-ls"

local completions = {
  view = require "laravel.null_ls.completion.view",
  route = require "laravel.null_ls.completion.route",
  config = require "laravel.null_ls.completion.config",
}

local function get_function_node(param_node)
  local node = param_node
  while node ~= nil and node.type(node) ~= "function_call_expression" do
    node = node:parent()
  end

  return node
end

local function get_member_node(param_node)
  local node = param_node
  while node ~= nil and node.type(node) ~= "member_call_expression" do
    node = node:parent()
  end

  return node
end

local M = {}

M.name = "Laravel.Completion"

function M.setup()
  null_ls.deregister(M.name)
  null_ls.register {
    name = M.name,
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local node = vim.treesitter.get_node()
        if not node then
          return
        end

        local member_node = get_member_node(node)
        if member_node then
          local node_text = vim.treesitter.get_node_text(member_node:field("name")[1], params.bufnr, {})
          local have_quotes = node.type(node) == "encapsed_string" or node.type(node) == "string"
          local completion = completions[node_text]
          if not completion then
            return
          end
          completion(done, not have_quotes)
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
end

return M
