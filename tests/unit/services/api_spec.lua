local nio = require("nio")
local Error = require("laravel.utils.error")
local health = require("laravel.core.health")

---@param command table
---@param err laravel.error
---@return laravel.services.api
local function new_api(command, err)
  local api = require("laravel.services.api"):new()
  api.command_generator = {
    generate = function()
      return command, err
    end,
  }
  api.log = {
    error = function() end,
  }

  return api
end

describe("api service", function()
  before_each(function()
    health.reset()
  end)

  it("includes the underlying process error when the command can not start", function()
    local original_run = nio.process.run
    nio.process.run = function()
      return nil, "ENOENT: no such file or directory"
    end

    local api = new_api({ "vendor/bin/sail", "php", "artisan", "tinker" })
    local ok, response, err = pcall(api.run, api, "artisan", { "tinker" })
    nio.process.run = original_run

    assert.is_true(ok)
    assert.same({}, response)
    assert.is_not_nil(err)
    assert.matches("Failed to run command", err.message)
    assert.matches("ENOENT: no such file or directory", err.message)
    assert.matches("vendor/bin/sail", err.message)
    assert.is_true(health.isUnavailable())
  end)

  it("marks the environment unavailable when the executable is missing", function()
    local executable_error = Error:new("Executable 'vendor/bin/sail' not found")
    local api = new_api(false, executable_error)

    local response, err = api:run("artisan", { "tinker" })

    assert.same({}, response)
    assert.is_not_nil(err)
    assert.matches("Executable 'vendor/bin/sail' not found", err:toString())
    assert.is_true(health.isUnavailable())
  end)

  it("does not change the health for a missing non application executable", function()
    local executable_error = Error:new("Executable 'rg' not found")
    local api = new_api(false, executable_error)

    local _, err = api:run("rg", { "TODO" })

    assert.is_not_nil(err)
    assert.is_false(health.isUnavailable())
  end)
end)
