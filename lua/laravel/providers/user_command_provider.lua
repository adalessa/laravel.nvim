local user_command_provider = {}

---@param app LaravelApp
function user_command_provider:register(app)
  vim.tbl_map(function(command)
    app:bindIf(command, command, { tags = { "command" } })
  end, require("laravel.commands"))

  app:bindIf("user_commands", function()
    return app:makeByTag("command")
  end)
end

---@param app LaravelApp
function user_command_provider:boot(app)
  local function get_command_names(command)
    if type(command.command) == "string" then
      return { command.command }
    elseif type(command.commands) == "table" then
      return command.commands
    end
    return command:commands()
  end

  vim.api.nvim_create_user_command("Laravel", function(args)
    if not app:isActive() then
      vim.notify("Laravel is not active", vim.log.levels.ERROR)
      return
    end

    if not args.fargs[1] then
      -- TODO maybe use snacks
      vim.ui.select(
        vim.iter(app("user_commands")):map(get_command_names):flatten():totable(),
        { prompt = "Laravel command: " },
        function(selected)
          if not selected then
            return
          end
          vim.api.nvim_command("Laravel " .. selected)
        end
      )
      return
    end

    local command = vim.iter(app("user_commands")):find(function(cmd)
      return vim.iter(get_command_names(cmd)):any(function(name)
        return vim.startswith(name, args.fargs[1])
      end)
    end)

    if command then
      -- if function handle exists use it
      if command.handle then
        return command:handle(args)
      end

      -- remove the command from the list
      table.remove(args.fargs, 1)
      local subcommand = args.fargs[1]
      if subcommand == "" or subcommand == "" or subcommand == nil then
        if not command.default then
          vim.notify("Sub command not provided and there is no default option set", vim.log.levels.ERROR)
          return
        end
        subcommand = command.default
      else
        -- remove the subcommand from the list
        table.remove(args.fargs, 1)
      end

      if not command[subcommand] then
        vim.notify("Command " .. subcommand .. " not found", vim.log.levels.ERROR)
        return
      end

      command[subcommand](command, args.fargs)
    end
  end, {
    nargs = "*",
    complete = app:whenActive(function(argLead, cmdLine)
      local fCmdLine = vim.split(cmdLine, " ")
      if #fCmdLine <= 2 then
        return vim
          .iter(app("user_commands"))
          :map(get_command_names)
          :flatten()
          :filter(function(subcommand)
            return vim.startswith(subcommand, argLead)
          end)
          :totable()
      elseif #fCmdLine == 3 then
        local command = vim.iter(app("user_commands")):find(function(cmd)
          return vim.iter(get_command_names(cmd)):any(function(name)
            return vim.startswith(name, fCmdLine[2])
          end)
        end)
        if command then
          if type(command.subCommands) == "table" then
            return vim
              .iter(command.subCommands)
              :filter(function(subcommand)
                return vim.startswith(subcommand, argLead)
              end)
              :totable()
          end

          return command:complete(argLead, cmdLine)
        end
      end

      return {}
    end),
  })
end

return user_command_provider
