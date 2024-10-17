local fzf_exec = require("fzf-lua").fzf_exec
local format_entry = require("laravel.pickers.fzf_lua.format_entry").gen_from_routes
local actions = require("laravel.pickers.common.actions")
local RoutePreviewer = require("laravel.pickers.fzf_lua.previewer").RoutePreviewer

---@class LaravelFzfLuaRoutesPicker
---@field routes_repository RoutesRepository
local routes_picker = {}

function routes_picker:new(cache_routes_repository)
  local instance = {
    routes_repository = cache_routes_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes_picker:run(opts)
  opts = opts or {}

  self.routes_repository:all():thenCall(function(routes)
    local route_names, route_table = format_entry(routes)

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
