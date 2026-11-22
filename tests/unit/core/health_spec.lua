local health = require("laravel.core.health")

describe("health", function()
  before_each(function()
    health.reset()
  end)

  it("starts in an unknown state", function()
    assert.equals("unknown", health.getStatus())
    assert.is_false(health.isUnavailable())
    assert.is_false(health.isBroken())
    assert.is_false(health.shouldSkip())
    assert.is_nil(health.getError())
  end)

  it("marks a successful command as healthy", function()
    health.markHealthy()

    assert.equals("healthy", health.getStatus())
    assert.is_nil(health.getError())
    assert.is_false(health.shouldSkip())
  end)

  it("detects an unavailable environment", function()
    health.recordFailure('service "together_api" is not running')

    assert.equals("unavailable", health.getStatus())
    assert.is_true(health.isUnavailable())
    assert.is_true(health.shouldSkip())
    assert.equals('service "together_api" is not running', health.getError())
  end)

  it("detects php errors as a broken application", function()
    health.recordFailure("PHP Parse error: syntax error, unexpected token")

    assert.equals("broken", health.getStatus())
    assert.is_true(health.isBroken())
    assert.is_false(health.shouldSkip())
  end)

  it("does not replace an unavailable environment with a broken state", function()
    health.markUnavailable("service is not running")
    health.recordFailure("PHP Fatal error: something else")

    assert.equals("unavailable", health.getStatus())
  end)

  it("recovers after a successful command", function()
    health.recordFailure("service is not running")
    health.markHealthy()

    assert.equals("healthy", health.getStatus())
    assert.is_false(health.shouldSkip())
    assert.is_nil(health.getError())
  end)

  it("resets the state", function()
    health.markUnavailable("service is not running")
    health.reset()

    assert.equals("unknown", health.getStatus())
    assert.is_nil(health.getError())
    assert.is_false(health.shouldSkip())
  end)
end)
