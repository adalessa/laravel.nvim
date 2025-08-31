local snacks = require("snacks").picker

local resources_picker = {}

function resources_picker.run(opts, resources)
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
