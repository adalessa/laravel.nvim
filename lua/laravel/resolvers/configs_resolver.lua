local api = require("laravel.api")

---@alias Config table<string, any>

local views_resolver = {}

---@param onSuccess fun(config: Config)|nil
---@param onFailure fun(errorMessage: string)|nil
function views_resolver.resolve(onSuccess, onFailure)
  api.async("artisan", { "tinker", "--execute", "echo json_encode(Arr::dot(Config::all()))" }, function(response)
    local configs = response:json()

    if not configs then
      if onFailure then
        onFailure("no configs found")
      end
      return
    end

    if onSuccess then
      onSuccess(configs)
    end
  end, function(errResponse)
    if onFailure then
      onFailure(errResponse:prettyErrors())
    end
  end)
end

return views_resolver
