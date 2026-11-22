local nio = require("nio")
local a = nio.tests

describe("status", function()
  local health = require("laravel.core.health")
  local Error = require("laravel.utils.error")

  before_each(function()
    health.reset()
  end)

  a.it("does not fail when the api returns an error", function()
    local status = require("laravel.services.status"):new({
      run = function()
        return {}, Error:new("Environment is not available")
      end,
    })

    status:start()

    assert.equals("unknown", status:get("health"))
  end)

  a.it("keeps the health value in sync", function()
    local status = require("laravel.services.status"):new({
      run = function()
        return {}, Error:new("Environment is not available")
      end,
    })

    health.markUnavailable("service is not running")
    status:start()

    assert.equals("unavailable", status:get("health"))
  end)
end)
