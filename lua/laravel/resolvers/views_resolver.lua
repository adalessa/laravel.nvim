local api = require "laravel.api"
local scan = require "plenary.scandir"


---@class View
---@field name string
---@field path string

local views_resolver = {}

---@param onSuccess fun(views: View[])|nil
---@param onFailure fun(errorMessage: string)|nil
function views_resolver.resolve(
  onSuccess,
  onFailure
)
  api.async("artisan", { "tinker", "--execute", "echo resource_path('views')" }, function(response)
    if response:failed() then
      if onFailure then onFailure(response:prettyErrors()) end
    end
    local view_path = response:prettyContent()
    local rule = string.format("^%s/(.*).blade.php$", view_path:gsub("-", "%%-"))
    local finds = scan.scan_dir(view_path, { hidden = false, depth = 4 })

    local views = vim.tbl_map(function(path)
      return {
        name = path:match(rule):gsub("/", "."),
        path = path,
      }
    end, finds)

    if onSuccess then onSuccess(views) end
  end)
end

return views_resolver
