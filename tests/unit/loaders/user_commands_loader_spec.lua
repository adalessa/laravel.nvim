describe("user commands loader", function()
  it("convert from configuration to commands", function()
    local optionsMock = {}
    function optionsMock:get(key, default)
      assert.equals("user_commands", key)
      assert.same({}, default)

      return {
        artisan = {
          ["db:fresh"] = {
            cmd = { "migrate:fresh", "--seed" },
            desc = "Re-creates the db and seed's it",
          },
        },
        npm = {
          build = {
            cmd = { "run", "build" },
            desc = "Builds the javascript assets",
          },
          dev = {
            cmd = { "run", "dev" },
            desc = "Builds the javascript assets",
          },
        },
        composer = {
          autoload = {
            cmd = { "dump-autoload" },
            desc = "Dumps the composer autoload",
          },
        },
      }
    end

    local cut = require("laravel.loaders.user_commands_loader"):new(optionsMock)

    cut:load(function(commands)
      assert.equals(4, #commands)
    end)
  end)
end)
