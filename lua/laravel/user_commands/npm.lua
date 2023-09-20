local run = require "laravel.run"
local create_user_command = require "laravel.user_commands.create_user_command"

local M = {}

function M.setup()
  return create_user_command("Npm", 'npm', {
    dev = function()
      run("npm", { "run", "dev" }, { runner = "persist" })
    end,
    build = function()
      run("npm", { "run", "build" })
    end,
  })
end

return M
