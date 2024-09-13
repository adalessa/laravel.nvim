local scan = require("plenary.scandir")

---@class LaravelView
---@field name string
---@field path string

---@class LaravelViewsProvider
---@field paths_service LaravelPathProvider
---@field runner LaravelRunner
local views = {}

function views:new(paths, runner)
  local instance = {
    paths_service = paths,
    runner = runner,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param callback fun(commands: LaravelView[])
---@return vim.SystemObj
function views:get(callback)
  return self.paths_service:resource("views", function(views_directory)
    local rule = string.format("^%s/(.*).blade.php$", views_directory:gsub("-", "%%-"))
    scan.scan_dir_async(views_directory, {
      hidden = false,
      depth = 4,
      on_exit = function(finds)
        callback(vim
          .iter(finds)
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
end

function views:open(name)
  self.paths_service:resource(
    "views",
    vim.schedule_wrap(function(views_directory)
      local view_path = string.format("%s/%s.blade.php", views_directory, name:gsub("%.", "/"))

      if vim.fn.filewritable(view_path) == 1 then
        vim.cmd("edit " .. view_path)
        return
      end
      -- It creates the view if does not exists and user want it
      if vim.fn.confirm("View " .. name .. " does not exists, Should create it?", "&Yes\n&No") == 1 then
        self.runner:run("artisan", { "make:view", name })
      end
    end)
  )
end

function views:name(fname, callback)
  self.paths_service:resource(
    "views",
    vim.schedule_wrap(function(views_directory)
      views_directory = views_directory .. "/"
      local view = fname:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", ".")
      callback(view)
    end)
  )
end

return views
