local user_command_provider = {}

---@param app LaravelApp
function user_command_provider:register(app)
  app:bindIf("composer_command", "laravel.services.commands.composer")
  app:bindIf("artisan_command", "laravel.services.commands.artisan")
  app:bindIf("routes_command", "laravel.services.commands.routes")
  app:bindIf("make_command", "laravel.services.commands.make")
  app:bindIf("related_command", "laravel.services.commands.related")

  app:bindIf("user_commands", function()
    return {
      app("composer_command"),
      app("artisan_command"),
      app("routes_command"),
      app("make_command"),
      app("related_command"),
    }
  end)
end

---@param app LaravelApp
function user_command_provider:boot(app)
  vim.api.nvim_create_user_command("Laravel", function(args)
    if not app("env"):is_active() then
      vim.notify("Laravel is not active", vim.log.levels.ERROR)
    end

    local command = vim.iter(app("user_commands")):find(function(cmd)
      return vim.iter(cmd:commands()):any(function(name)
        return vim.startswith(name, args.fargs[1])
      end)
    end)

    if command then
      command:handle(args)
    end
  end, {
    nargs = "*",
    complete = function(argLead, cmdLine)
      if not app("env"):is_active() then
        return {}
      end

      local fCmdLine = vim.split(cmdLine, " ")
      if #fCmdLine <= 2 then
        return vim
            .iter(app("user_commands"))
            :map(function(command)
              return command:commands()
            end)
            :flatten()
            :filter(function(subcommand)
              return vim.startswith(subcommand, argLead)
            end)
            :totable()
      elseif #fCmdLine == 3 then
        local command = vim.iter(app("user_commands")):find(function(cmd)
          return vim.iter(cmd:commands()):any(function(name)
            return vim.startswith(name, fCmdLine[2])
          end)
        end)
        if command then
          return command:complete(argLead, cmdLine)
        end
      end

      return {}
    end,
  })
end

return user_command_provider
