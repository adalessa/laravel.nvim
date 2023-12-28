local config = require "laravel.config"

return function(resource)
  return config.options.resources[resource] ~= nil
end
