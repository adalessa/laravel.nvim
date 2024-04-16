local api = require("laravel.api")
local create_user_command = require("laravel.user_commands.create_user_command")
local status = require("laravel.status")

local M = {}

function M.setup()
  create_user_command("DockerCompose", "compose", {
    up = function()
      api.async("compose", { "up", "-d" }, function()
        vim.notify("Compose Up Completed", vim.log.levels.INFO)
        status.refresh()
      end, function(errResponse)
        vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
      end)
    end,

    ps = function()
      api.async("compose", { "ps" }, function(response)
        vim.notify(response:prettyContent(), vim.log.levels.INFO)
      end, function(errResponse)
        vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
      end)
    end,

    restart = function()
      api.async("compose", { "restart" }, function()
        vim.notify("Compose restart complete", vim.log.levels.INFO)
      end, function(errResponse)
        vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
      end)
      vim.notify("Compose restart starting", vim.log.levels.INFO)
    end,

    down = function()
      api.async("compose", { "down" }, function()
        vim.notify("Compose Down complete", vim.log.levels.INFO)
      end, function(errResponse)
        vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
      end)
    end,
  })
end

return M
