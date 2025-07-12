local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local resources_picker = Class({
  config = "laravel.services.config",
})

function resources_picker:run(picker, opts)
  local resources = {}
  for name, path in pairs(self.config.get("resources", {})) do
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

  vim.schedule(function()
    picker.run(opts, resources)
  end)
end

return resources_picker
