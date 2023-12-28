local run = require "laravel.run"
local environment = require "laravel.environment"
local create_user_command = require "laravel.user_commands.create_user_command"
local api = require "laravel.api"
local status = require "laravel.status"

local M = {}

function M.setup()
  if environment.get_executable "sail" == nil then
    return
  end

  create_user_command("Sail", "sail", {
    up = function()
      api.async(
        "sail",
        { "up", "-d" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Sail up completed", vim.log.levels.INFO)
            status.refresh()
          end
        end
      )
    end,

    shell = function()
      run("sail", { "shell" }, {})
    end,

    ps = function()
      api.async(
        "sail",
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
        "sail",
        { "restart" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Sail restart complete", vim.log.levels.INFO)
          end
        end
      )
      vim.notify("Sail restart starting", vim.log.levels.INFO)
    end,

    down = function()
      api.async(
        "sail",
        { "down" },
        ---@param response ApiResponse
        function(response)
          if response:failed() then
            vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
          else
            vim.notify("Sail Down complete", vim.log.levels.INFO)
          end
        end
      )
    end,
  })
end

return M
