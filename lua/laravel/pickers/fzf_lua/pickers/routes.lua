local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_routes
local actions = require("laravel.pickers.common.actions")
local RoutePreviewer = require("laravel.pickers.fzf_lua.previewer").RoutePreviewer

---@class laravel.pickers.fzf_lua.routes
---@field routes_loader laravel.loaders.routes_cache_loader
local routes_picker = Class({
  routes_loader = "laravel.loaders.routes_cache_loader",
})

function routes_picker:run()
  local routes, err = self.routes_loader:load()
  if err then
    notify.error("Failed to load routes: " .. err)
    return
  end

  local route_names, route_table = format_entry(routes)

  vim.schedule(function()
    fzf_exec(route_names, {
      actions = {
        ["default"] = function(selected)
          local route = route_table[selected[1]]
          actions.open_route(route)
        end,
        ["ctrl-o"] = function(selected)
          local route = route_table[selected[1]]
          actions.open_browser(route)
        end,
      },
      prompt = "Routes > ",
      fzf_opts = {
        ["--preview-window"] = "nohidden,70%",
      },
      previewer = RoutePreviewer(route_table),
    })
  end)
end

return routes_picker
