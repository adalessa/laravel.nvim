local app = require("laravel.core.app")
local nio = require("nio")

return {
  signature = "env:configure",
  description = "Configure Laravel.nvim environment",
  handle = nio.create(function()
    app("laravel.core.env"):configure()
  end, 1),
}
