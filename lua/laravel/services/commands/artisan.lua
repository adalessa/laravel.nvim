local artisan = {}

function artisan:new(runner, commands_provider)
  local instance = {
    runner = runner,
    commands_provider = commands_provider,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function artisan:commands()
  return { "artisan", "art" }
end

function artisan:handle(args)
  vim.print(args)
end

function artisan:complete(argLead, cmdLine)
  local commands = vim.iter({})

  self.commands_provider
      :get(function(cmds)
        commands = cmds
      end)
      :wait()

  vim.print(commands:totable())

  return commands
      :map(function(cmd)
        return cmd.name
      end)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return artisan
