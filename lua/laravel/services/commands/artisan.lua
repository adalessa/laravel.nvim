local artisan = {}

function artisan:new(runner, cache_commands, artisan_picker)
  local instance = {
    runner = runner,
    commands_provider = cache_commands,
    picker = artisan_picker,
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
    self.artisan_picker()
  else
    self.runner:run("artisan", args.fargs)
  end
end

function artisan:complete(argLead)
  local commands = vim.iter({})

  self.commands_provider
      :get(function(cmds)
        commands = cmds
      end)
      :wait()

  return vim
      .iter(commands)
      :map(function(cmd)
        return cmd.name
      end)
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return artisan
