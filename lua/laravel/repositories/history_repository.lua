local table = require("laravel.db").history

---@class HistoryRepository
local HistoryRepository = {}

---@class HistoryRecord
---@field id integer|nil
---@field path string
---@field jobId integer
---@field name string
---@field args table
---@field opts table
---@field created_on integer|nil

---@param record HistoryRecord
---@return HistoryRecord
function HistoryRepository:save(record)
  local id = table:insert(record)
  record.id = id

  return record
end

---@return HistoryRecord[]
function HistoryRepository:findAll()
  ---@diagnostic disable-next-line: missing-parameter
  return table:get()
end

---@param condition table
---@return boolean
function HistoryRepository:deleteBy(condition)
  return table:remove(condition)
end

return HistoryRepository
