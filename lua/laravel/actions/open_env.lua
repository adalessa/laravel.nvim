local promise = require("promise")

return {
  check = function()
    return promise.resolve(true)
  end,
  format = function()
    return "Open env file"
  end,
  run = function()
    vim.cmd("edit .env")
  end,
}
