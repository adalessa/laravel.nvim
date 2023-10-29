describe("Environment Resolver test", function()
  before_each(function() end)

  it("resolve by the environment variable", function()
    package.loaded["laravel.environment.get_env"] = function()
      return "test-environment"
    end
    local resolver = require "laravel.environment.resolver"
    local test_resolver = resolver(true, false, nil)
    local environment = test_resolver { ["test-environment"] = "test-environment" }
    assert.equals("test-environment", environment)
  end)
end)
