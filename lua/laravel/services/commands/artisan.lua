local artisan = {}

function artisan:new(run, commands_provider)
  local instance = {
    run = run,
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
  table.remove(args.fargs, 1)
  self.run('artisan', args.fargs)
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
