local app = require("laravel.core.app")

local M = {}

---@async
function M.complete(value)
  ---@type laravel.loaders.composer_commands_cache_loader
  local loaders = app("laravel.loaders.composer_commands_cache_loader")
  local commands, err = loaders:load()

  if err then
    return {}
  end

  local segments = vim.split(value, " ")
  if segments[1] ~= "composer" and not vim.startswith("composer", segments[1]) then
    return {}
  end

  return vim
    .iter(commands)
    :filter(function(c)
      if segments[3] then
        return c.name == segments[2]
      end
      return vim.startswith(c.name, segments[2] or "")
    end)
    :map(function(c)
      if segments[3] then
        return "composer " .. c.name .. " [" .. (c.usage[1] or "") .. "]"
      end
      return "composer " .. c.name
    end)
    :totable()
end

return M
