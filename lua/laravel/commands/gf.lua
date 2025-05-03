local split = require("laravel.utils").split
local actions = require("laravel.pickers.common.actions")

local gf_command = {}

function gf_command:new(views, gf, cache_routes_repository)
  local instance = {
    views = views,
    gf = gf,
    routes = cache_routes_repository,
    command = "gf",
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function gf_command:handle()
  local node, resource_type = self.gf:cursorOnResource()
  if not node then
    return
  end

  if resource_type == "view" then
    self.views:open(vim.treesitter.get_node_text(node, 0, {}))
    return
  end

  if resource_type == "config" then
    -- app.name
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
    self.routes:all():thenCall(function(routes)
      for _, route in ipairs(routes) do
        if route.name == route_name then
          actions.open_route(route)
          return
        end
      end
      vim.notify("Route not found", vim.log.levels.WARN)
    end)
  end
end

return gf_command
