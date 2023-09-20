local run = require "laravel.run"
local create_user_command = require "laravel.user_commands.create_user_command"

local M = {}

function M.setup()
  return create_user_command("Yarn", "yarn", {
    dev = function()
      run("yarn", { "run", "dev" }, { runner = "persist" })
    end,
    build = function()
      run("yarn", { "run", "build" })
    end,
  })
end

return M
