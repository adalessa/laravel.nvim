local nio = require("nio")
local a = nio.tests

describe("routes loader test", function()
  local ApiResponse = require("laravel.dto.api_response")

  local function new_loader(api)
    local watcher = {}
    watcher.register = function(_, _, callback)
      watcher.callback = callback
    end
    local loader = require("laravel.loaders.routes_loader"):new(api)
    loader.api = api
    loader.options = {
      get = function(_, default)
        return default
      end,
    }
    loader.mapper = require("laravel.mappers.route_mapper")
    loader.watcher = watcher
    return loader, watcher
  end

  a.it("loads routes", function()
    local calls = 0
    local apiMock = CreateApiMock(function(command)
      calls = calls + 1
      assert.equals("artisan route:list --json", command)
    end, ApiResponse:new({ LoadStub("./tests/stubs/routes_list.json") }, 0, {}))

    local cut = new_loader(apiMock)

    local routes, err = cut:load()
    local cached_routes, cached_err = cut:load()

    assert.is_nil(err)
    assert.is_table(routes)
    assert.equals(38, #routes)
    assert.equals(routes, cached_routes)
    assert.is_nil(cached_err)
    assert.equals(1, calls)
  end)

  a.it("reloads cached routes when a route file changes", function()
    local calls = 0
    local apiMock = CreateApiMock(function()
      calls = calls + 1
    end, ApiResponse:new({ LoadStub("./tests/stubs/routes_list.json") }, 0, {}))

    local cut, watcher = new_loader(apiMock)
    cut:load()
    watcher.callback()

    assert.equals(2, calls)
    assert.is_true(cut.loaded)
  end)

  a.it("returns error on api failure", function()
    local apiMock = CreateApiMock(function(command)
      assert.equals("artisan route:list --json", command)
    end, ApiResponse:new({}, 1, { "API Error" }))

    local cut = new_loader(apiMock)

    local routes, err = cut:load()

    assert.table(routes)
    assert.equals(0, #routes)
    assert.equals("Failed to load routes API Error", err.message)
    assert.is_false(cut.loaded)
  end)
end)
