local resource_path_resolve = require("laravel.resolvers.resource_path_resolver")
local scan = require("plenary.scandir")

---@class View
---@field name string
---@field path string

local views_resolver = {}

---@param onSuccess fun(views: View[])|nil
---@param onFailure fun(errorMessage: string)|nil
function views_resolver.resolve(onSuccess, onFailure)
  resource_path_resolve.resolve("views", function(view_path)
    -- FIX this is a fix to handle the docker case
    view_path = view_path:gsub("/var/www/html", vim.fn.getcwd())
    local rule = string.format("^%s/(.*).blade.php$", view_path:gsub("-", "%%-"))
    local finds = scan.scan_dir(view_path, { hidden = false, depth = 4 })

    local views = vim.tbl_map(function(path)
      return {
        name = path:match(rule):gsub("/", "."),
        path = path,
      }
    end, finds)

    if onSuccess then
      onSuccess(views)
    end
  end, onFailure)
end

return views_resolver
