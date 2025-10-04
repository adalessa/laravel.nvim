local Class = require("laravel.utils.class")
local nio = require("nio")
local notify = require("laravel.utils.notify")

local clean = vim.schedule_wrap(function(bufnr, namespace)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.diagnostic.reset(namespace, bufnr)
end)

---@class laravel.extensions.route_info.lib
---@field class laravel.services.class
---@field routes_loader laravel.loaders.routes_cache_loader
---@field route_info_view table
---@field display_status table
local route_info = Class({
  class = "laravel.services.class",
  routes_loader = "laravel.loaders.routes_cache_loader",
  route_info_view = "laravel.extensions.route_info.view_factory",
}, {
  display_status = {},
})

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
    clean(bufnr, namespace)
  end
end

function route_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.routes")
  nio.run(function()
    local class, err = self.class:get(bufnr)
    if err then
      clean(bufnr, namespace)
      notify.error("Could not get class for buffer: " .. err:toString())
      return
    end
    local routes, err = self.routes_loader:load()
    if err then
      clean(bufnr, namespace)
      notify.error("Could not load routes: " .. err:toString())
      return
    end

    ---
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

    if self.display_status[bufnr] == nil then
      self.display_status[bufnr] = true
    end

    if self.display_status[bufnr] then
      clean(bufnr, namespace)
      vim.iter(route_methods):each(vim.schedule_wrap(function(route_method)
        vim.api.nvim_buf_set_extmark(
          bufnr,
          namespace,
          route_method.method.pos,
          0,
          self.route_info_view:get(route_method.route, route_method.method)
        )
      end))
    end

    vim.schedule(function()
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
  end)
end

return route_info
