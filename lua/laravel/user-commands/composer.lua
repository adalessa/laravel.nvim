local utils = require "laravel.utils"

local commands = {
  update = function(cmd)
    table.insert(cmd, 1, "update")
    require("laravel.composer").run(cmd)
  end,

  install = function()
    require("laravel.composer").run { "install" }
  end,

  ---@param cmd table
  require = function(cmd)
    table.insert(cmd, 1, "require")
    require("laravel.composer").run(cmd, "terminal")
  end,

  remove = function(cmd)
    if #cmd == 0 then
      utils.notify("composer.remove", { msg = "Need arguement for composer remove", level = "ERROR" })
      return
    end
    table.insert(cmd, 1, "remove")
    require("laravel.composer").run(cmd)
  end,

  ["dump-autoload"] = function()
    require("laravel.composer").run({ "dump-autoload" }, "async", {
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

      return require("laravel.composer").run(args.fargs)
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
