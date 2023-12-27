local views = require "laravel.views"
local utils = require "laravel.utils"
local notify = require "laravel.notify"

local M = {}

-- Should be use from blades to find where is being use
function M.go_to_usage()
  local fname = vim.uri_to_fname(vim.uri_from_bufnr(vim.api.nvim_get_current_buf()))
  local view = views.name_from_fname(fname)

  local matches = utils.runRipgrep(string.format("view\\(['\\\"]%s['\\\"]", view))

  if #matches == 0 then
    notify("laravel.views", { msg = "No usage of this view found", level = "WARN" })
  elseif #matches == 1 then
    vim.cmd("edit " .. matches[1].file)
  else
    vim.ui.select(
      vim.fn.sort(vim.tbl_map(function(item)
        return item.file
      end, matches)),
      { prompt = "File: " },
      function(value)
        if not value then
          return
        end
        vim.cmd("edit " .. value)
      end
    )
  end
end

-- should be use in files to find the views
function M.go_to_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local php_parser = vim.treesitter.get_parser(bufnr, "php")
  local tree = php_parser:parse()[1]
  if tree == nil then
    notify("laravel.views", { msg = "Could not retrive syntax tree", level = "WARN" })
    return
  end

  local query = vim.treesitter.query.get("php", "laravel_views")

  if true or query == nil then
    vim.treesitter.query.set(
      "php",
      "laravel_views",
      [[
        (function_call_expression
          (name) @function_name (#eq? @function_name "view")
          (arguments (argument (string (string_value) @view)))
        )
    ]]
    )

    query = vim.treesitter.query.get("php", "laravel_views")
  end
  if not query then
    notify("laravel.views", { msg = "Could not get proper query", level = "WARN" })
    return
  end

  local founds = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      table.insert(founds, vim.treesitter.get_node_text(node, bufnr))
    end
  end

  if #founds == 0 then
    notify("laravel.views", { msg = "No views found in file", level = "WARN" })
    return
  end

  if #founds > 1 then
    vim.ui.select(vim.fn.sort(founds), { prompt = "Which view:" }, function(selected)
      if not selected then
        return
      end
      views.open(selected)
    end)
    return
  end
  views.open(founds[1])
end

function M.auto()
  local ft = vim.o.filetype
  if ft == "php" then
    return M.go_to_definition()
  elseif ft == "blade" then
    return M.go_to_usage()
  end
end

return M
