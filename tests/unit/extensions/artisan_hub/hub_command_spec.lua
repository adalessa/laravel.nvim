local Error = require("laravel.utils.error")

describe("artisan hub", function()
  local function with_bindings(callback)
    local app = require("laravel.core.app")
    local original_notify = vim.notify
    local notifications = {}

    app:singleton("laravel.extensions.artisan_hub.commands", {
      { name = "Serve", cmd = "artisan serve" },
    })
    app:bind("laravel.services.command_generator", {
      generate = function()
        return false, Error:new("Executable 'vendor/bin/sail' not found")
      end,
    })

    vim.notify = function(message)
      table.insert(notifications, message)
    end

    local ok, err = pcall(callback, notifications)

    vim.notify = original_notify
    assert.is_true(ok, err)
  end

  it("does not build terminal commands when the environment is unavailable", function()
    with_bindings(function(notifications)
      local hub = require("laravel.extensions.artisan_hub.hub_command")

      hub:handle()
      vim.wait(100, function()
        return #notifications > 0
      end, 10)

      assert.matches("No commands available", notifications[1] or "")
    end)
  end)
end)
