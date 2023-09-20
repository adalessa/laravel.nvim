local run = require "laravel.run"
local notify = require "laravel.notify"
local environment = require "laravel.environment"
local create_user_command = require "laravel.user_commands.create_user_command"

local M = {}

function M.setup()
  if environment.get_executable "sail" == nil then
    return
  end

  create_user_command("Sail", "sail", {
    up = function()
      run("sail", { "up", "-d" }, {
        runner = "async",
        callback = function(j, exit_code)
          if exit_code ~= 0 then
            notify("sail.up", { msg = string.format("Error on Sail up. %s", vim.inspect(j:result())), level = "ERROR" })

            return
          end
          notify("sail.up", { msg = "Completed", level = "INFO" })
        end,
      })
    end,

    shell = function()
      run("sail", { "shell" }, {})
    end,

    ps = function()
      run("sail", { "ps" }, {
        runner = "async",
        callback = function(j, exit_code)
          if exit_code ~= 0 then
            notify("sail.ps", { msg = "Failed to run Sail up", level = "ERROR" })

            return
          end
          notify("sail.ps", { raw = vim.fn.join(j:result(), "\n"), level = "INFO" })
        end,
      })
    end,

    restart = function()
      run("sail", { "restart" }, {
        runner = "async",
        callback = function(j, exit_code)
          if exit_code ~= 0 then
            notify(
              "sail.restart",
              { msg = string.format("Failed to restart Sail. %s", vim.inspect(j:result())), level = "ERROR" }
            )

            return
          end
          notify("sail.restart", { msg = "Sail restart complete", level = "INFO" })
        end,
      })
      notify("sail.restart", { msg = "Sail restart starting", level = "INFO" })
    end,

    down = function()
      run("sail", { "down" }, {
        runner = "async",
        callback = function(j, exit_code)
          if exit_code ~= 0 then
            notify(
              "sail.down",
              { msg = string.format("Failed to down Sail. Error: %s", vim.inspect(j:result())), level = "ERROR" }
            )

            return
          end
          notify("sail.down", { msg = "Sail Down complete", level = "INFO" })
        end,
      })
    end,
  })
end

return M
