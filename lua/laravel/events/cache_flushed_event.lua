local dispatcher = require("laravel.events.dispatcher")

local M = {
  name = "laravel.events.cache_flushed",
}

function M.dispatch()
  dispatcher.dispatch(M.name, {})
end

return M
