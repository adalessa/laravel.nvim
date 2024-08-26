local view_right = {}

function view_right:get(route)
  return {
    virt_text = {
      { "[",                                                "comment" },
      { "Method: ",                                         "comment" },
      { table.concat(route.methods, "|"),                   "@enum" },
      { " Uri: ",                                           "comment" },
      { route.uri,                                          "@enum" },
      { " Middleware: ",                                    "comment" },
      { table.concat(route.middlewares or { "None" }, ","), "@enum" },
      { "]",                                                "comment" },
    },
  }
end

return view_right
