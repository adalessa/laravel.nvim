local Task = require("laravel.task")

local promise = require("promise")
local dump_server = {}

function dump_server:new(api, cache_commands_repository, runner)
  local instance = {
    api = api,
    commands_repository = cache_commands_repository,
    runner = runner,
    task = Task:new(),
    in_header = false,
    current_index = nil,
    records = {},
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function dump_server:isInstalled()
  return self.commands_repository:all():thenCall(function(commands)
    return vim.iter(commands):any(function(command)
      return command.name == "dump-server"
    end)
  end)
end

function dump_server:install()
  self:isInstalled():thenCall(function(isInstalled)
    if isInstalled then
      vim.notify("Dump server already installed", vim.log.levels.INFO, {})
      return promise.resolve()
    end

    return self.runner:run("composer", { "require", "--dev", "beyondcode/laravel-dump-server" })
  end)
end

function dump_server:start()
  if self.task:running() then
    vim.notify("Server already running", vim.log.levels.INFO, {})

    return promise.resolve()
  end

  return self:isInstalled():thenCall(function(isInstalled)
    if not isInstalled then
      vim.notify("Dump server not installed", vim.log.levels.ERROR, {})
      return promise.reject("Dump server not installed")
    end

    self:_start()
    return promise.resolve()
  end)
end

function dump_server:_start()
  -- reseting
  self.records = {}
  self.in_header = false
  self.current_index = nil

  local cmd = self.api:generateCommand("artisan", { "dump-server" })
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
