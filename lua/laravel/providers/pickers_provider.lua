local nio = require("nio")
local notify = require("laravel.utils.notify")

---@type laravel.providers.provider
local pickers_provider = { name = "laravel.providers.pickers_provider" }

function pickers_provider.register(app)
  app:alias("pickers_manager", "laravel.managers.pickers_manager")
end

function pickers_provider.boot(app)
  Laravel.pickers = setmetatable({
    list = function()
      return vim.tbl_keys(app:make("pickers"):get_pickers())
    end,
  }, {
    __index = function(_, key)
      local pickers_manager = app:make("laravel.managers.pickers_manager")
      if not pickers_manager:exists(key) then
        error("Picker not found: " .. key .. " in provider " .. pickers_manager.name)
      end

      return setmetatable({}, {
        __call = function(_, opts)
          nio.run(function()
            if not app:isActive() then
              return notify.warn(
                string.format(
                  'Picker %s can not run since Laravel is not active. use `lua Laravel.commands.run("env:configure")`',
                  key
                )
              )
            end
            return pickers_manager:run(key, opts)
          end)
        end,
      })
    end,
  })
end

return pickers_provider
