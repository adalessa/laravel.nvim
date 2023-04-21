local environment = {}

---@param environments table
---@param resolver function
environment.initialize = function(environments, resolver)
  if vim.fn.filereadable "artisan" ~= 1 then
    return nil
  end

  return resolver(environments)
end

return environment
