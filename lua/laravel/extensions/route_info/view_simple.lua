local get_line_indent = require("laravel.utils.init").get_line_indent

local view = {}

function view:get(route, method)
  local indent = get_line_indent(method.pos[1] + 1)

  return {
    virt_lines = {
      {
        { indent .. "[", "comment" },
        { "Method: ", "comment" },
        { table.concat(route.methods, "|"), "@string" },
        { " Uri: ", "comment" },
        { route.uri, "@string" },
        { " ", "@string" },
        {
          vim
            .iter(route.middlewares or {})
            :filter(function(middleware)
              return vim.tbl_contains({ "web", "api", "auth" }, middleware)
            end)
            :map(function(middleware)
              return "@" .. middleware
            end)
            :join(" "),
          "@enum",
        },
        { "]", "comment" },
      },
    },
    virt_lines_above = true,
  }
end

return view
