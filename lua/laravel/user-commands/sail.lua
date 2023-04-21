local log = require("laravel.dev").log
local utils = require "laravel.utils"
local application = require "laravel.application"

local commands = {
  up = function()
    application.run("sail", { "up", "-d" }, {
      runner = "async",
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
    application.run("sail", { "shell" }, { runner = "terminal" })
  end,

  ps = function()
    application.run("sail", { "ps" }, {
      runner = "async",
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
    application.run("sail", { "restart" }, {
      runner = "async",
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
    application.run("sail", { "down" }, {
      runner = "async",
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
    if not application.has_command "sail" then
      return
    end

    vim.api.nvim_create_user_command("Sail", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return application.run("sail", args.fargs, {})
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
