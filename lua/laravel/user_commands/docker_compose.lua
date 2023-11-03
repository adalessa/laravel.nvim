local notify = require "laravel.notify"
local environment = require "laravel.environment"
local create_user_command = require "laravel.user_commands.create_user_command"
local api = require "laravel.api"

local M = {}

function M.setup()
  if environment.get_executable "compose" == nil then
    return
  end

  create_user_command("DockerCompose", "compose", {
    up = function()
      api.async("compose", { "up", "-d" }, function(j, exit_code)
        if exit_code ~= 0 then
          notify(
            "compose.up",
            { msg = string.format("Error on Compose up. %s", vim.inspection(j:result())), level = "ERROR" }
          )

          return
        end
        notify("compose.up", { msg = "Completed", level = "INFO" })
      end)
    end,

    ps = function()
      api.async("compose", { "ps" }, function(j, exit_code)
        if exit_code ~= 0 then
          notify("compose.ps", { msg = "Failed to run compose up", level = "ERROR" })

          return
        end
        notify("compose.ps", { raw = j:result(), level = "INFO" })
      end)
    end,

    restart = function()
      api.async("compose", { "restart" }, function(j, exit_code)
        if exit_code ~= 0 then
          notify(
            "compose.restart",
            { msg = string.format("Failed to restart compose. %s", vim.inspect(j:result())), level = "ERROR" }
          )

          return
        end
        notify("compose.restart", { msg = "compose restart complete", level = "INFO" })
      end)
      notify("compose.restart", { msg = "compose restart starting", level = "INFO" })
    end,

    down = function()
      api.async("compose", { "down" }, function(j, exit_code)
        if exit_code ~= 0 then
          notify(
            "compose.down",
            { msg = string.format("Failed to down compose. %s", vim.inspect(j:result())), level = "ERROR" }
          )

          return
        end
        notify("compose.down", { msg = "compose Down complete", level = "INFO" })
      end)
    end,
  })
end

return M
