local app = require("laravel.core.app")

return {
  signature = "hub:add",
  description = "Add Command to the hub",
  handle = function()
    vim.ui.input({ prompt = "Name: " }, function(name)
      if not name or name == "" then
        return
      end
      -- being able from a command to add to hub

      vim.ui.input({ prompt = "Enter command: " }, function(input)
        if not input or input == "" then
          return
        end

        app("laravel.extensions.artisan_hub.hub_command"):add(name, input)
      end)
    end)
  end,
}
