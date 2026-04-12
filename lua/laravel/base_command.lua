---@class laravel.BaseCommand
---@field cmd string[]
---@field name string
---@field job_id integer|nil
---@field bufnr integer|nil
---@field exited boolean
local BaseCommand = {}
BaseCommand.__index = BaseCommand

---@param cmd string[]
---@param opts table|nil
function BaseCommand:new(cmd, opts)
  opts = opts or {}

  local instance = {
    cmd = cmd,
    name = opts.name or table.concat(cmd, " "),
    job_id = nil,
    bufnr = nil,
    exited = false,
  }

  setmetatable(instance, self)
  return instance
end

function BaseCommand:isRunning()
  return self.job_id ~= nil and not self.exited
end

function BaseCommand:stop()
  if self.job_id then
    vim.fn.jobstop(self.job_id)
  end
end

function BaseCommand:execute()
  error("execute method not implemented")
end
function BaseCommand:restart()
  self:stop()
  vim.defer_fn(function()
    self:execute()
  end, 100)
end

return BaseCommand
