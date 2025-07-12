local common_actions = require("laravel.pickers.common.actions")
local preview = require("laravel.pickers.providers.snacks.preview")

local routes_picker = {}

function routes_picker.run(opts, routes)
  local nameLenght, uriLenght = 0, 0

  vim.iter(routes):each(function(route)
    nameLenght = math.max(nameLenght, route.name and #route.name or 0)
    uriLenght = math.max(uriLenght, #route.uri)
  end)

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
    format = function(item, _)
      local uriPadding = string.rep(" ", uriLenght - #item.value.uri)
      local namePadding = string.rep(" ", nameLenght - string.len(item.value.name or ""))
      return {
        { item.value.uri .. uriPadding, "@enum" },
        { " ", "@string" },
        { (item.value.name or "") .. namePadding, "@keyword" },
        { " ", "@string" },
        { vim.iter(item.value.methods):join("|"), "@string" },
      }
    end,
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
