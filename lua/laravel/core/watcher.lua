local notify = require("laravel.utils.notify")

local Watcher = {}

local watchers = {}
local timers = {}

local debounce_time = 1 --second

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

---@param paths string[]
---@param pattern string
---@param callback fun(filename: string)
Watcher.register = function(paths, pattern, callback)
  for _, path in ipairs(paths) do
    if not watchers[path] then
      watchers[path] = {}
      create_watcher(path)
    end
    table.insert(watchers[path], function(filename)
      if filename:match(pattern) then
        callback(vim.fs.joinpath(path, filename))
      end
    end)
  end
end

return Watcher
