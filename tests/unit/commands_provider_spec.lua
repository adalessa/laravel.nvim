local mock = require('luassert.mock')
local stub = require('luassert.stub')

local ApiResponse = require("laravel.dto.api_response")

describe("commands provider", function()
  it("Filters the hidden commands", function()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({
        [[{"commands":[{"name":"command1","hidden":false},{"name":"command2","hidden":true}]}]],
      }, 0, {}))
    end

    local cut = require("laravel.providers.commands"):new(api)

    cut:get(function(commands)
      assert.equals(1, #commands)
    end)
  end)

  it("returns empty list when commands is not returned as key", function()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({
        [[{"other":"data"}]],
      }, 0, {}))
    end

    local cut = require("laravel.providers.commands"):new(api)

    cut:get(function(commands)
      assert.equals(0, #commands)
    end)
  end)

  it("notify if the command failed", function()
    local api = {}
    function api:async(_, _, callback)
      callback(ApiResponse:new({}, 1, {"some error"}))
    end

    local notify = stub(vim, "notify", true)

    local cut = require("laravel.providers.commands"):new(api)
    cut:get(function()
    end)

    assert.stub(notify).was_called_with("some error", vim.log.levels.ERROR)
    mock.revert(notify)
  end)
end)
