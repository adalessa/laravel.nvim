---@class laravel.providers.fzf_lua_provider: laravel.providers.provider
local fzf_lua_provider = {name = "laravel.providers.fzf_lua_provider"}

function fzf_lua_provider:register(app)
  app:singletonIf("pickers.fzf-lua", function()
    return {
      check = function()
        local ok, _ = pcall(require, "fzf-lua")

        return ok
      end,
      pickers = {
        artisan = "laravel.pickers.fzf_lua.pickers.artisan",
        composer = "laravel.pickers.fzf_lua.pickers.composer",
        routes = "laravel.pickers.fzf_lua.pickers.routes",
        make = "laravel.pickers.fzf_lua.pickers.make",
        related = "laravel.pickers.fzf_lua.pickers.related",
        resources = "laravel.pickers.fzf_lua.pickers.resources",
        commands = "laravel.pickers.fzf_lua.pickers.commands",
        history = "laravel.pickers.fzf_lua.pickers.history",
      },
    }
  end)
end

return fzf_lua_provider
