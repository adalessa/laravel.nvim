local log = require("laravel.dev").log
local utils = require "laravel.utils"
local application = require "laravel.application"

local M = {}

---Opens the resource
---@param resource string
---@param name string
M.open = function(resource, name)
  local directory = application.get_options().resources[resource]
  local filename = ""
  if type(directory) == "function" then
    local err
    filename, err = directory(name)
    if err ~= nil then
      log.error("resource.open(): Error getting the name", err)
      return
    end
    filename = filename[1]
  elseif type(directory) == "string" then
    filename = string.format("%s/%s.php", directory, name)
  end

  if vim.fn.findfile(filename) then
    local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
    local buffer = vim.uri_to_bufnr(uri)
    vim.api.nvim_win_set_buf(0, buffer)

    return
  end

  utils.notify("resources.open", {
    msg = string.format("Can't find resource %s", filename),
    level = "INFO",
  })
end

--- Identifies if the given command is a resource
---@param name string
---@return boolean
M.is_resource = function(name)
  return application.get_options().resources[name] ~= nil
end

--- Creates the resource and opens the file
---@param cmd table
M.create = function(cmd)
  if not M.is_resource(cmd[1]) then
    log.error("resource.create(): Invalid command", cmd)
    return
  end

  local resource = cmd[1]
  local name = cmd[2]

  application.run("artisan", cmd, {
    runner = "async",
    callback = function()
      M.open(resource, name)
    end,
  })
end

return M
