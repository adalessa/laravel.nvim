---@type LaravelApp
local app = require('laravel').app

local artisan = {}

function artisan:new(runner, cache_commands)
  local instance = {
    runner = runner,
    commands_provider = cache_commands,
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
    if app:has('artisan_picker') then
      app('artisan_picker'):run()
      return
    end
  end

  self.runner:run("artisan", args.fargs)
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
