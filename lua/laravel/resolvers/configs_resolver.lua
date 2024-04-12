local api = require "laravel.api"

local views_resolver = {}

---@param onSuccess fun(configs: string[])|nil
---@param onFailure fun(errorMessage: string)|nil
function views_resolver.resolve(
  onSuccess,
  onFailure
)
  api.async("artisan", { "tinker", "--execute", "echo json_encode(array_keys(Arr::dot(Config::all())))" },
    function(response)
      local configs = vim.json.decode(response:prettyContent())

      if not configs then
        if onFailure then onFailure("no configs found") end
        return
      end

      if onSuccess then onSuccess(configs) end
    end,
    function(errResponse)
      if onFailure then onFailure(errResponse:prettyErrors()) end
    end
  )
end

return views_resolver
