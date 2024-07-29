local ApiResponse = require("laravel.dto.api_response")

describe("api response", function()
  it("can parse json response", function()
    local resp = ApiResponse:new({
      [[{"key":"value"}]],
    }, 0, {})

    assert.equals("value", resp:json().key)
  end)

  it("returns nil when a not valid json", function()
    local resp = ApiResponse:new({
      [[not a json]],
    }, 0, {})

    assert.equals(nil, resp:json())
  end)
end)
