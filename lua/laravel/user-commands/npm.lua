local application = require "laravel.application"

local commands = {
  dev = function()
    return application.run("npm", { "run", "dev" }, { runner = "persist" })
  end,
  build = function()
    return application.run("npm", { "run", "build" }, {})
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Npm", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return application.run("npm", args.fargs, {})
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
