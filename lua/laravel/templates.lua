---@class laravel.templates
local templates = {
  ["route_documentation"] = [[ # Route: %s
  - methods: %s
  - uri: %s
  - middleware: %s
]],
  ["route_label"] = "%s (route)",
  ["config_label"] = "%s (config)",
  ["view_label"] = "%s (view)",
  ["env_var"] = "%s (env)",
  ["relation"] = [[

    public function %s(): %s
    {
        return $this->%s;
    }
  ]]
}

function templates:build(name, ...)
  return string.format(templates[name], ...)
end

return templates
