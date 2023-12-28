local run = require "laravel.run"
local create_user_command = require "laravel.user_commands.create_user_command"

local M = {}

function M.setup()
  return create_user_command("Bun", "bun", {
    dev = function()
      run("bun", { "run", "dev" }, { runner = "persist" })
    end,
    build = function()
      run("bun", { "run", "build" })
    end,
  })
end

return M
