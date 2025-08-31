local actions = require("laravel.pickers.common.actions")
local format_entry = require("laravel.pickers.providers.fzf_lua.format_entry").gen_from_routes
local fzf_exec = require("fzf-lua").fzf_exec
local RoutePreviewer = require("laravel.pickers.providers.fzf_lua.previewer").RoutePreviewer

local routes_picker = {}

function routes_picker.run(opts, routes)
  local route_names, route_table = format_entry(routes)

  fzf_exec(
    route_names,
    vim.tbl_extend("force", {
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
    }, opts or {})
  )
end

return routes_picker
