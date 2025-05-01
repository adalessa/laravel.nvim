local promise = require("promise")

local action = {}

function action:check()
  return promise.resolve(self)
end

function action:format()
  return "Open env file"
end

function action:run()
  vim.cmd("edit .env")
end

return action
