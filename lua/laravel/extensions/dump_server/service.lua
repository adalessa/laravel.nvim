local Task = require("laravel.task")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local dump_server = Class({
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
function dump_server:isInstalled()
  local commands, err = self.commands_loader:load()
  if err then
    return false, "Could not load artisan commands: " .. err
  end

  return vim.iter(commands):any(function(command)
    return command.name == "dump-server"
  end)
end

---@async
function dump_server:install()
  local isInstalled, err = self:isInstalled()
  if err then
    notify.error("Could not check if dump server is installed: " .. err)
    return
  end

  if isInstalled then
    notify.info("Dump server already installed")
    return
  end

  return self.runner:run("composer", { "require", "--dev", "beyondcode/laravel-dump-server" })
end

function dump_server:start()
  if self.task:running() then
    notify.info("Server already running")

    return true
  end

  local isInstalled, err = self:isInstalled()
  if err then
    notify.error("Could not check if dump server is installed: " .. err)
    return
  end

  if not isInstalled then
    notify.error("Dump server not installed")
    return
  end

  self:_start()
end

function dump_server:_start()
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

function dump_server:stop()
  self.task:stop()
end

function dump_server:isRunning()
  return self.task:running()
end

function dump_server:getRecords()
  return self.records
end

function dump_server:unseenRecords()
  return vim
    .iter(self.records)
    :filter(function(record)
      return not record.seen
    end)
    :totable()
end

function dump_server:markRecordAsSeen(index)
  self.records[index].seen = true
end

function dump_server:_stdout(err, data)
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
          vim.api.nvim_exec_autocmds("user", {
            pattern = "DumpServerRecord",
          })
        end
      end
    end
  end
end

return dump_server
