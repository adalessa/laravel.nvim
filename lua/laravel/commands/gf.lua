local app = require("laravel.core.app")
local split = require("laravel.utils").split
local actions = require("laravel.pickers.common.actions")
local notify = require("laravel.utils.notify")
local nio = require("nio")

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

    ---@type laravel.services.inertia
    local inertia = app:make("laravel.services.inertia")

    local node, resource_type = gf:cursorOnResource()
    if not node then
      return
    end

    if resource_type == "view" then
      local path, err = views:pathFromName(vim.treesitter.get_node_text(node, 0, {}))
      if err then
        notify.error("Could not find view: " .. err:toString())
        return
      end

      nio.scheduler()
      vim.cmd("e " .. path)

      return
    end

    if resource_type == "inertia" then
      local inertia_name = vim.treesitter.get_node_text(node, 0, {})
      local path, err = inertia:find(inertia_name)
      if err then
        notify.error("Could not find inertia view: " .. err:toString())
        return
      end

      nio.scheduler()
      vim.cmd("e " .. path)

      return
    end

    if resource_type == "config" then
      local config_name = vim.treesitter.get_node_text(node, 0, {})
      nio.run(function()
        local config, err = app("laravel.loaders.configs_loader"):get(config_name)
        if err or not config then
          return
        end
        local actual_file, err = app("laravel.services.path"):handle(config.file)
        if err then
          return
        end
        nio.scheduler()
        if pcall(vim.cmd.edit, actual_file) then
          pcall(vim.api.nvim_win_set_cursor, 0, { config.line, 0 })
          pcall(vim.cmd.normal, "zt")
        end
      end)
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
        notify.error("Could not load routes: " .. err:toString())
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
