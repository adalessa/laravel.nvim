local nio = require("nio")
local a = nio.tests

describe("code service", function()
  local app = require("laravel.core.app")

  local ApiResponse = require("laravel.dto.api_response")

  local function new_service(response)
    local service = require("laravel.services.code"):new()
    service.make_php_file = function()
      return "/tmp/laravel-nvim-code.php"
    end
    service.api = {
      run = function()
        return response
      end,
    }

    return service
  end

  it("returns an error when php stops before producing output", function()
    -- A parse error in a model aborts php before the output markers are printed.
    local service = new_service(ApiResponse:new({ "PHP Parse error: syntax error" }, 0, {}))

    local ok, result, err = pcall(service.run, service, "echo 'unreachable';")

    assert.is_true(ok)
    assert.same({}, result)
    assert.is_not_nil(err)
    assert.matches("Invalid or empty PHP output", err.message)
  end)

  it("returns an error when php output is not valid json", function()
    local service = new_service(
      ApiResponse:new({ "__NEOVIM_LARAVEL_START_OUTPUT__", "not json", "__NEOVIM_LARAVEL_END_OUTPUT__" }, 0, {})
    )

    local ok, result, err = pcall(service.run, service, "echo 'not json';")

    assert.is_true(ok)
    assert.same({}, result)
    assert.is_not_nil(err)
    assert.matches("Could not parse PHP output", err.message)
  end)

  a.it("generates the php file from a fast event context", function()
    local cwd = vim.uv.cwd()
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp, "p")

    app:bind("laravel.services.code.pre_script", function()
      return ""
    end)

    local cut = require("laravel.services.code"):new()
    require("laravel.php-templates.tinker")
    vim.uv.chdir(tmp)

    local path
    local result

    local timer = vim.uv.new_timer()
    timer:start(0, 0, function()
      local ok, value = pcall(cut.make_php_file, cut, "echo 1;")
      result = { ok = ok, value = value }
      path = value
    end)

    vim.wait(1000, function()
      return result ~= nil
    end, 10)

    timer:stop()
    timer:close()

    assert.is_true(result.ok)
    assert.is_not_nil(path)

    local full = tmp .. "/" .. path
    vim.uv.chdir(cwd)

    assert.is_truthy(vim.uv.fs_stat(full))

    local content = table.concat(vim.fn.readfile(full), "\n")
    assert.is_truthy(content:find("<?php", 1, true))

    vim.fn.delete(tmp, "rf")
  end)
end)
