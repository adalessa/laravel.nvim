--[[
This will take care of storing configuration per project persistent
--]]
---@class laravel.dto.config
---@field path string
---@field name string
---@field commands table
---@field condition table|nil

---@class laravel.core.config
---@field path string
---@field data table<string, laravel.dto.config>
local config = {}

---@param filePath string
function config:new(filePath)
  local instance = {
    path = filePath,
    data = {},
  }
  setmetatable(instance, self)
  self.__index = self

  instance:load()

  return instance
end

function config:load()
  if vim.fn.isdirectory(vim.fs.dirname(self.path)) == 0 then
    return {}
  end
  local file = io.open(self.path, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()
  if content == "" then
    return {}
  end

  local json = vim.json.decode(content)
  if not json then
    return {}
  end

  if type(json) ~= "table" then
    return {}
  end

  for _, project in pairs(json) do
    self.data[project.path] = project
  end
end

function config:save()
  if vim.fn.isdirectory(vim.fs.dirname(self.path)) == 0 then
    vim.fn.mkdir(vim.fs.dirname(self.path), "p")
  end
  local file = io.open(self.path, "w")
  if not file then
    return false
  end

  local json = vim.json.encode(self.data)
  file:write(json)
  file:close()

  return true
end

---@param path string
---@return laravel.dto.config|nil
function config:get(path)
  if not path then
    return nil
  end

  return self.data[path]
end

---@param cfg laravel.dto.config
function config:set(cfg)
  if not cfg.path or not cfg.name then
    return false
  end

  self.data[cfg.path] = cfg

  return self:save()
end

return config
