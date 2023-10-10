describe("environment", function()
  it("generates environment", function()
    local config = require "laravel.config"
    local environment = require "laravel.environment"
    local user_commands = require "laravel.user_commands"
    local route_info = require "laravel.route_info"
    local env = {}
    config.setup {}
    config.options.environment.resolver = function(environments)
      return env
    end
    local spy = require "luassert.spy"
    spy.on(config.options.environment, "resolver")
    environment.setup()
    assert.spy(config.options.environment.resolver).was.called_with(config.options.environment.environments)
    assert.are.same(env, environment.environment)
    assert.spy(user_commands.setup).was.called()
    assert.spy(route_info.setup).was.called()
  end)
end)
