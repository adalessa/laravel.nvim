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
  table.remove(args.fargs, 1)
  if vim.tbl_isempty(args.fargs) then
    require("telescope").extensions.laravel.artisan()
  else
    self.runner:run('artisan', args.fargs)
  end
end

function artisan:complete(argLead, cmdLine)
  local commands = vim.iter({})

  self.commands_provider
      :get(function(cmds)
        commands = cmds
      end)
      :wait()

  return vim.iter(commands)
      :map(function(cmd)
        return cmd.name
      end)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return artisan
