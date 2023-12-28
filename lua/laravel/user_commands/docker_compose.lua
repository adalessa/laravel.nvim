local create_user_command = require "laravel.user_commands.create_user_command"
local api = require "laravel.api"
local status = require "laravel.status"

local M = {}

function M.setup()
  create_user_command("DockerCompose", "compose", {
    up = function()
      api.async(
        "compose",
        { "up", "-d" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Compose Up Completed", vim.log.levels.INFO)
            status.refresh()
          end
        end
      )
    end,

    ps = function()
      api.async(
        "compose",
        { "ps" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify(response:prettyContent(), vim.log.levels.INFO)
          end
        end
      )
    end,

    restart = function()
      api.async(
        "compose",
        { "restart" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Compose restart complete", vim.log.levels.INFO)
          end
        end
      )
      vim.notify("Compose restart starting", vim.log.levels.INFO)
    end,

    down = function()
      api.async(
        "compose",
        { "down" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Compose Down complete", vim.log.levels.INFO)
          end
        end
      )
    end,
  })
end

return M
