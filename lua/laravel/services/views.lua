---@class LaravelViewsService
---@field resources_repository ResourcesRepository
---@field runner LaravelRunner
local views = {}

function views:new(cache_resources_repository, runner)
  local instance = {
    resources_repository = cache_resources_repository,
    runner = runner,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function views:open(name)
  return self.resources_repository:get("views"):thenCall(function(views_directory)
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
end

function views:name(fname, callback)
  return self.resources_repository:get("views"):thenCall(function(views_directory)
    views_directory = views_directory .. "/"
    local view = fname:gsub(views_directory:gsub("-", "%%-"), ""):gsub("%.blade%.php", ""):gsub("/", ".")
    callback(view)
  end)
end

return views
