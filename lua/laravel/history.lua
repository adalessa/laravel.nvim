---@class LaravelHistory
---@field jobId string
---@field name string
---@field args table
---@field opts table

---@class LaravelHistoryService
---@field list LaravelHistory[]
local history = {}

function history:new()
  local instance = setmetatable({}, { __index = history })
  instance.list = {}
  return instance
end

function history:add(jobId, name, args, opts)
  table.insert(self.list, {
    jobId = jobId,
    name = name,
    args = args,
    opts = opts,
  })
end

---@return Iter<LaravelHistory>
function history:get()
  return vim.iter(self.list)
end

return history
