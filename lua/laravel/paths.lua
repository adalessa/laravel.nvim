local api = require "laravel.api"

local M = {}

local function get_cwd()
  return vim.fn.getcwd()
end

local function get_base_path()
  return api.php_execute("base_path()").stdout[1]
end

local function map_path(path)
  return path:gsub(get_base_path():gsub("-", "%%-"), get_cwd())
end

function M.resource_path(resource)
  local path = api.php_execute(string.format("resource_path('%s')", resource)).stdout[1]

  return map_path(path)
end

return M
