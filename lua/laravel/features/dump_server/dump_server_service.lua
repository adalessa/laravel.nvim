local dump_server = {}

function dump_server:new(api)
  local instance = {
    api = api,
    job = nil,
    in_header = false,
    current_index = nil,
    records = {},
    commandId = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function dump_server:start()
  if self.job then
    vim.notify("Server already running", vim.log.levels.INFO, {})
    return
  end

  -- reseting
  self.records = {}
  self.in_header = false
  self.current_index = nil

  self.commandId = vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function()
      self.job:kill(15)
    end,
  })

  local cmd = self.api:generate_command("artisan", { "dump-server" })
  self.job = vim.system(
    cmd,
    {
      stdout = vim.schedule_wrap(function(err, data)
        self:_stdout(err, data)
      end),
    },
    vim.schedule_wrap(function()
      vim.api.nvim_del_autocmd(self.commandId)
      self.job = nil
      self.commandId = nil
    end)
  )
end

function dump_server:stop()
  self.job:kill(15)
end

function dump_server:isRunning()
  return self.job ~= nil
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
