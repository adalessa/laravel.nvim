local nio = require("nio")
local a = nio.tests

describe("routes loader test", function()
  local ApiResponse = require("laravel.dto.api_response")

  a.it("loads routes", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan route:list --json", command)
    end, ApiResponse:new({ LoadStub("./tests/stubs/routes_list.json") }, 0, {}))

    local cut = require("laravel.loaders.routes_loader"):new(apiMock)

    local routes, err = cut:load()

    assert.is_nil(err)
    assert.is_table(routes)
    assert.equals(38, #routes)
  end)

  a.it("returns error on api failure", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan route:list --json", command)
    end, ApiResponse:new({}, 1, { "API Error" }))

    local cut = require("laravel.loaders.routes_loader"):new(apiMock)

    local routes, err = cut:load()

    assert.table(routes)
    assert.equals(0, #routes)
    assert.is_string(err)
    assert.equals("Failed to load routes: API Error", err)
  end)
end)

