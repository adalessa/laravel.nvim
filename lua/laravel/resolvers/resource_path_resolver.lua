local api = require "laravel.api"

local resource_path_resolve = {}

---@param resource string
---@param onSuccess fun(path: string)|nil
---@param onFailure fun(errorMessage: string)|nil
function resource_path_resolve.resolve(
  resource,
  onSuccess,
  onFailure
)
  api.async("artisan", { "tinker", "--execute", string.format("echo resource_path('%s');", resource) },
    function(response)
      if onSuccess then onSuccess(response:prettyContent()) end
    end, function(errResponse)
      if onFailure then onFailure(errResponse:prettyErrors()) end
    end)
end

return resource_path_resolve
