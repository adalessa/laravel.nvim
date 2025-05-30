local Class = require("laravel.utils.class")

---@class laravel.dto.history
---@field jobId string
---@field name string
---@field args table
---@field opts table

---@class laravel.service.history
---@field list laravel.dto.history[]
local history = Class({}, {
  list = {}
})

function history:add(jobId, name, args, opts)
  table.insert(self.list, {
    jobId = jobId,
    name = name,
    args = args,
    opts = opts,
  })
end

---@return laravel.dto.history[]
function history:get()
  return self.list
end

return history
