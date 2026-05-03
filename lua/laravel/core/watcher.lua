local notify = require("laravel.utils.notify")
local nio = require("nio")

local Watcher = {}

local watchers = {}
local timers = {}
local registrations = {}

local debounce_ms = 200

---@param path string
---@return table|nil
local function create_watcher(path)
  local w = vim.uv.new_fs_event()
  if not w then
    notify.error("Failed to create fs_event handle")
    return
  end

  local success, err = w:start(path, {}, function(err, filename)
    if err then
      notify.error("Watcher error on " .. path .. ": " .. err)
      return
    end

    if not watchers[path] then
      return
    end

    local entries = watchers[path]

    local timer = timers[path]
    if not timer then
      timer = vim.uv.new_timer()
      if not timer then
        notify.error("Failed to create debounce timer")
        return
      end
      timers[path] = timer
    end

    timer:stop()

    timer:start(
      debounce_ms,
      0,
      vim.schedule_wrap(function()
        for _, entry in ipairs(entries) do
          if filename and filename:match(entry.pattern) then
            nio.run(function()
              entry.callback(filename)
            end)
          end
        end
      end)
    )
  end)

  if not success then
    notify.error("Failed to start watcher on " .. path .. ": " .. err)
    w:stop()
    w:close()
    return nil
  end

  return w
end

local function scan_directories_async(base_path, pattern, callback)
  nio.run(function()
    local ok, handler = pcall(nio.uv.fs_opendir, base_path, nil, 100)
    if not ok or not handler then
      return
    end

    while true do
      local entries_ok, entries = pcall(nio.uv.fs_readdir, handler)
      if not entries_ok or not entries or #entries == 0 then
        break
      end

      for _, entry in ipairs(entries) do
        if entry.type == "directory" then
          local sub_path = base_path .. "/" .. entry.name
          Watcher.register({ { sub_path, recursive = true } }, pattern, callback)
        end
      end
    end

    nio.uv.fs_closedir(handler)
  end)
end

---@param paths table
---@param pattern string
---@param callback fun(filename: string)
Watcher.register = function(paths, pattern, callback)
  for _, path_entry in ipairs(paths) do
    local is_recursive = false
    local path = path_entry

    if type(path_entry) == "table" then
      is_recursive = path_entry.recursive or false
      path = path_entry[1]
    end

    if not path then
      return
    end

    local reg_key = path .. pattern .. tostring(callback)
    if registrations[reg_key] then
      return
    end
    registrations[reg_key] = true

    if not watchers[path] then
      watchers[path] = {}
      create_watcher(path)
    end

    table.insert(watchers[path], {
      pattern = pattern,
      callback = callback,
    })

    if is_recursive then
      scan_directories_async(path, pattern, callback)
    end
  end
end

Watcher.close = function(path)
  if path then
    if watchers[path] then
      for _, entry in ipairs(watchers[path]) do
        local reg_key = path .. entry.pattern .. tostring(entry.callback)
        registrations[reg_key] = nil
      end
      watchers[path] = nil
    end
    if timers[path] then
      timers[path]:stop()
      timers[path]:close()
      timers[path] = nil
    end
  else
    for p, entries in pairs(watchers) do
      for _, entry in ipairs(entries) do
        local reg_key = p .. entry.pattern .. tostring(entry.callback)
        registrations[reg_key] = nil
      end
    end
    watchers = {}
    for _, timer in pairs(timers) do
      timer:stop()
      timer:close()
    end
    timers = {}
  end
end

Watcher.info = function()
  return {
    active = vim.tbl_keys(watchers),
    registrations = vim.tbl_keys(registrations),
  }
end

return Watcher
