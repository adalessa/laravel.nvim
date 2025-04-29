local route_info_command = {}

function route_info_command:new(route_info)
  local instance = {
    service = route_info,
    command = "route_info",
    subCommands = {
      "show",
      "hide",
      "toggle",
    },
    default = "toggle",
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function route_info_command:show()
  self.service:show(vim.api.nvim_get_current_buf())
end

function route_info_command:hide()
  self.service:hide(vim.api.nvim_get_current_buf())
end

function route_info_command:toggle()
  self.service:toggle(vim.api.nvim_get_current_buf())
end

return route_info_command
