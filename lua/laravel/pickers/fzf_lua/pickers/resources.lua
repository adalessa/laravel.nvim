local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_artisan
local notify       = require("laravel.utils.notify")

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

  local resource_names, resource_table = format_entry(resources)
  fzf_exec(resource_names, {
    actions = {
      ["default"] = function(selected)
        local resource = resource_table[selected[1]]
        require("fzf-lua").files({ cwd = resource.path })
      end,
    },
    prompt = "Resources > ",
    preview = function(selected)
      local resource = resource_table[selected[1]]

      local command = "ls -1 " .. resource.path
      local handle = io.popen(command)

      if not handle then
        return ""
      end

      local output = handle:read("*a")
      handle:close()

      if not output then
        return ""
      end

      return vim.split(output, "\n")
    end,
    fzf_opts = {
      ["--preview-window"] = "nohidden,70%",
    },
  })
end

return resources_picker
