local promise = require("promise")

---@class LaravelModelService
---@field class LaravelClassService
---@field tinker Tinker
---@field api LaravelApi
local model = {}

function model:new(tinker, class, api)
  local instance = {
    tinker = tinker,
    class = class,
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function model:all()
  return self.tinker:json([[
    use Illuminate\Support\Collection;
    use Symfony\Component\Finder\Finder;

    $modelPath = is_dir(app_path('Models')) ? app_path('Models') : app_path();

    echo json_encode((new Collection(Finder::create()->files()->depth(0)->in($modelPath)))
        ->map(fn ($file) => [ 'name' => $file->getBasename('.php'), 'path' => $file->getRealPath()])
        ->sort()
        ->values()
        ->all());
  ]])
end

function model:getByBuffer(bufnr)
  return self.class:get(bufnr):thenCall(function(class)
    return self.tinker
      :json(string.format(
        [[
            $r = new ReflectionClass("%s");
            $isModel = $r->isSubclassOf("Illuminate\Database\Eloquent\Model");
            echo json_encode([
              'is_model' => $isModel,
              'class_start' => $r->getStartLine(),
            ]);
          ]],
        class.fqn
      ))
      :thenCall(function(res)
        if not res.is_model then
          return promise.reject("class is not a model")
        end

        return self:info(class.fqn):thenCall(function(info)
          info.start = res.class_start
          info.class_info = class

          return info
        end)
      end)
  end)
end

---@param fqn string
---@return Promise
function model:info(fqn)
  return self.api:send("artisan", { "model:show", "--json", string.format("\\%s", fqn) }):thenCall(function(result)
    local info = result:json()

    if not info then
      return promise.reject("info is not json")
    end

    return info
  end)
end

return model
