local nio = require("nio")
local a = nio.tests

describe("artisan loader test", function()
  local ApiResponse = require("laravel.dto.api_response")
  a.it("loads artisan commands", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan list --format=json", command)
    end, ApiResponse:new({ LoadStub("./tests/stubs/artisan_list.json") }, 0, {}))

    local cut = require("laravel.loaders.artisan_loader"):new(apiMock)

    local commands, err = cut:load()

    assert.is_nil(err)
    assert.is_table(commands)
    assert.equals(124, #commands)
  end)

  a.it("returns error on api failure", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan list --format=json", command)
    end, ApiResponse:new({}, 1, { "API Error" }))

    local cut = require("laravel.loaders.artisan_loader"):new(apiMock)

    local commands, err = cut:load()

    assert.table(commands)
    assert.equals(0, #commands)
    assert.equals("Failed to load artisan commands: API Error", err.message)
  end)
end)
