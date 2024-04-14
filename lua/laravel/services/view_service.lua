local resolver = require "laravel.resolvers.cache"
local utils = require "laravel.utils"

---@class ViewService
local ViewService = {}

---@param name string
---@param onSuccess fun(view: View)
---@param onFailure fun(errorMessage: string)|nil
function ViewService:find(name, onSuccess, onFailure)
  return resolver.views.resolve(
    function(views)
      ---@type View[]
      local filter = vim.tbl_filter(
        function(view) return view.name == name end,
        views
      )
      if not filter then
        if onFailure then onFailure("view not found") end
        return
      end
      onSuccess(filter[1])
    end,
    onFailure
  )
end

--- Finds the usage of the view base on the name of the file
---@param fileName string
---@param onSuccess fun(usages: Match[])
---@param onFailure fun(errorMessage: string)|nil
function ViewService:usage(fileName, onSuccess, onFailure)
  resolver.paths.resolve(
    "views",
    function(path)
      local name = fileName:gsub((path .. "/"):gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", ".")
      -- looks for view('')
      -- TODO: support Route::view("", 'something')
      local matches = utils.runRipgrep(string.format("view\\(['\\\"]%s['\\\"]", name))
      onSuccess(matches)
    end,
    onFailure
  )
end

return ViewService
