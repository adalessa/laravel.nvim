local M = {}

function M.command(app, name, callback)
  app:bind(name .. "_command", function()
    return {
      command = name,
      handle = function(_, ...)
        callback(...)
      end,
    }
  end, { tags = { "command" } })
end

return M
