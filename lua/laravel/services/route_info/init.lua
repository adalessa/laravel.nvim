local promise = require("promise")

---@class LaravelRouteInfo
---@field class LaravelClassService
---@field routes_repository RoutesRepository
---@field route_info_view table
---@field display_status table
local route_info = {}

function route_info:new(class, cache_routes_repository, route_info_view)
  local instance = {
    class = class,
    routes_repository = cache_routes_repository,
    route_info_view = route_info_view,
    display_status = {},
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function route_info:toggle(bufnr)
  self.display_status[bufnr] = not self.display_status[bufnr]
  self:refresh(bufnr)
end

function route_info:show(bufnr)
  self.display_status[bufnr] = true
  self:refresh(bufnr)
end

function route_info:hide(bufnr)
  self.display_status[bufnr] = false
  self:refresh(bufnr)
end

function route_info:refresh(bufnr)
  if self.display_status[bufnr] then
    self:handle(bufnr)
  else
    local namespace = vim.api.nvim_create_namespace("laravel.routes")
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    vim.diagnostic.reset(namespace, bufnr)
  end
end

---@return Promise
function route_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.routes")

  return promise
    .all({
      self.class:get(bufnr),
      self.routes_repository:all(),
    })
    :thenCall(function(results)
      local class, routes = unpack(results)

      local missing_routes = {}
      local route_methods = {}

      vim
        .iter(routes)
        :filter(function(route)
          return vim.startswith(route.action, class.fqn)
        end)
        :each(function(route)
          local class_method = vim.iter(class.methods):find(function(method)
            return route.action == method.fqn or (method.name == "__invoke" and route.action == class.fqn)
          end)

          if not class_method then
            table.insert(missing_routes, route)
          else
            table.insert(route_methods, { route = route, method = class_method })
          end
        end)
      return { class, missing_routes, route_methods }
    end)
    :thenCall(function(results)
      local class, missing_routes, route_methods = unpack(results)
      -- set the virtual text
      if self.display_status[bufnr] == nil then
        self.display_status[bufnr] = true
      end
      if self.display_status[bufnr] then
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        vim.iter(route_methods):each(function(route_method)
          vim.api.nvim_buf_set_extmark(
            bufnr,
            namespace,
            route_method.method.pos,
            0,
            self.route_info_view:get(route_method.route, route_method.method)
          )
        end)
      end

      -- set the errors
      vim.diagnostic.set(
        namespace,
        bufnr,
        vim
          .iter(missing_routes)
          :map(function(route)
            return {
              lnum = class.line,
              col = 0,
              message = string.format(
                "missing method %s [Method: %s, URI: %s]",
                route.method or "__invoke",
                table.concat(route.methods, "|"),
                route.uri
              ),
            }
          end)
          :totable()
      )
    end)
    :catch(function()
      vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      vim.diagnostic.reset(namespace, bufnr)
    end)
end

return route_info
