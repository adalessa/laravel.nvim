---@param opts? LaravelOptions
---@param register? fun(app: LaravelApp)
---@param boot? fun(app: LaravelApp)
local function setup(opts, register, boot)
  local app = require("laravel.app")

  opts = vim.tbl_deep_extend("force", require("laravel.options.default"), opts or {})

  app():register("options", function()
    return require("laravel.services.options"):new(opts)
  end)

  for _, provider in pairs(opts.providers) do
    provider:register(app)
  end

  for _, provider in pairs(opts.user_providers) do
    provider:register(app)
  end

  if register then
    register(app)
  end

  for _, provider in pairs(opts.providers) do
    provider:boot(app)
  end

  for _, provider in pairs(opts.user_providers) do
    provider:boot(app)
  end

  if boot then
    boot(app)
  end
end

return {
  setup = setup,
  -- history = require("telescope").extensions.laravel.history,
  -- make = require("telescope").extensions.laravel.make,
  -- commands = require("telescope").extensions.laravel.commands,
  -- resources = require("telescope").extensions.laravel.resources,
  -- recies = require("laravel.recipes").run,
  -- viewFinder = require("laravel.view_finder").auto,
}
