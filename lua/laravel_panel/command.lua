local panel_command = {}

function panel_command:new(panel)
  local instance = {
    panel = panel,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function panel_command:commands()
  return { "panel" }
end

function panel_command:handle(args)
  self.panel:toggle(args.fargs[2])
end

function panel_command:complete(argLead)
  return vim
      .iter(self.panel.modules)
      :map(function(module)
        return module.text
      end)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return panel_command
