local notify = require("laravel.utils.notify")
local nio = require("nio")

local Watcher = {}

local watchers = {}
local timers = {}

local debounce_time = 1 --second

---@param path string
local function create_watcher(path)
  local w = vim.uv.new_fs_event()
  assert(w, "Failed to create fs_event handle")
  w:start(path, { recursive = false }, function(err, filename, status)
    if err then
      notify.error("Watcher error: " .. err)
      return
    end
    if os.time() - (timers[filename] or 0) < debounce_time then
      return
    end

    timers[filename] = os.time()

    -- Notify all registered callbacks for this path
    if watchers[path] then
      for _, watcher in ipairs(watchers[path]) do
        assert(type(watcher) == "function", "Watcher callback must be a function")
        watcher(filename, status)
      end
    end
  end)
end

---@param pattern string
---@param callback fun(filename: string)
Watcher.register = function(paths, pattern, callback)
  for _, path in ipairs(paths) do
    local isRecursive = false
    if type(path) == "table" then
      isRecursive = path.recursive or false
      path = path[1]
    end

    if not watchers[path] then
      watchers[path] = {}
      create_watcher(path)
    end
    table.insert(watchers[path], function(filename)
      if filename:match(pattern) then
        nio.run(function()
          callback()
        end)
      end
    end)

    if isRecursive then
      local _, handler = nio.uv.fs_opendir(path)
      local directories = {}
      while true do
        local _, c = nio.uv.fs_readdir(handler)
        if not c then
          break
        end
        local dir = c[1]
        if dir and dir.type == "directory" then
          table.insert(directories, { path .. "/" .. dir.name, recursive = true })
        end
      end
      if #directories > 0 then
        Watcher.register(directories, pattern, callback)
      end
    end
  end
end

Watcher.info = function()
  return {
    active = vim.tbl_keys(watchers),
  }
end

return Watcher
