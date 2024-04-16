local cache = require("laravel.services.cache_service")

return function(opts)
  if cache:has(opts.key) then
    if opts.onSuccess then
      opts.onSuccess(cache:get(opts.key))
    end
    return
  end

  local args = opts.args or {}

  table.insert(args, function(result)
    cache:put(opts.key, result)
    if opts.onSuccess then
      opts.onSuccess(result)
    end
  end)
  table.insert(args, opts.onFailure)

  opts.decorated.resolve(unpack(args))
end
