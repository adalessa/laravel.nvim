local dispatcher = require("laravel.events.dispatcher")

local M = {
  name = "laravel.events.command_run",
}

---@param cmd string
---@param args string[]
---@param options table
---@param job_id integer
function M.dispatch(cmd, args, options, job_id)
  dispatcher.dispatch(M.name, {
    cmd = cmd,
    args = args,
    options = options,
    job_id = job_id,
  })
end

return M
