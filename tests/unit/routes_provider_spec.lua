local mock = require('luassert.mock')
local stub = require('luassert.stub')

local ApiResponse = require("laravel.dto.api_response")

describe("routes provider", function()
  it("get empty list", function()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({
        [[{}]],
      }, 0, {}))
    end

    local cut = require("laravel.services.commands"):new(api)

    cut:get(function(routes)
      assert.equals(0, #routes)
    end)
  end)

  it("can return a mapped route", function ()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({
        [[
        [{"uri":"/","method":"GET","action":"Closure","middleware":"web","name":null}]
        ]],
      }, 0, {}))
    end

    local cut = require("laravel.providers.routes"):new(api)

    cut:get(function(routes)
      local route = routes[1]
      assert.equals("/", route.uri)
      assert.equals("GET", route.methods[1])
      assert.equals("Closure", route.action)
      assert.equals("web", route.middlewares)
      assert.equals(nil, route.name)
    end)
  end)

  it("notify if the command failed", function()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({}, 1, {"some error"}))
    end

    local notify = stub(vim, "notify", true)

    local cut = require("laravel.providers.routes"):new(api)
    cut:get(function()
    end)

    assert.stub(notify).was_called_with("some error", vim.log.levels.ERROR)
    mock.revert(notify)
  end)
end)
