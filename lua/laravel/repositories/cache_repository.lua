local table = require("laravel.db").cache

---@class CacheRepository
local CacheRepository = {}

---@class CacheRecord
---@field id integer|nil
---@field path string
---@field key string
---@field value table
---@field expire_at integer

---@param id integer
---@return CacheRecord|nil
function CacheRepository:find(id)
  ---@diagnostic disable-next-line: missing-fields
  local records = table:get({ where = { id = id } })

  if #records == 0 then
    return nil
  end

  return records[1]
end

---@return CacheRecord[]
function CacheRepository:findAll()
  ---@diagnostic disable-next-line: missing-parameter
  return table:get()
end

---@param condition table
---@return CacheRecord[]
function CacheRepository:findBy(condition)
  ---@diagnostic disable-next-line: missing-fields
  return table:get({ where = condition })
end

---@param record CacheRecord
---@return CacheRecord
function CacheRepository:save(record)
  local id = table:insert(record)
  record.id = id

  return record
end

---@param record CacheRecord
---@return boolean
function CacheRepository:update(record)
  return table:update({
    where = {
      id = record.id,
    },
    set = record,
  })
end

---@param id integer
---@return boolean
function CacheRepository:delete(id)
  ---@diagnostic disable-next-line: assign-type-mismatch
  return table:remove({ id = id })
end

---@return number
function CacheRepository:count()
  return table:count()
end

---@param condition table
---@return boolean
function CacheRepository:exists(condition)
  ---@diagnostic disable-next-line: missing-fields
  local records = table:get({ where = condition })

  return #records > 0
end

---@param condition table
---@return boolean
function CacheRepository:deleteBy(condition)
  return table:remove(condition)
end

return CacheRepository
