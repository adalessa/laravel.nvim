describe("command generator", function()
  it("built the command from a single string", function()
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function(_, name)
        if name == "artisan" then
          return { "php", "artisan" }
        end
      end,
    })

    assert.same({ "php", "artisan", "migrate" }, cut:generate("artisan migrate"))
  end)

  it("built the command from a name with args", function()
    local cut = require("laravel.services.command_generator"):new({
      getExecutable = function(_, name)
        if name == "artisan" then
          return { "php", "artisan" }
        end
      end,
    })

    assert.same({ "php", "artisan", "migrate", "--force" }, cut:generate("artisan", { "migrate", "--force" }))
  end)
end)
