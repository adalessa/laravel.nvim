---@class LaravelTemplates
local templates = {
  ["route_documentation"] = [[ # Route: %s
  - methods: %s
  - uri: %s
  - middleware: %s
]],
  ["route_label"] = "%s (route)",
  ["config_label"] = "%s (config)",
  ["view_label"] = "%s (view)",
}

function templates:build(name, ...)
  return string.format(templates[name], ...)
end

return templates
