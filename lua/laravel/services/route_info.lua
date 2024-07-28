---@class LaravelRouteInfo
---@field class LaravelClassService
---@field routes LaravelRouteProvider
---@field route_virutal_text LaravelRouteVirtualTextService
local route_info = {}

function route_info:new(class, routes, route_virutal_text)
  local instance = {
    class = class,
    routes = routes,
    route_virutal_text = route_virutal_text,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

local function is_same_class(action, class)
  return string.sub(action, 1, string.len(class)) == class
end

function route_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.routes")

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)

  self.class:get(bufnr, function(class)
    if not class.fqn then
      return
    end
    self.routes:get(vim.schedule_wrap(function(routes)
      local errors = {}
      for _, route in routes:enumerate() do
        local found = false
        for _, method in pairs(class.methods) do
          local action_full = route.action
          if vim.fn.split(route.action, "@")[2] == nil then
            action_full = action_full .. "@__invoke"
          end
          if action_full == string.format("%s@%s", class.fqn, method.name) then
            vim.api.nvim_buf_set_extmark(bufnr, namespace, method.pos, 0, self.route_virutal_text:get(route, method))
            found = true
          end
        end

        if is_same_class(route.action, class.fqn) and not found then
          table.insert(errors, {
            lnum = class.line,
            col = 0,
            message = string.format(
              "missing method %s [Method: %s, URI: %s]",
              vim.fn.split(route.action, "@")[2] or "__invoke",
              vim.fn.join(route.methods, "|"),
              route.uri
            ),
          })
        end
      end
      if #errors > 0 then
        vim.diagnostic.set(namespace, bufnr, errors)
      end
    end))
  end)
end

return route_info
