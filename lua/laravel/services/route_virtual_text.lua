---@class LaravelRouteVirtualTextService
---@field options LaravelOptionsService
local route_virtual_text = {}

function route_virtual_text:new(options)
  local instance = {
    options = options,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

local function get_line_indent(line)
  local line_content = vim.fn.getline(line)
  return string.match(line_content, "^%s*")
end

---@param route LaravelRoute
function route_virtual_text:get(route, method)
  local position = self.options:get().features.route_info.position

  if position == "right" then
    return {
      virt_text = {
        { "[",                                               "comment" },
        { "Method: ",                                        "comment" },
        { vim.fn.join(route.methods, "|"),                   "@enum" },
        { " Uri: ",                                          "comment" },
        { route.uri,                                         "@enum" },
        { " Middleware: ",                                   "comment" },
        { vim.fn.join(route.middlewares or { "None" }, ","), "@enum" },
        { "]",                                               "comment" },
      },
    }
  end

  if position == "top" then
    local indent = get_line_indent(method.pos + 1)
    local middleware_lines = {}

    for _, mw in ipairs(route.middlewares or { "None" }) do
      table.insert(middleware_lines, { { indent .. "  " .. mw, "@enum" } })
    end

    local virt_lines = {
      { { indent .. "[", "comment" } },
      { { indent .. " Method: ", "comment" },    { vim.fn.join(route.methods, "|"), "@enum" } },
      { { indent .. " Uri: ", "comment" },       { route.uri, "@enum" } },
      { { indent .. " Middleware: ", "comment" } },
    }

    for _, line in ipairs(middleware_lines) do
      table.insert(virt_lines, line)
    end

    table.insert(virt_lines, { { indent .. "]", "comment" } })
    return {
      virt_lines = virt_lines,
      virt_lines_above = true,
    }
  end
end

return route_virtual_text
