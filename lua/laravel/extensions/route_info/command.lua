local route_info_command = {}

function route_info_command:new(route_info)
  local instance = {
    service = route_info,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function route_info_command:commands()
  return { "route_info" }
end

function route_info_command:complete(argLead)
  return vim
    .iter({
      "show",
      "hide",
      "toggle",
    })
    :filter(function(name)
      return vim.startswith(name, argLead)
    end)
    :totable()
end

function route_info_command:handle(args)
  table.remove(args.fargs, 1)
  local action = args.fargs[1] or "toggle"
  local bufnr = vim.api.nvim_get_current_buf()

  if action == "toggle" then
    self.service:toggle(bufnr)
  elseif action == "show" then
    self.service:show(bufnr)
  elseif action == "hide" then
    self.service:hide(bufnr)
  end
end

return route_info_command
