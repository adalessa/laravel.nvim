local sqlite = require "sqlite.db"
local tbl = require "sqlite.tbl"

local uri = vim.fn.stdpath "cache" .. "/laravel_db.sqlite"

---@class CacheTable: sqlite_tbl
---@class HistoryTable: sqlite_tbl

---@class LaravelDatabase: sqlite_db
---@field cache CacheTable
---@field history HistoryTable

---@type CacheTable
local cache = tbl("cache", {
  id = true,
  path = "text",
  key = "text",
  value = "luatable",
  expire_at = "timestamp",
})

local history = tbl("history", {
  id = true,
  path = "text",
  jobId = "integer",
  name = "text",
  args = "luatable",
  opts = "luatable",
  created_on = { "timestampt", default = sqlite.lib.strftime("%s", "now") },
})

-- TODO: define fields for the environment
-- commands ? sail have a general prefix
-- local environment = tbl("environments", {
--   id = true,
--   path = "text",
-- })

---@type LaravelDatabase
local DB = sqlite {
  uri = uri,
  cache = cache,
  history = history,
}

return DB
