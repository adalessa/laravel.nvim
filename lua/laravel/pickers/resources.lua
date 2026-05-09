local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local resources_picker = Class({
  options = "laravel.core.options_manager",
})

function resources_picker:run(picker, opts)
  local resources = {}
  for name, path in pairs(self.options.get("resources", {})) do
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

  picker(opts, resources)
end

return resources_picker
