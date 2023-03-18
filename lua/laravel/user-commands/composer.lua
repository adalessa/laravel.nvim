local utils = require("laravel.utils")

local commands = {
  update = function(library)
    local cmd = { "update" }
    if library ~= nil then
      table.insert(cmd, library)
    end
    require("laravel.composer").run(cmd)
  end,

  install = function()
    require("laravel.composer").run({ "install" })
  end,

  require = function(library)
    local cmd = { "require" }
    if library ~= nil then
      table.insert(cmd, library)
    end
    require("laravel.composer").run(cmd, "terminal")
  end,

  remove = function(library)
    if library == nil then
      utils.notify("composer.remove", { msg = "Need arguement for composer remove", level = "ERROR" })
      return
    end
    require("laravel.composer").run({ "remove", library })
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
        return commands[command](unpack(args.fargs))
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
