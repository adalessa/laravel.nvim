local nio = require("nio")
local a = nio.tests

describe("user commands loader test", function()
  a.it("it parses the commands", function()
    local cut = require("laravel.loaders.user_commands_loader"):new(
      {
        get = function(_, key, default)
          if key == "user_commands" then
            return {
              artisan = {
                list = {
                  cmd = "artisan list",
                  desc = "List all artisan commands",
                },
                migrate = {
                  cmd = "artisan migrate",
                  desc = "Run the database migrations",
                },
              },
            }
          end
          return default
        end,
      }
    )

    local commands = cut:load()
    assert.is_table(commands)
    assert.equals(2, #commands)
  end)
end)
