local entry_display = require "telescope.pickers.entry_display"

local make_entry = {}

local handle_entry_index = function(opts, t, k)
  local override = ((opts or {}).entry_index or {})[k]
  if not override then
    return
  end

  local val, save = override(t, opts)
  if save then
    rawset(t, k, val)
  end
  return val
end

make_entry.set_default_entry_mt = function(tbl, opts)
  return setmetatable({}, {
    __index = function(t, k)
      local override = handle_entry_index(opts, t, k)
      if override then
        return override
      end

      -- Only hit tbl once
      local val = tbl[k]
      if val then
        rawset(t, k, val)
      end

      return val
    end,
  })
end

function make_entry.gen_from_laravel_routes(opts)
  opts = opts or {}

  local displayer = entry_display.create {
    separator = " ",
    hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
    items = {
      { width = 16 },
      { width = 40 },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    return displayer {
      { vim.fn.join(entry.value.methods, "|"), "TelescopeResultsConstant" },
      { entry.value.uri, "TelescopeResultsIdentifier" },
      { entry.value.name or "", "TelescopeResultsFunction" },
    }
  end

  return function(route)
    return make_entry.set_default_entry_mt({
      value = route,
      ordinal = route.uri,
      display = make_display,
      route_method = vim.fn.join(route.methods, "|"),
    }, opts)
  end
end

return make_entry
