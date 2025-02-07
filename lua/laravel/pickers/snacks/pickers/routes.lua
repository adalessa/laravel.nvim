local snacks = require("snacks").picker
local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.snacks.preview")
local format_entry = require("laravel.pickers.snacks.format_entry")

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
  self.routes_repository:all():thenCall(function(routes)
    snacks.pick(vim.tbl_extend("force", {
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
          common_actions.go(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return routes_picker
