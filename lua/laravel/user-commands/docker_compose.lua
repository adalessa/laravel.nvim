local log = require("laravel.dev").log
local utils = require "laravel.utils"
local application = require "laravel.application"

local commands = {
  up = function()
    application.run("compose", { "up", "-d" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("compose.up(): stdout", j:result())
          log.error("compose.up(): stderr", j:result())
          utils.notify("compose.up", { msg = "Error on Compose up", level = "ERROR" })

          return
        end
        utils.notify("compose.up", { msg = "Completed", level = "INFO" })
      end,
    })
  end,

  ps = function()
    application.run("compose", { "ps" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("compose.ps(): stdout", j:result())
          log.error("compose.ps(): stderr", j:result())
          utils.notify("compose.ps", { msg = "Failed to run compose up", level = "ERROR" })

          return
        end
        utils.notify("compose.ps", { raw = j:result(), level = "INFO" })
      end,
    })
  end,

  restart = function()
    application.run("compose", { "restart" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("compose.restart(): stdout", j:result())
          log.error("compose.restart(): stderr", j:result())
          utils.notify("compose.restart", { msg = "Failed to restart compose", level = "ERROR" })

          return
        end
        utils.notify("compose.restart", { msg = "compose restart complete", level = "INFO" })
      end,
    })
    utils.notify("compose.restart", { msg = "compose restart starting", level = "INFO" })
  end,

  down = function()
    application.run("compose", { "down" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("compose.down(): stdout", j:result())
          log.error("compose.down(): stderr", j:result())
          utils.notify("compose.down", { msg = "Failed to down compose", level = "ERROR" })

          return
        end
        utils.notify("compose.down", { msg = "compose Down complete", level = "INFO" })
      end,
    })
  end,
}

return {
  setup = function()
    if not application.has_command "compose" then
      return
    end

    vim.api.nvim_create_user_command("DockerCompose", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      application.run("compose", args.fargs, {})
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
