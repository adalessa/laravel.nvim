local repository = require "laravel.repositories.cache"

local default_expiriation = 600

local cache = {}

function cache:put(key, value, expire_on)
  local record = {
    path = vim.fn.getcwd(),
    key = key,
    value = value,
    expire_at = vim.fn.strftime("%s") + (expire_on or default_expiriation)
  }

  local records = repository:findBy({ path = vim.fn.getcwd(), key = key })
  if #records > 0 then
    record.id = records[1].id
    repository:update(record)
  else
    repository:save(record)
  end
end

function cache:get(key)
  local records = repository:findBy({
    key = key,
    path = vim.fn.getcwd(),
    expire_at = "> " .. vim.fn.strftime("%s")
  })

  if #records == 0 then
    return nil
  end

  return records[1].value
end

function cache:forget(key)
  local records = repository:findBy({
    key = key,
    path = vim.fn.getcwd(),
  })

  if #records == 0 then
    return
  end

  repository:delete(records[1].id)
end

function cache:has(key)
  return repository:exists({
    key = key,
    path = vim.fn.getcwd(),
    expire_at = "> " .. vim.fn.strftime("%s")
  })
end

function cache:flush()
  return repository:deleteBy({
    path = vim.fn.getcwd(),
  })
end

return cache
