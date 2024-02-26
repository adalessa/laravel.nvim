local create_user_command = require "laravel.user_commands.create_user_command"
local environment = require "laravel.environment"

local commands = {
  ["cache:clean"] = function()
    require("laravel.commands").list = {}
    require("laravel.routes").list = {}
    vim.notify("Laravel plugin cache cleaned", vim.log.levels.INFO)
  end,
  ["routes"] = require("telescope").extensions.laravel.routes,
  ["artisan"] = require("telescope").extensions.laravel.commands,
  ["test:watch"] = function()
    require "laravel.watch"("artisan", { "test" })
  end,
  ["related"] = require("telescope").extensions.laravel.related,
  ["history"] = require("telescope").extensions.laravel.history,
  ["make"] = require("telescope").extensions.laravel.make,
  ["recipes"] = require("laravel.recipes").run,
  ["commands"] = function()
    vim.cmd [[LaravelMyCommands]]
  end,
  ["view-finder"] = require("laravel.view_finder").auto,
  ["health"] = function()
    vim.cmd [[checkhealth laravel]]
  end,
}

return {
  setup = function()
    if environment.get_executable "sail" then
      commands["sail"] = function()
        vim.cmd [[Sail]]
      end
    end
    if environment.get_executable "compose" then
      commands["docker-compose"] = function()
        vim.cmd [[DockerCompose]]
      end
    end
    create_user_command("Laravel", nil, commands)
  end,
}
