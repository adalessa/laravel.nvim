local sqlite = require "sqlite.db"
local tbl = require "sqlite.tbl"

local uri = vim.fn.stdpath("cache") .. '/laravel_db.sqlite'

---@class CacheTable: sqlite_tbl

---@class LaravelDatabase: sqlite_db
---@field cache CacheTable

---@type CacheTable
local cache = tbl("cache", {
  id = true,
  path = "text",
  key = "text",
  value = "luatable",
  expire_at = { "timestamp" },
})

---@type LaravelDatabase
local DB = sqlite {
  uri = uri,
  cache = cache,
}

return DB
