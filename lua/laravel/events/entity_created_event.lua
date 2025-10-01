local dispatcher = require("laravel.events.dispatcher")

local M = {
  name = "laravel.events.entity_created",
}

---@param entity string
function M.dispatch(entity)
  dispatcher.dispatch(M.name, {
    entity = entity,
  })
end

return M
