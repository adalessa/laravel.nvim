local M = {}

local function check_nil(value)
  if value == vim.NIL then
    return nil
  end
  return value
end

M.from_json = function(json)
  local routes = {}
  if json == "" or json == nil or #json == 0 then
    return routes
  end
  for _, route in ipairs(vim.fn.json_decode(json)) do
    table.insert(routes, {
      uri = route.uri,
      action = route.action,
      domain = check_nil(route.domain),
      methods = vim.fn.split(route.method, "|"),
      middlewares = route.middleware,
      name = check_nil(route.name),
    })
  end

  return routes
end

return M
