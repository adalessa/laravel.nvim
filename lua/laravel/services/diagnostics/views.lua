local views_diagnostic = {}

function views_diagnostic:new(views)
  local instance = {
    views = views,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function views_diagnostic:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.views")
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)

  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    -- error("Could not retrive syntax tree", vim.log.levels.ERROR)
    return
  end
  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    -- error("Could not get treesitter query", vim.log.levels.ERROR)
    return
  end

  local matches = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      local view = vim.treesitter.get_node_text(node, bufnr):gsub("'", "")
      local row, start_col = node:start()
      local _, end_col = node:end_()

      table.insert(matches, {
        view = view,
        row = row,
        start_col = start_col,
        end_col = end_col,
      })
    end
  end

  self.views:get(vim.schedule_wrap(function(views)
    views = vim.iter(views):map(function(view)
      return view.name
    end)

    vim.diagnostic.set(
      namespace,
      bufnr,
      vim
      .iter(matches)
      :filter(function(match)
        if match.view == "" then
          return true
        end

        if vim.tbl_contains(views, match.view) then
          return false
        end

        return true
      end)
      :map(function(match)
        return {
          lnum = match.row,
          col = match.start_col,
          end_col = match.end_col,
          source = "laravel.nvim",
          message = "view does not exists",
          severity = vim.diagnostic.severity.ERROR,
        }
      end)
      :totable()
    )
  end))
end

return views_diagnostic
