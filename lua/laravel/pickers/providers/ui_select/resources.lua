local actions = require("laravel.pickers.common.actions")
local notify  = require("laravel.utils.notify")

local resources_picker = {}
function resources_picker:new(options)
  local instance = {
    options = options,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function resources_picker:run(opts)
  opts = opts or {}

  local resources = {}
  for name, path in pairs(self.options:get("resources")) do
    if vim.fn.isdirectory(path) == 1 then
      table.insert(resources, {
        name = name,
        path = path,
      })
    end
  end

  if vim.tbl_isempty(resources) then
    notify.warn("No resources defined in the config")
    return
  end

  vim.ui.select(resources, {
    prompt = "Resources",
    format_item = function(resource)
      return resource.name
    end,
    kind = "resources",
  }, function(resource)
    if resource ~= nil then
      actions.open_resource(resource)
    end
  end)
end

return resources_picker
