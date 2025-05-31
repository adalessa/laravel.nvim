local command_center_provider = {}

---@param app laravel.core.app
function command_center_provider:register(app)
  app:addCommand("laravel.commands.command_center", function()
    return {
      signature = "command_center",
      description = "Open Command Center",
      handle = function()
        app("laravel.extensions.command_center.command_center"):open()
      end,
    }
  end)
end

---@param app laravel.core.app
function command_center_provider:boot(app) end

return command_center_provider
