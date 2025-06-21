local Error = require("laravel.utils.error")

describe("Error", function()

  it("creates a new error instance with correct properties", function()
    local errorMessage = "An error occurred"
    local err = Error:new(errorMessage)

    assert.are.equal(errorMessage, err.message)
    assert.are_not.equals(nil, err.file)
    assert.are_not.equals(nil, err.line)
    assert.are.equals(nil, err.inner)
  end)

  it("wraps another error instance", function()
    local outerMessage = "Outer error"
    local innerMessage = "Inner error"

    local innerError = Error:new(innerMessage)
    local outerError = Error:new(outerMessage):wrap(innerError)

    assert.are.equal(innerError, outerError.inner)
    assert.are.equal(innerMessage, outerError.inner.message)
  end)

  it("generates a human-readable string representation", function()
    local errorMessage = "An error occurred"
    local err = Error:new(errorMessage)

    local details = err:toString()

    assert.is_true(details:find(errorMessage) ~= nil)
    assert.is_true(details:find("Occured at") ~= nil)
  end)

  it("includes inner error in string representation if wrapped", function()
    local outerMessage = "Outer error"
    local innerMessage = "Inner error"

    local innerError = Error:new(innerMessage)
    local outerError = Error:new(outerMessage):wrap(innerError)

    local details = outerError:toString()

    assert.is_true(details:find(innerMessage) ~= nil)
    assert.is_true(details:find("Caused by") ~= nil)
  end)

end)

