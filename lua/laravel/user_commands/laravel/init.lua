local notify = require "laravel.notify"
local run = require "laravel.run"

local commands = {
  ["cache:clean"] = function()
    require("laravel.commands").list = {}
    require("laravel.routes").list = {}
    notify("laravel.cache:clean", { msg = "Cache cleaned", level = "INFO" })
  end,
  ["routes"] = function()
    return require("telescope").extensions.laravel.routes()
  end,
  ["artisan"] = function()
    return require("telescope").extensions.laravel.commands()
  end,
  ["test:watch"] = function()
    return run("artisan", { "test" }, { runner = "watch" })
  end,
  ["related"] = function()
    return require("telescope").extensions.laravel.related()
  end,
  ["info"] = require "laravel.user_commands.laravel.info",
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Laravel", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      notify("laravel", { msg = "Unkown command", level = "ERROR" })
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
