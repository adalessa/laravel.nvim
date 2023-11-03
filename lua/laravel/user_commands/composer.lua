local notify = require "laravel.notify"
local create_user_command = require "laravel.user_commands.create_user_command"
local run = require "laravel.run"
local api = require "laravel.api"

local M = {}

function M.setup()
  return create_user_command("Composer", "composer", {
    update = function(cmd)
      table.insert(cmd, 1, "update")
      run("composer", cmd, {})
    end,

    install = function(cmd)
      table.insert(cmd, 1, "install")
      run("composer", cmd, {})
    end,

    ---@param cmd table
    require = function(cmd)
      table.insert(cmd, 1, "require")
      run("composer", cmd, {})
    end,

    remove = function(cmd)
      if #cmd == 0 then
        notify("composer.remove", { msg = "Need arguement for composer remove", level = "ERROR" })
        return
      end
      table.insert(cmd, 1, "remove")
      run("composer", cmd, {})
    end,

    ["dump-autoload"] = function()
      api.async("composer", { "dump-autoload" }, function()
        notify("composer.dump-autoload", { msg = "Completed", level = "INFO" })
      end)
    end,
  })
end

return M
