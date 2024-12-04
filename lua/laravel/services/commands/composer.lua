local composer = {}

function composer:new(runner)
  local instance = {
    runner = runner,
    sub_commands = {
      "install",
      "require",
      "update",
      "remove",
    },
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function composer:commands()
  return { "composer" }
end

function composer:handle(args)
  table.remove(args.fargs, 1)
  if vim.tbl_isempty(args.fargs) then
    vim.ui.select({prompt = "Composer commands"}, self.sub_commands, function(selected)
      if selected == nil then
        return
      end

      self.runner:run("composer", selected)
    end)
    return
  end
  self.runner:run("composer", args.fargs)
end

function composer:complete(argLead, cmdLine)
  return vim
      .iter(self.sub_commands)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return composer
