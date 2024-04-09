local sqlite = require 'sqlite'

local timeout = 600

local db = sqlite {
  uri = vim.fn.stdpath("cache") .. '/laravel_db.sqlite',
  cache = {
    id = true,
    path = "text",
    key = "text",
    value = "luatable",
    created = { "timestamp", default = sqlite.lib.strftime("%s", "now") }
  }
}

local cache = db.cache


function cache:put(key, value)
  if cache:has(key) then
    cache:update {
      where = {
        path = vim.fn.getcwd(),
        key = key,
      },
      set = { value = value }
    }
  else
    cache:__insert {
      path = vim.fn.getcwd(),
      key = key,
      value = value
    }
  end
end

function cache:get(key)
  local hits = cache:__get({
    where = {
      key = key,
      path = vim.fn.getcwd(),
    },
    select = {
      "created",
      "value"
    }
  })

  if #hits == 0 then
    return nil
  end

  local hit = hits[1]

  if hit.created < (vim.fn.strftime("%s") - timeout) then
    cache:forget(key)

    return nil
  end

  return hit.value
end

function cache:forget(key)
  cache:remove {
    key = key,
    path = vim.fn.getcwd(),
  }
end

function cache:has(key)
  return cache:get(key) ~= nil
end

return cache
