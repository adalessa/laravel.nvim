local snacks = require("snacks").picker

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
    vim.notify("No resources defined in the config", vim.log.levels.WARN, {})
    return
  end

  snacks.pick(vim.tbl_extend("force", {
    title = "Resources",
    items = vim
      .iter(resources)
      :map(function(resource)
        return {
          value = resource,
          text = resource.name,
          file = resource.path,
        }
      end)
      :totable(),
    preview = "directory",
    confirm = function(picker, item)
      picker:close()
      if item then
        snacks.files({ cwd = item.value.path })
      end
    end,
  }, opts or {}))
end

return resources_picker
