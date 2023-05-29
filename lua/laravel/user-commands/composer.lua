local utils = require "laravel.utils"
local application = require "laravel.application"

local commands = {
  update = function(cmd)
    table.insert(cmd, 1, "update")
    application.run("composer", cmd, {})
  end,

  install = function()
    application.run("composer", { "install" }, {})
  end,

  ---@param cmd table
  require = function(cmd)
    table.insert(cmd, 1, "require")
    application.run("composer", cmd, {})
  end,

  remove = function(cmd)
    if #cmd == 0 then
      utils.notify("composer.remove", { msg = "Need arguement for composer remove", level = "ERROR" })
      return
    end
    table.insert(cmd, 1, "remove")
    application.run("composer", cmd, {})
  end,

  ["dump-autoload"] = function()
    application.run("composer", { "dump-autoload" }, {
      runner = "async",
      callback = function()
        utils.notify("composer.dump-autoload", { msg = "Completed", level = "INFO" })
      end,
    })
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Composer", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](args.fargs)
      end

      return application.run("composer", args.fargs, {})
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
