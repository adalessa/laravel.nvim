local paths = require "laravel.paths"
local null_ls = require "null-ls"

local M = {}

M.name = "Laravel_Diagnostics"

function M.setup()
  null_ls.deregister(M.name)
  null_ls.register {
    name = M.name,
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

        if not query then
          error("Could not get treesitter query", vim.log.levels.ERROR)
        end

        for id, node in query:iter_captures(tree:root(), params.bufnr, 0, -1) do
          if query.captures[id] == "view" then
            local view = vim.treesitter.get_node_text(node, params.bufnr):gsub("'", "")
            local row, start_col = node:start()
            local _, end_col = node:end_()

            if view == "" then
              table.insert(diagnostics, {
                row = row + 1,
                col = start_col + 1,
                end_col = end_col + 1,
                source = "laravel.nvim",
                message = string.format("Need to provide a new to the view", view),
                severity = vim.diagnostic.severity.ERROR,
              })
            else
              local views_directory = paths.resource_path "views"

              local file_path = string.format("%s/%s.blade.php", views_directory, string.gsub(view, "%.", "/"))

              if vim.fn.filewritable(file_path) == 0 then
                table.insert(diagnostics, {
                  row = row + 1,
                  col = start_col + 1,
                  end_col = end_col + 1,
                  source = "laravel.nvim",
                  message = string.format("view '%s' does not exists", view),
                  user_data = {
                    view = view,
                  },
                  severity = vim.diagnostic.severity.ERROR,
                })
              end
            end
          end
        end

        return diagnostics
      end,
    },
  }
end

return M
