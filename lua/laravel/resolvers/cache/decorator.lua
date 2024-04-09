local cache = require "laravel.cache"

return function(decorated, key, onSuccess, onFailure)
  if cache:has(key) then
    if onSuccess then
      onSuccess(cache:get(key))
    end
    return
  end

  decorated.resolve(
    function(result)
      cache:put(key, result)
      if onSuccess then
        onSuccess(result)
      end
    end,
    onFailure
  )
end
