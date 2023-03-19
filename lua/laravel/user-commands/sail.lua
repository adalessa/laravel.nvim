local log = require("laravel.dev").log
local utils = require "laravel.utils"

local commands = {
  up = function()
    require("laravel.sail").run({ "up", "-d" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("sail.up(): stdout", j:result())
          log.error("sail.up(): stderr", j:result())
          utils.notify("sail.up", { msg = "Error on Sail up", level = "ERROR" })

          return
        end
        utils.notify("sail.up", { msg = "Completed", level = "INFO" })
      end,
    })
  end,
  shell = function()
    require("laravel.sail").run({ "shell" }, "terminal")
  end,

  ps = function()
    require("laravel.sail").run({ "ps" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("sail.ps(): stdout", j:result())
          log.error("sail.ps(): stderr", j:result())
          utils.notify("sail.ps", { msg = "Failed to run Sail up", level = "ERROR" })

          return
        end
        utils.notify("sail.ps", { raw = j:result(), level = "INFO" })
      end,
    })
  end,

  restart = function()
    require("laravel.sail").run({ "restart" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("sail.restart(): stdout", j:result())
          log.error("sail.restart(): stderr", j:result())
          utils.notify("sail.restart", { msg = "Failed to restart Sail", level = "ERROR" })

          return
        end
        utils.notify("sail.restart", { msg = "Sail restart complete", level = "INFO" })
      end,
    })
    utils.notify("sail.restart", { msg = "Sail restart starting", level = "INFO" })
  end,
  down = function()
    require("laravel.sail").run({ "down" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("sail.down(): stdout", j:result())
          log.error("sail.down(): stderr", j:result())
          utils.notify("sail.down", { msg = "Failed to down Sail", level = "ERROR" })

          return
        end
        utils.notify("sail.down", { msg = "Sail Down complete", level = "INFO" })
      end,
    })
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Sail", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return require("laravel.sail").run(args.fargs)
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
