local api = require "laravel.api"

local cache = {}

local M = {}

--- Get value from app config
---@param name string
function M.get(name)
  if cache[name] then
    return cache[name]
  end

  local response = api.tinker_execute(string.format('json_encode(config("%s"))', name))
  if response:failed() then
    vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
    return nil
  end

  local conf = vim.fn.json_decode(response:first())

  cache[name] = conf

  return conf
end

return M
