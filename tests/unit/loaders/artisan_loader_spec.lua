local nio = require("nio")
local a = nio.tests

describe("artisan loader test", function()
  local ApiResponse = require("laravel.dto.api_response")

  local function new_loader(api)
    local watcher = {}
    watcher.register = function(_, _, callback)
      watcher.callback = callback
    end
    local loader = require("laravel.loaders.artisan_loader"):new(api)
    loader.api = api
    loader.watcher = watcher
    return loader, watcher
  end

  a.it("loads artisan commands", function()
    local calls = 0
    local apiMock = CreateApiMock(function(command)
      calls = calls + 1
      assert.equals("artisan list --format=json", command)
    end, ApiResponse:new({ LoadStub("./tests/stubs/artisan_list.json") }, 0, {}))

    local cut = new_loader(apiMock)

    local commands, err = cut:load()
    local cached_commands, cached_err = cut:load()

    assert.is_nil(err)
    assert.is_table(commands)
    assert.equals(124, #commands)
    assert.equals(commands, cached_commands)
    assert.is_nil(cached_err)
    assert.equals(1, calls)
  end)

  a.it("reloads cached commands when a command definition changes", function()
    local calls = 0
    local apiMock = CreateApiMock(function()
      calls = calls + 1
    end, ApiResponse:new({ LoadStub("./tests/stubs/artisan_list.json") }, 0, {}))

    local cut, watcher = new_loader(apiMock)
    cut:load()
    watcher.callback()

    assert.equals(2, calls)
    assert.is_true(cut.loaded)
  end)

  a.it("returns error on api failure", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan list --format=json", command)
    end, ApiResponse:new({}, 1, { "API Error" }))

    local cut = new_loader(apiMock)

    local commands, err = cut:load()

    assert.table(commands)
    assert.equals(0, #commands)
    assert.equals("Failed to load artisan commands: API Error", err.message)
    assert.is_false(cut.loaded)
  end)
end)
