local nio = require "nio"
local M = {}

function M.command(app, name, callback)
  app:bind(name .. "_command", function()
    return {
      command = name,
      handle = function(_, ...)
        local args = ...
        nio.run(function()
          callback(args)
        end)
      end,
    }
  end, { tags = { "command" } })
end

return M
