local nio = require("nio")
local notify = require("laravel.utils.notify")

local pickers_provider = { name = "laravel.providers.pickers_provider" }

---@param app laravel.core.app
function pickers_provider:register(app)
  app:alias("pickers_manager", "laravel.managers.pickers_manager")
end

---@param app laravel.core.app
function pickers_provider:boot(app)
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
              return notify.warn(string.format("Picker %s can not run since Laravel is not active", key))
            end
            return pickers_manager:run(key, opts)
          end)
        end,
      })
    end,
  })
end

return pickers_provider
