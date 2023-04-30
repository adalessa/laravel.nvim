local environment = {}

---@param environments table
---@param resolver function
environment.initialize = function(environments, resolver)
  return resolver(environments)
end

return environment
