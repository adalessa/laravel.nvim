local nio = require("nio")
local Class = require("laravel.utils.class")
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")

---@class laravel.pickers.snacks.routes
---@field routes_loader laravel.loaders.routes_cache_loader
local routes_picker = Class({
  routes_loader = "laravel.loaders.routes_cache_loader",
})

function routes_picker:run(opts)
  nio.run(function()
    local routes, err = self.routes_loader:load()
    if err then
      vim.notify("Failed to load routes: " .. err, vim.log.levels.ERROR)
      return
    end

    vim.schedule(function()
      Snacks.picker.pick(vim.tbl_extend("force", {
        title = "Routes",
        items = vim
          .iter(routes)
          :map(function(route)
            return {
              value = route,
              text = string.format("%s %s %s", vim.iter(route.methods):join(" "), route.uri, route.name or ""),
            }
          end)
          :totable(),
        format = format_entry.route,
        preview = preview.route,
        confirm = function(picker, item)
          picker:close()
          if item then
            common_actions.open_route(item.value)
          end
        end,
        actions = {
          open_browser = function(picker, item)
            picker:close()
            if item then
              common_actions.open_browser(item.value)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<c-o>"] = { "open_browser", mode = { "n", "i" }, desc = "Open Route in Browser" },
            },
          },
        },
      }, opts or {}))
    end)
  end)
end

return routes_picker
