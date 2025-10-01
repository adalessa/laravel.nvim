local app = require("laravel.core.app")
local split = require("laravel.utils").split
local actions = require("laravel.pickers.common.actions")
local notify = require("laravel.utils.notify")
local nio    = require("nio")

local gf_command = {
  signature = "gf",
  description = "Go to file",
}

---@async
function gf_command:handle()
  nio.run(function()
    ---@type laravel.loaders.routes_cache_loader
    local routes_loader = app:make("laravel.loaders.routes_cache_loader")
    ---@type laravel.services.gf
    local gf = app:make("laravel.services.gf")
    ---@type laravel.services.views
    local views = app:make("laravel.services.views")

    local node, resource_type = gf:cursorOnResource()
    if not node then
      return
    end

    if resource_type == "view" then
      local path, err = views:pathFromName(vim.treesitter.get_node_text(node, 0, {}))
      if err then
        notify.error("Could not find view: " .. err)
        return
      end

      vim.schedule(function()
        vim.cmd("e " .. path)
      end)
      return
    end

    if resource_type == "config" then
      local config_name = vim.treesitter.get_node_text(node, 0, {})
      local s = split(config_name, ".")

      -- TODO: can be improve by parsing the file with treesitter.
      -- find the return and with the the array elements with the next items
      vim.cmd("e config/" .. s[1] .. ".php")
      return
    end

    if resource_type == "env" then
      local env_name = vim.treesitter.get_node_text(node, 0, {})
      vim.cmd("e .env")
      vim.fn.search(env_name)
      vim.cmd("normal zt")
      return
    end

    if resource_type == "route" then
      local route_name = vim.treesitter.get_node_text(node, 0, {})
      local routes, err = routes_loader:load()
      if err then
        notify.error("Could not load routes: " .. err)
        return
      end
      for _, route in ipairs(routes) do
        if route.name == route_name then
          actions.open_route(route)
          return
        end
      end
      notify.warn("Route not found")
    end
  end)
end

return gf_command
