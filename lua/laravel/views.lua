local run = require "laravel.run"
local paths = require "laravel.services.paths"

local M = {}

function M.open(view)
  -- FIX: the paths usage
  local views_directory = paths.resource_path "views"

  local file_path = string.format("%s/%s.blade.php", views_directory, string.gsub(view, "%.", "/"))

  if vim.fn.filewritable(file_path) == 1 then
    vim.cmd("edit " .. file_path)
    return
  end
  -- It creates the view if does not exists and user want it
  if vim.fn.confirm("View " .. view .. " does not exists, Should create it?", "&Yes\n&No") == 1 then
    run("artisan", { "make:view", view })
  end
end

function M.name_from_fname(fname)
  local views_directory = paths.resource_path "views" .. "/"
  return fname:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", ".")
end

return M
