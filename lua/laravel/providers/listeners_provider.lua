local utils = require("laravel.utils")
local provider = { name = "laravel.providers.listeners_provider" }

function provider:register(app)
  vim
    .iter(utils.get_modules({
      "lua/laravel/listeners/*.lua",
      "lua/laravel/extensions/**/*_listener.lua",
    }))
    :each(function(listener)
      app:bindIf(listener, listener, { tags = { "listener" } })
    end)

  app:bindIf("laravel.listeners", function()
    return app:makeByTag("listener")
  end)
end

function provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.listeners", {})

  local mapped = {}

  for _, listener in ipairs(app("laravel.listeners")) do
    local event = listener.event.name
    if not mapped[event] then
      mapped[event] = {}
    end
    table.insert(mapped[event], listener)
  end

  for _, mapped_listeners in pairs(mapped) do
    local event = mapped_listeners[1].event.name
    vim.api.nvim_create_autocmd({ "User" }, {
      group = group,
      pattern = { event },
      callback = function(ev)
        for _, listener in ipairs(mapped_listeners) do
          pcall(listener.handle, ev.data, app)
        end
      end,
    })
  end
end

return provider
