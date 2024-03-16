local api = require "laravel.api"

local cache = {}

local M = {}

---@return ApiResponse
local function exec(cmd)
  if not cache[cmd] then
    cache[cmd] = api.tinker_execute(cmd)
  end

  return cache[cmd]
end

local function get_cwd()
  return vim.fn.getcwd()
end

local function get_base_path()
  return exec("base_path()"):first()
end

local function map_path(path)
  return path:gsub(get_base_path():gsub("-", "%%-"), get_cwd())
end

function M.resource_path(resource)
  local path = exec(string.format("resource_path('%s')", resource)):first()

  return map_path(path)
end

return M
