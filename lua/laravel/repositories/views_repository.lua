local scan = require("plenary.scandir")
local promise = require("promise")

---@class ViewsRepository
---@field resources_repository ResourcesRepository
local views_repository = {}

function views_repository:new(cache_resources_repository)
  local instance = { resources_repository = cache_resources_repository }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function views_repository:all()
  return self.resources_repository:get("views"):thenCall(function(directory)
    local rule = string.format("^%s/(.*).blade.php$", directory:gsub("-", "%%-"))

    return promise:new(function(resolve, reject)
      if not directory then
        reject("Directory is required")

        return
      end

      scan.scan_dir_async(directory, {
        hidden = false,
        depth = 4,
        on_exit = function(finds)
          resolve(vim
            .iter(finds)
            :filter(function (value) return value ~= nil end)
            :map(function(value)
              return {
                name = value:match(rule):gsub("/", "."),
                path = value,
              }
            end)
            :totable())
        end,
      })
    end)
  end)
end

return views_repository
