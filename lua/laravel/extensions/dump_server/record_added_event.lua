local dispatcher = require("laravel.events.dispatcher")

local M = {
  name = "laravel.events.dump_server_record_added",
}

function M.dispatch()
  dispatcher.dispatch(M.name, {})
end

return M
