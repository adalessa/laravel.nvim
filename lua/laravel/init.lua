---@param opts? LaravelOptions
---@param register? fun(app: LaravelApp)
---@param boot? fun(app: LaravelApp)
local function setup(opts, register, boot)
  -- register all the clases
  require("laravel.bootstrap")

  local app = require("laravel.app")
  --- set the options by the user

  -- FIX: move to a provider
  -- require("laravel.user_command")

  --- set treesitter queires
  require("laravel.treesitter_queries")
  require("laravel.tinker")

  --- FIX: move to a provider register cmp
  -- local ok, cmp = pcall(require, "cmp")
  -- if ok then
  --   cmp.register_source("laravel", require("laravel.app")("completion"))
  -- end

  -- read all the providers from laravel.providers
  -- TODO: change to by dinamic
  local providers = {
    main = require("laravel.providers.provider"),
    override = require("laravel.providers.override_provider"),
    route_info = require("laravel.providers.route_info_provider"),
  }

  for _, provider in pairs(providers) do
    provider:register(app)
  end

  if register then
    register(app)
  end

  -- TODO: where to property send this info
  app("options"):set(opts)

  for _, provider in pairs(providers) do
    provider:boot(app)
  end

  if boot then
    boot(app)
  end
end

return {
  setup = setup,
  routes = require("telescope").extensions.laravel.routes,
  artisan = require("telescope").extensions.laravel.artisan,
  history = require("telescope").extensions.laravel.history,
  make = require("telescope").extensions.laravel.make,
  commands = require("telescope").extensions.laravel.commands,
  resources = require("telescope").extensions.laravel.resources,
  recies = require("laravel.recipes").run,
  viewFinder = require("laravel.view_finder").auto,
}
