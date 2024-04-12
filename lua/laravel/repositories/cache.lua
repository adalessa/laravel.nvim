local db = require "laravel.db"

---@class CacheRepository
---@field _table CacheTable
local CacheRepository = {}

---@class CacheRecord
---@field id integer|nil
---@field path string
---@field key string
---@field value string
---@field expiration integer

---@param table CacheTable
---@return CacheRepository
function CacheRepository:new(table)
  local obj = {
    _table = table
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

---@param id integer
---@return CacheRecord|nil
function CacheRepository:find(id)
  ---@diagnostic disable-next-line: missing-fields
  local records = self._table:get { where = { id = id } }

  if #records == 0 then
    return nil
  end

  return records[1]
end

---@return CacheRecord[]
function CacheRepository:findAll()
  ---@diagnostic disable-next-line: missing-parameter
  return self._table:get()
end

---@param condition table
---@return CacheRecord[]
function CacheRepository:findBy(condition)
  ---@diagnostic disable-next-line: missing-fields
  return self._table:get({ where = condition })
end

---@param record CacheRecord
---@return CacheRecord
function CacheRepository:save(record)
  local id = self._table:insert(record)
  record.id = id

  return record
end

---@param record CacheRecord
---@return boolean
function CacheRepository:update(record)
  return self._table:update {
    where = {
      id = record.id,
    },
    set = record,
  }
end

---@param id integer
---@return boolean
function CacheRepository:delete(id)
  ---@diagnostic disable-next-line: assign-type-mismatch
  return self._table:remove({ id = id })
end

---@return number
function CacheRepository:count()
  return self._table:count()
end

---@param condition table
---@return boolean
function CacheRepository:exists(condition)
  ---@diagnostic disable-next-line: missing-fields
  local records = self._table:get({ where = condition })

  return #records > 0
end

return CacheRepository:new(db.cache)
