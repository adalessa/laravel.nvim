local paths = require "laravel.paths"

local M = {}

function M.setup()
  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    vim.notify(
      "Null ls feature is enable but null ls is not installed please install to have this feature enable",
      vim.log.levels.ERROR
    )
    return
  end

  null_ls.deregister "Laravel diagnostics"

  local laravel_diagnostic = {
    name = "Laravel diagnostics",
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "php" },
    generator = {
      fn = function(params)
        local diagnostics = {}

        local php_parser = vim.treesitter.get_parser(params.bufnr, "php")
        local tree = php_parser:parse()[1]
        if tree == nil then
          error("Could not retrive syntax tree", vim.log.levels.ERROR)
        end
        local query = vim.treesitter.query.get("php", "laravel_views")

        if query == nil then
          vim.treesitter.query.set(
            "php",
            "laravel_views",
            [[
                (function_call_expression
                  (name) @function_name (#eq? @function_name "view")
                  (arguments (argument (string (string_value) @view)))
                )
                (member_call_expression
                  (name) @member_name (#eq? @member_name "view")
                  (arguments (argument (string (string_value) @view)))
                )
            ]]
          )

          query = vim.treesitter.query.get("php", "laravel_views")
        end
        if not query then
          error("Could not get treesitter query", vim.log.levels.ERROR)
        end

        for id, node in query:iter_captures(tree:root(), params.bufnr, 0, -1) do
          if query.captures[id] == "view" then
            local view = vim.treesitter.get_node_text(node, params.bufnr)

            local views_directory = paths.resource_path "views"

            local file_path = string.format("%s/%s.blade.php", views_directory, string.gsub(view, "%.", "/"))

            if vim.fn.filewritable(file_path) == 0 then
              local row, start_col = node:start()
              local _, end_col = node:end_()
              table.insert(diagnostics, {
                row = row + 1,
                col = start_col + 1,
                end_col = end_col + 1,
                source = "laravel.nvim",
                message = "view does not exists",
                severity = vim.diagnostic.severity.ERROR,
              })
            end
          end
        end

        return diagnostics
      end,
    },
  }

  null_ls.register(laravel_diagnostic)
end

return M
