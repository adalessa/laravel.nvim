local notify = require "laravel.notify"
local get_node_text = vim.treesitter.get_node_text
local run = require "laravel.run"
local api = require "laravel.api"

local M = {}
-- In the current buffer get run a treesitter query to get the frist argument for `view()` and `response()->view()`.
-- Present them in a ui select if more than one
-- From selected or unique, look for file. if does not exists ask to be created, open buffer or use artisan command

local function gotoView(view)
  local res = api.sync("artisan", { "tinker", "--execute", "echo resource_path('views')" })
  local view_path = res.stdout[1]

  local file_path = string.format("%s/%s.blade.php", view_path, string.gsub(view, "%.", "/"))

  if vim.fn.findfile(file_path) then
    vim.cmd("edit " .. file_path)
    return
  end
  -- It creates the view if does not exists and user want it
  if vim.fn.confirm("View does not exists, Should create it?", "&Yes\n&No") == 1 then
    run("artisan", { "make:view", view })
  end
end

local function php_run()
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

  local views = {}
  for id, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
    if query.captures[id] == "view" then
      table.insert(views, get_node_text(node, bufnr))
    end
  end

  if #views == 0 then
    notify("laravel.views", { msg = "No views found in file", level = "WARN" })
    return
  end

  if #views > 1 then
    vim.ui.select(vim.fn.sort(views), { prompt = "Which view:" }, function(selected)
      if not selected then
        return
      end
      gotoView(selected)
    end)
    return
  end
  gotoView(views[1])
end

local function blade_run()
  -- get the filename
  -- TODO: from filename get the name of view in dot format
  -- grep the app directory looking for that with view("<name>"
  -- not close it for posibility of arguments, any quotes
  -- more than one show select
  -- open file and position in line
end

function M.run()
  local ft = vim.o.filetype
  if ft == "php" then
    php_run()
  elseif ft == "blade" then
    blade_run()
  end
end

return M
