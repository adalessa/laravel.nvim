---@class laravel.cache_manager
local cache_manager = {
    items = {},
}

--- Gets item from the cache
---@param key string
---@param default any
cache_manager.get = function(key, default)
    if cache_manager.items[key] == nil then
        if type(default) == "function" then
            cache_manager.items[key] = default()
        else
            cache_manager.items[key] = default
        end
    end

    return cache_manager.items[key]
end

--- Puts an Item in the cache
---@param key string
---@param value any
cache_manager.put = function(key, value)
    cache_manager.items[key] = value
end

--- Forgets an item from the cache
---@param key string
cache_manager.forget = function(key)
    cache_manager.items[key] = nil
end

--- Purge all items from the cache
cache_manager.purge = function()
    cache_manager.items = {}
end

return cache_manager
