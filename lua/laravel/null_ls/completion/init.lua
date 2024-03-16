local null_ls = require "null-ls"

local completions = {
  view = require "laravel.null_ls.completion.view",
  route = require "laravel.null_ls.completion.route",
  config = require "laravel.null_ls.completion.config",
}

local M = {}

M.name = "Laravel_completion"

function M.setup()
  null_ls.deregister(M.name)
  null_ls.register {
    name = M.name,
    method = null_ls.methods.COMPLETION,
    filetypes = { "php" },
    generator = {
      fn = function(params, done)
        local currentNode = vim.treesitter.get_node()
        if not currentNode then
          return
        end

        local pos = params.lsp_params.position

        local php_parser = vim.treesitter.get_parser(params.bufnr, "php")
        local tree = php_parser:parse()[1]

        --- START Completion views
        local viewsQuery = vim.treesitter.query.get("php", "laravel_view_arguments")
        if viewsQuery then
          for id, node in viewsQuery:iter_captures(tree:root(), params.bufnr, pos.line, pos.line + 1) do
            if viewsQuery.captures[id] == "routeViewArguments" then
              if
                currentNode:type() == "string"
                and node:named_child_count() > 1
                and node:named_child(1):equal(currentNode:parent())
              then
                completions.view(done, false)
                return
              end
              if currentNode:type() == "arguments" then
                if node:named_child_count() == 1 then
                  completions.view(done, true)
                  return
                end
              end
            end
            if viewsQuery.captures[id] == "viewMethodArugments" then
              if
                currentNode:type() == "string"
                and node:named_child_count() > 0
                and node:named_child(0):equal(currentNode:parent())
              then
                completions.view(done, false)
                return
              end
              if currentNode:type() == "arguments" then
                if node:named_child_count() == 0 then
                  completions.view(done, true)
                  return
                end
              end
            end
            if
              viewsQuery.captures[id] == "viewFunctionArugments"
              -- For some reason the query does not work as expected
              and vim.treesitter.get_node_text(node:prev_named_sibling(), params.bufnr) == "view"
            then
              if
                currentNode:type() == "string"
                and node:named_child_count() > 0
                and node:named_child(0):equal(currentNode:parent())
              then
                completions.view(done, false)
                return
              end
              if currentNode:type() == "arguments" and node:named_child_count() == 0 then
                completions.view(done, true)
                return
              end
            end
          end
        end
        --- END Completion views

        --- START Completion routes
        local routeQuery = vim.treesitter.query.get("php", "laravel_route_argument")
        if routeQuery then
          for id, node in routeQuery:iter_captures(tree:root(), params.bufnr, pos.line, pos.line + 1) do
            if
              routeQuery.captures[id] == "routeFunctionArugments"
              -- For some reason the query does not work as expected
              and vim.treesitter.get_node_text(node:prev_named_sibling(), params.bufnr) == "route"
            then
              if
                currentNode:type() == "string"
                and node:named_child_count() > 0
                and node:named_child(0):equal(currentNode:parent())
              then
                completions.route(done, false)
                return
              end
              if currentNode:type() == "arguments" and node:named_child_count() == 0 then
                completions.route(done, true)
                return
              end
            end
          end
        end
        --- END Completion routes

        --- START Completion routes
        local configQuery = vim.treesitter.query.get("php", "laravel_config_argument")
        if configQuery then
          for id, node in configQuery:iter_captures(tree:root(), params.bufnr, pos.line, pos.line + 1) do
            if
              configQuery.captures[id] == "configFunctionArugments"
              -- For some reason the query does not work as expected
              and vim.treesitter.get_node_text(node:prev_named_sibling(), params.bufnr) == "config"
            then
              if
                currentNode:type() == "string"
                and node:named_child_count() > 0
                and node:named_child(0):equal(currentNode:parent())
              then
                completions.config(done, false)
                return
              end
              if currentNode:type() == "arguments" and node:named_child_count() == 0 then
                completions.config(done, true)
                return
              end
            end
          end
        end
        --- END Completion routes
      end,
      async = true,
    },
  }
end

return M
