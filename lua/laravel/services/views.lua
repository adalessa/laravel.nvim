local scan = require("plenary.scandir")

---@class LaravelView
---@field name string
---@field path string

---@class LaravelViewsProvider
---@field paths_service LaravelPathProvider
local views = {}

function views:new(paths)
  local instance = setmetatable({}, { __index = views })
  instance.paths_service = paths
  return instance
end

---@param callback fun(commands: LaravelView[])
---@return Job
function views:get(callback)
  return self.paths_service:resource("views", function(views_directory)
    local rule = string.format("^%s/(.*).blade.php$", views_directory:gsub("-", "%%-"))
    local finds = scan.scan_dir(views_directory, { hidden = false, depth = 4 })

    callback(vim
      .iter(finds)
      :map(function(value)
        return {
          name = value:match(rule):gsub("/", "."),
          path = value,
        }
      end)
      :totable())
  end)
end

return views
