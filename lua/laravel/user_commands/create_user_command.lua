local run = require "laravel.run"

return function(name, executable, commands, opts)
  vim.api.nvim_create_user_command(
    name,
    function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return run(executable, args.fargs, {})
    end,
    vim.tbl_deep_extend("force", {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    }, opts or {})
  )
end
