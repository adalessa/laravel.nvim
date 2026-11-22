local env_service = require("laravel.core.env")

describe("environment prompt", function()
  local function with_plugin_stubs(callback)
    local original_readable = vim.fn.filereadable
    local original_select = vim.ui.select

    vim.fn.filereadable = function()
      return 1
    end

    local ok, result = pcall(callback)

    vim.fn.filereadable = original_readable
    vim.ui.select = original_select

    assert.is_true(ok)
    return result
  end

  local function options(overrides)
    overrides = overrides or {}
    local values = {
      path = nil,
      ["environments.ask_on_boot"] = true,
      ["environments.definitions"] = { { name = "local" } },
    }

    for key, value in pairs(overrides) do
      values[key] = value
    end

    return {
      get = function(key)
        return values[key]
      end,
      set = function()
        return true
      end,
    }
  end

  it("does not open another prompt while one is pending", function()
    with_plugin_stubs(function()
      local prompts = 0
      local pending
      vim.ui.select = function(_, _, callback)
        prompts = prompts + 1
        pending = callback
      end

      local cut = env_service:new()
      cut.options = options()

      cut:boot()
      cut:boot()

      assert.equals(1, prompts)

      pending(nil)

      cut:boot()
      assert.equals(2, prompts)
    end)
  end)
end)

describe("environment executables", function()
  it("does not reuse an executable cached by another environment", function()
    local original_executable = vim.fn.executable
    vim.fn.executable = function()
      return 1
    end

    local ok, err = pcall(function()
      local Environment = require("laravel.dto.environment")
      local sail = Environment:new({ name = "sail", map = { php = { "vendor/bin/sail", "php" } } })
      local local_env = Environment:new({ name = "local" })

      assert.same({ "vendor/bin/sail", "php" }, sail:executable("php"))
      assert.same({ "php" }, local_env:executable("php"))
    end)

    vim.fn.executable = original_executable
    assert.is_true(ok, err)
  end)
end)
