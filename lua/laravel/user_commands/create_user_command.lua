local run = require "laravel.run"
local environment = require "laravel.environment"

return function(name, executable, commands, opts)
  if executable then
    if not environment.get_executable(executable) then
      return
    end
  end

  vim.api.nvim_create_user_command(
    name,
    function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](args.fargs)
      end

      if not command then
        vim.ui.select(vim.fn.sort(vim.tbl_keys(commands)), { prompt = name }, function(action)
          if not action then
            return
          end
          if commands[action] ~= nil then
            commands[action]()
          end
        end)

        return
      end

      if executable then
        return run(executable, args.fargs, {})
      end
    end,
    vim.tbl_deep_extend("force", {
      nargs = "*",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    }, opts or {})
  )
end
