local log = require("laravel.dev").log
local application = require "laravel.application"
local laravel_route = require "laravel.route"
local utils = require "laravel.utils"
local lsp = require "laravel._lsp"

local container_key = "artisan_routes"

---@param route LaravelRoute
local go_to = function(route)
  if route.action == "Closure" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd "edit routes/api.php"
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd "edit routes/web.php"
      if route.uri == "/" then
        vim.fn.search "['\"]/['\"]"
      else
        vim.fn.search("/" .. route.uri)
      end
    else
      utils.notify("Route", { msg = "Could not open the route location", level = "WARN" })
      return
    end

    vim.cmd "normal zt"
    return
  end

  local action = vim.fn.split(route.action, "@")
  lsp.go_to(action[1], action[2])
end

return {
  load = function()
    application.run("artisan", { "route:list", "--json" }, {
      runner = "async",
      callback = function(j, exit_code)
        if exit_code == 1 then
          application.container.unset(container_key)
          return
        end
        application.container.set(container_key, laravel_route.from_json(j:result()))
      end,
    })
  end,
  clean = function()
    application.container.unset(container_key)
  end,
  list = function()
    local routes = application.container.get(container_key)
    if routes then
      return routes
    end

    local result, ok = application.run("artisan", { "route:list", "--json" }, { runner = "sync" })
    if not ok then
      return nil
    end

    if result.exit_code == 1 then
      log.error("app.routes(): stdout", result.out)
      log.error("app.routes(): stderr", result.err)
      return nil
    end

    routes = laravel_route.from_json(result.out)

    application.container.set(container_key, routes)

    return routes
  end,
  go_to = go_to,
}
