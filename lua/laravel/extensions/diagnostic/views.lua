local nio = require("nio")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local log = require("laravel.utils.log")
local Error = require("laravel.utils.error")

---@class laravel.extensions.diagnostic.views_diagnostic
---@field views_loader laravel.loaders.views_loader
local views_diagnostic = Class({
  views_loader = "laravel.loaders.views_loader",
})

function views_diagnostic:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.views")
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)

  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  if not php_parser then
    notify.error("Could not get treesitter parser for PHP. Make sure you have the PHP parser installed.")
    return
  end
  local tree = php_parser:parse()[1]
  if tree == nil then
    notify.error("Could not parse the PHP file. Make sure the file is a valid PHP file.")
    return
  end
  local query = vim.treesitter.query.get("php", "laravel_views")

  if not query then
    notify.error(
      "Could not get treesitter query for Laravel views. Make sure you have the Laravel views query installed."
    )
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

  nio.run(function()
    local views, err = self.views_loader:load()

    if err then
      log.error(Error:new("Could not load views"):wrap(err))
      return
    end

    views = vim
      .iter(views)
      :map(
        ---@param view laravel.dto.artisan_views
        function(view)
          if view.isLivewire then
            return "livewire." .. view.key
          end
          return view.key
        end
      )
      :totable()

    nio.scheduler()
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
  end)
end

return views_diagnostic
