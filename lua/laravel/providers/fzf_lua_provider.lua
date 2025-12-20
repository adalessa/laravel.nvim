---@type laravel.providers.provider
local fzf_lua_provider = {name = "laravel.providers.fzf_lua_provider"}

function fzf_lua_provider.register(app)
  app:singletonIf("pickers.fzf-lua", function()
    return {
      check = function()
        local ok, _ = pcall(require, "fzf-lua")

        return ok
      end,
      pickers = {
        artisan = "laravel.pickers.providers.fzf_lua.artisan",
        composer = "laravel.pickers.providers.fzf_lua.composer",
        routes = "laravel.pickers.providers.fzf_lua.routes",
        make = "laravel.pickers.providers.fzf_lua.make",
        related = "laravel.pickers.providers.fzf_lua.related",
        resources = "laravel.pickers.providers.fzf_lua.resources",
        commands = "laravel.pickers.providers.fzf_lua.commands",
        history = "laravel.pickers.providers.fzf_lua.history",
      },
    }
  end)
end

return fzf_lua_provider
