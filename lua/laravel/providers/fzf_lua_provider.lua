---@class LaravelFzfLuaProvider: LaravelProvider
local fzf_lua_provider = {}

function fzf_lua_provider:register(app)
  app:singeltonIf("fzf-lua.pickers", function()
    return {
      artisan = "laravel.pickers.fzf_lua.pickers.artisan",
      routes = "laravel.pickers.fzf_lua.pickers.routes",
      make = "laravel.pickers.fzf_lua.pickers.make",
      related = "laravel.pickers.fzf_lua.pickers.related",
      resources = "laravel.pickers.fzf_lua.pickers.resources",
      commands = "laravel.pickers.fzf_lua.pickers.commands",
      history = "laravel.pickers.fzf_lua.pickers.history",
    }
  end)
end

return fzf_lua_provider
