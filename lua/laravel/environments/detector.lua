local detector = {}

detector.get_environment = function(order, settings)
  for _, env in ipairs(order) do
    local env_module = require("laravel.environments." .. env)
    if env_module:is_applicable() then
      return env_module:new(settings)
    end
  end
  return nil
end

return detector
