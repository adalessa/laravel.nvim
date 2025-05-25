local nio = require("nio")
local a = nio.tests

describe("config service test", function()
  local config = require("laravel.services.config")

  a.it("returns the entire configs table when no property is provided", function()
    config.set("some.config", "value")
    assert.are.same(config(), { some = { config = "value" } })
  end)

  a.it("gets a configuration value", function()
    config.set("some.config", "value")
    assert.are.equal(config("some.config"), "value")
  end)

  a.it("returns the default value when the property does not exist", function()
    assert.are.equal(config("nonexistent.config", "default"), "default")
  end)

  a.it("sets a configuration value using a table", function()
    config.set({ another = { config = "value" } })
    assert.are.same(config(), { some = { config = "value" }, another = { config = "value" } })
  end)
end)
