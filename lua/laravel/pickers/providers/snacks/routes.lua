local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.providers.snacks.preview")
local format_entry = require("laravel.pickers.providers.snacks.format_entry")

local routes_picker = {}

function routes_picker.run(opts, routes)
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
end

return routes_picker
