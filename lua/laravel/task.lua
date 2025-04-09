local task = {}

function task:new()
  local instance = setmetatable({
    handle = nil,
    pid = nil,
    exit = nil,
    stdout = nil,
    stderr = nil,
    data = "",
    error = "",
    commandId = nil,
  }, { __index = task })
  return instance
end

function task:running()
  return self.pid ~= nil
end

--- @param command string[]
function task:run(command, stdCallback, errCallback)
  local cmd = table.remove(command, 1)

  self.stdout = vim.uv.new_pipe()
  self.stderr = vim.uv.new_pipe()
  self.data = ""
  self.error = ""

  self.commandId = vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function()
      self:stop()
    end,
  })

  local handle, pid = vim.uv.spawn(
    cmd,
    {
      args = command,
      detached = true,
      stdio = { nil, self.stdout, self.stderr },
    },
    vim.schedule_wrap(function(code, signal)
      self:_exit(code, signal)
    end)
  )

  vim.uv.read_start(self.stdout, function(err, data)
    if err then
      vim.notify("Error reading stdout: " .. err, vim.log.levels.ERROR)
      return
    end
    if data then
      self.data = self.data .. data
      if stdCallback then
        stdCallback(data)
      end
    end
  end)

  vim.uv.read_start(self.stderr, function(err, data)
    if err then
      vim.notify("Error reading stderr: " .. err, vim.log.levels.ERROR)
      return
    end
    if data then
      self.error = self.error .. data
      if errCallback then
        errCallback(data)
      end
    end
  end)

  self.handle = handle
  self.pid = pid
end

function task:stop()
  if self.handle == nil then
    return
  end
  vim.uv.kill(-self.pid, "sigterm")
end

function task:_exit(code, signal)
  self.exit = {
    code = code,
    signal = signal,
  }
  vim.uv.read_stop(self.stdout)
  vim.uv.read_stop(self.stderr)
  self.handle:close()
  self.stdout:close()
  self.stderr:close()
  self.handle = nil
  self.pid = nil
  self.stdout = nil
  self.stderr = nil
  vim.api.nvim_del_autocmd(self.commandId)
end

return task
