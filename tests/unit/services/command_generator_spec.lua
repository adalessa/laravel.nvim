describe("command generator", function()
  it("built the command from a single string", function()
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function(_, name)
        if name == "artisan" then
          return { "php", "artisan" }
        end
      end,
    })

    assert.same({ "php", "artisan", "migrate" }, cut:generate("artisan migrate"))
  end)

  it("built the command from a name with args", function()
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function(_, name)
        if name == "artisan" then
          return { "php", "artisan" }
        end
      end,
    })

    assert.same({ "php", "artisan", "migrate", "--force" }, cut:generate("artisan", { "migrate", "--force" }))
  end)

  it("returns the executable error instead of dropping the executable", function()
    local Error = require("laravel.utils.error")
    local executable_error = Error:new("Executable 'vendor/bin/sail' not found")
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function()
        -- env:getExecutable returns an empty table plus the error on failure.
        return {}, executable_error
      end,
    })

    local command, err = cut:generate("artisan", { "tinker", "--execute", "1" })

    assert.is_false(command)
    assert.equals(executable_error, err)
  end)

  it("returns false when the executable is not configured", function()
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function()
        return nil
      end,
    })

    local command = cut:generate("artisan", { "tinker" })

    assert.is_false(command)
  end)
end)
