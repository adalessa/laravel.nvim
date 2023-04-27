local log = require("laravel.dev").log
local utils = require "laravel.utils"

local commands = {
  up = function()
    require("laravel.container").run({ "up", "-d" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("env.up(): stdout", j:result())
          log.error("env.up(): stderr", j:result())
          utils.notify("env.up", { msg = "Error on Env up", level = "ERROR" })

          return
        end
        utils.notify("env.up", { msg = "Completed", level = "INFO" })
      end,
    })
  end,
  shell = function()
    require("laravel.container").run({ "shell" }, "terminal")
  end,

  ps = function()
    require("laravel.container").run({ "ps" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("env.ps(): stdout", j:result())
          log.error("env.ps(): stderr", j:result())
          utils.notify("env.ps", { msg = "Failed to run Env up", level = "ERROR" })

          return
        end
        utils.notify("env.ps", { raw = j:result(), level = "INFO" })
      end,
    })
  end,

  restart = function()
    require("laravel.container").run({ "restart" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("env.restart(): stdout", j:result())
          log.error("env.restart(): stderr", j:result())
          utils.notify("env.restart", { msg = "Failed to restart Env", level = "ERROR" })

          return
        end
        utils.notify("env.restart", { msg = "Env restart complete", level = "INFO" })
      end,
    })
    utils.notify("env.restart", { msg = "Env restart starting", level = "INFO" })
  end,
  down = function()
    require("laravel.container").run({ "down" }, "async", {
      callback = function(j, exit_code)
        if exit_code ~= 0 then
          log.error("env.down(): stdout", j:result())
          log.error("env.down(): stderr", j:result())
          utils.notify("env.down", { msg = "Failed to down Env", level = "ERROR" })

          return
        end
        utils.notify("env.down", { msg = "Env Down complete", level = "INFO" })
      end,
    })
  end,
}

return {
  setup = function()
    vim.api.nvim_create_user_command("Container", function(args)
      local command = args.fargs[1]
      if commands[command] ~= nil then
        table.remove(args.fargs, 1)
        return commands[command](unpack(args.fargs))
      end

      return require("laravel.container").run(args.fargs)
    end, {
      nargs = "+",
      complete = function()
        return vim.tbl_keys(commands)
      end,
    })
  end,
}
