local view_right = {}

local function get_line_indent(line)
  local line_content = vim.fn.getline(line)
  return string.match(line_content, "^%s*")
end

function view_right:get(route, method)
  local indent = get_line_indent(method.pos + 1)
  local middleware_lines = {}

  for _, mw in ipairs(route.middlewares or { "None" }) do
    table.insert(middleware_lines, { { indent .. "  " .. mw, "@enum" } })
  end

  local virt_lines = {
    { { indent .. "[", "comment" } },
    { { indent .. " Method: ", "comment" },    { table.concat(route.methods, "|"), "@enum" } },
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

return view_right
