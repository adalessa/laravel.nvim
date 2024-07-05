return function(bufnr)
  local paths = require("laravel.paths")

  local namespace = vim.api.nvim_create_namespace("laravel.views")
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)

  local diagnostics = {}

  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    error("Could not retrive syntax tree", vim.log.levels.ERROR)
  end
  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    error("Could not get treesitter query", vim.log.levels.ERROR)
  end

  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
      local row, start_col = node:start()
      local _, end_col = node:end_()

      if view == "" then
        table.insert(diagnostics, {
          lnum = row,
          col = start_col,
          end_col = end_col,
          source = "laravel.nvim",
          message = string.format("Need to provide a new to the view", view),
          severity = vim.diagnostic.severity.ERROR,
        })
      else
        local views_directory = paths.resource_path("views")

        local file_path = string.format("%s/%s.blade.php", views_directory, string.gsub(view, "%.", "/"))

        if vim.fn.filewritable(file_path) == 0 then
          table.insert(diagnostics, {
            lnum = row,
            col = start_col,
            end_col = end_col,
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

  vim.diagnostic.set(namespace, bufnr, diagnostics)
end
