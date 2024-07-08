local scan = require("plenary.scandir")

---@class LaravelView
---@field name string
---@field path string

---@class LaravelViewsProvider
---@field paths_provider LaravelPathProvider
local views = {}

function views:new(paths_provider)
  local instance = setmetatable({}, { __index = views })
  instance.paths_provider = paths_provider
  return instance
end

---@param callback fun(commands: Iter<LaravelView>)
---@return Job
function views:get(callback)
  return self.paths_provider:resource("views", function(views_directory)
    local rule = string.format("^%s/(.*).blade.php$", views_directory:gsub("-", "%%-"))
    local finds = scan.scan_dir(views_directory, { hidden = false, depth = 4 })

    callback(vim.iter(finds):map(function(value)
      return {
        name = value:match(rule):gsub("/", "."),
        path = value,
      }
    end))
  end)
end

return views
