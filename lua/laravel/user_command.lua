local app = require("laravel.app")

vim.api.nvim_create_user_command("Laravel", function(args)
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
