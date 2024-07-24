local composer = {}

function composer:new(runner)
  local instance = {
    runner = runner,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function composer:commands()
  return { "composer" }
end

function composer:handle(args)
  vim.print(args)
end

function composer:complete(argLead, cmdLine)
  return vim
      .iter({
        "install",
        "require",
        "udpate",
        "remove",
      })
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return composer
