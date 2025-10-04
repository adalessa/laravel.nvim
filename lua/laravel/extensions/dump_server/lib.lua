local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local Task = require("laravel.task")
local record_added = require("laravel.extensions.dump_server.record_added_event")
local Error = require("laravel.utils.error")

---@class laravel.extensions.dump_server.lib
---@field command_generator laravel.services.command_generator
---@field commands_loader laravel.loaders.artisan_cache_loader
---@field runner laravel.services.runner
---@field task laravel.task
local lib = Class({
  command_generator = "laravel.services.command_generator",
  commands_loader = "laravel.loaders.artisan_cache_loader",
  runner = "laravel.services.runner",
}, {
  task = Task:new(),
  in_header = false,
  current_index = nil,
  records = {},
})

---@async
function lib:isInstalled()
  local commands, err = self.commands_loader:load()
  if err then
    return false, Error:new("Could not load artisan commands"):wrap(err)
  end

  return vim.iter(commands):any(function(command)
    return command.name == "dump-server"
  end)
end

---@async
function lib:install()
  local isInstalled, err = self:isInstalled()
  if err then
    notify.error("Could not check if dump server is installed: " .. err:toString())
    return
  end

  if isInstalled then
    notify.info("Dump server already installed")
    return
  end

  return self.runner:run("composer", { "require", "--dev", "beyondcode/laravel-dump-server" })
end

---@async
function lib:start()
  if self.task:running() then
    notify.info("Server already running")

    return true
  end

  local isInstalled, err = self:isInstalled()
  if err then
    notify.error("Could not check if dump server is installed: " .. err:toString())
    return false
  end

  if not isInstalled then
    notify.error("Dump server not installed")
    return false
  end

  self:_start()

  return true
end

function lib:_start()
  -- reseting
  self.records = {}
  self.in_header = false
  self.current_index = nil

  local cmd = self.command_generator:generate("artisan dump-server")
  if not cmd then
    notify.error("Dump server not found")
    return
  end

  self.task:run(
    cmd,
    vim.schedule_wrap(function(data)
      self:_stdout(nil, data)
    end),
    vim.schedule_wrap(function(err)
      self:_stdout(err, nil)
    end)
  )
end

function lib:stop()
  self.task:stop()
end

function lib:isRunning()
  return self.task:running()
end

function lib:getRecords()
  return self.records
end

function lib:unseenRecords()
  return vim
    .iter(self.records)
    :filter(function(record)
      return not record.seen
    end)
    :totable()
end

function lib:markRecordAsSeen(index)
  self.records[index].seen = true
end

function lib:_stdout(err, data)
  if err then
    error(err)
  end

  -- split data by new line
  if data == nil or not type(data) == "string" then
    return
  end

  for _, line in ipairs(vim.split(data, "\n")) do
    if line ~= "" then
      if vim.startswith(line, " ------------ ") then
        self.in_header = not self.in_header
        if self.in_header then
          self.current_index = #self.records + 1
        end
      elseif self.current_index ~= nil then
        self.records[self.current_index] = self.records[self.current_index]
          or {
            headers = {},
            body = {},
            seen = false,
          }

        if self.in_header then
          local key, value = line:match("([^%s]+)%s+(.+)")
          table.insert(self.records[self.current_index].headers, { key = key, value = vim.trim(value) })
        else
          table.insert(self.records[self.current_index].body, line)
          record_added.dispatch()
        end
      end
    end
  end
end

return lib
