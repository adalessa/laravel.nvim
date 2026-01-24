local app = require("laravel.core.app")

local tab = {}

function tab:new(opts)
  local instance = {
    bufnr = vim.api.nvim_create_buf(false, true),
    channel_id = nil,
    job_id = nil,
    cmd = opts.cmd,
    name = opts.name,
    key = opts.key,
    auto_start = opts.auto_start or false,
    maps = {},
  }
  setmetatable(instance, self)
  self.__index = self

  vim.api.nvim_set_option_value("modifiable", true, { buf = instance.bufnr })
  vim.api.nvim_buf_set_lines(instance.bufnr, 0, -1, false, { instance.name, instance.cmd, "NOT STARTED" })
  vim.api.nvim_set_option_value("modifiable", false, { buf = instance.bufnr })

  return instance
end

function tab:map(mode, lhs, rhs)
  table.insert(self.maps, { mode = mode, lhs = lhs, rhs = rhs })
  self:applyMaps()
end

function tab:applyMaps()
  for _, map in ipairs(self.maps) do
    vim.keymap.set(map.mode, map.lhs, map.rhs, { buffer = self.bufnr })
  end
end

function tab:_newBuffer()
  local new_buf = vim.api.nvim_create_buf(false, true)
  self.channel_id = vim.api.nvim_open_term(new_buf, {})
  self.bufnr = new_buf
  self:applyMaps()

  vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
end

function tab:start()
  if self.job_id ~= nil then
    return
  end

  self:_newBuffer()
  local cmd = app("laravel.services.command_generator"):generate(self.cmd)

  self.job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      vim.fn.chansend(self.channel_id, data)
    end,
    on_exit = function()
      vim.fn.chansend(self.channel_id, { "PROCESS EXITED" })
      self.job_id = nil
    end,
    pty = true,
  })
end

function tab:stop()
  if self.job_id == nil then
    return
  end
  vim.fn.jobstop(self.job_id)
  vim.fn.jobwait({ self.job_id }, 500)
  vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
  vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { "STOPPED" })
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
end

function tab:restart()
  self:stop()
  self:start()
end

function tab:getBufnr()
  return self.bufnr
end

function tab:getTitle()
  return {
    text = self.name,
    key = self.key,
  }
end

function tab:autostart()
  if self.auto_start then
    self:start()
  end
end

function tab:getActions()
  return {
    {
      name = "Start",
      key = "S",
      action = function()
        self:start()
      end,
    },
    {
      name = "Stop",
      key = "T",
      action = function()
        self:stop()
      end,
    },
    {
      name = "Restart",
      key = "R",
      action = function()
        self:restart()
      end,
    },
  }
end

return tab
