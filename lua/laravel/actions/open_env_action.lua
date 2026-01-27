local nio = require("nio")

return {
  check = function()
    return true
  end,
  format = function()
    return "Open env file"
  end,
  run = function()
    vim.cmd("edit .env")
  end,
}
