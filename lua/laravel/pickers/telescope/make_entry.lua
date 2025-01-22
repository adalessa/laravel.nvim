local entry_display = require("telescope.pickers.entry_display")

local M = {}

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

M.set_default_entry_mt = function(tbl, opts)
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

function M.gen_from_laravel_routes(opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = " ",
    hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
    items = {
      { width = 16 },
      { width = 40 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      { vim.fn.join(entry.value.methods, "|"), "TelescopeResultsConstant" },
      { entry.value.uri, "TelescopeResultsIdentifier" },
      { entry.value.name or "", "TelescopeResultsFunction" },
    })
  end

  return function(route)
    return M.set_default_entry_mt({
      value = route,
      ordinal = vim.fn.join({ route.uri, route.name or "" }, " "),
      display = make_display,
      route_method = vim.fn.join(route.methods, "|"),
    }, opts)
  end
end

function M.gen_from_model_relations(opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = " ",
    hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
    items = {
      { width = 40 },
      { width = 20 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      { entry.value.class_name, "TelescopeResultsConstant" },
      { entry.value.type, "TelescopeResultsIdentifier" },
      { entry.value.extra_information or "", "TelescopeResultsFunction" },
    })
  end

  return function(relation)
    local class_parts = vim.split(relation.class, "\\")
    relation.class_name = class_parts[#class_parts]
    return M.set_default_entry_mt({
      value = relation,
      ordinal = relation.class_name,
      display = make_display,
    }, opts)
  end
end

return M
