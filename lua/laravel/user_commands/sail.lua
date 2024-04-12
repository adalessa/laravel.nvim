local run = require "laravel.run"
local create_user_command = require "laravel.user_commands.create_user_command"
local api = require "laravel.api"
local status = require "laravel.status"

return {
  setup = function()
    create_user_command("Sail", "sail", {
      up = function()
        api.async("sail", { "up", "-d" }, function(response)
          vim.notify("Sail up completed", vim.log.levels.INFO)
          status.refresh()
        end, function(errResponse)
          vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
        end)
      end,

      shell = function()
        run("sail", { "shell" }, {})
      end,

      ps = function()
        api.async("sail", { "ps" }, function(response)
          vim.notify(response:prettyContent(), vim.log.levels.INFO)
        end, function(errResponse)
          vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
        end)
      end,

      restart = function()
        api.async("sail", { "restart" }, function()
          vim.notify("Sail restart complete", vim.log.levels.INFO)
        end, function(errResponse)
          vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
        end)
        vim.notify("Sail restart starting", vim.log.levels.INFO)
      end,

      down = function()
        api.async("sail", { "down" }, function()
          vim.notify("Sail Down complete", vim.log.levels.INFO)
        end, function(errResponse)
          vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
        end)
      end,
    })
  end,
}
