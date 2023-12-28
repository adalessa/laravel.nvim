local spy = require "luassert.spy"

describe("Artisan user command", function()
  local s = spy.new(function() end)
  package.loaded["laravel.run"] = s
  package.loaded["laravel.resources.is_resource"] = function()
    return false
  end
  require("laravel.user_commands.artisan").setup()

  it("require formats the parameter", function()
    vim.cmd [[Artisan --version]]
    assert.spy(s).was.called_with("artisan", { "--version" }, {})
  end)
end)
