local promise = require("promise")

local models = {}

function models:new(tinker)
  local instance = {
    tinker = tinker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function models:all()
  return self.tinker:json([[
    use Illuminate\Support\Collection;
    use Symfony\Component\Finder\Finder;

    $modelPath = is_dir(app_path('Models')) ? app_path('Models') : app_path();

    echo json_encode((new Collection(Finder::create()->files()->depth(0)->in($modelPath)))
        ->map(fn ($file) => [ 'name' => $file->getBasename('.php'), 'path' => $file->getRealPath()])
        ->sort()
        ->values()
        ->all());
  ]]):thenCall(nil, function (err)
    return promise.reject(
      string.format(
        "Failed to get models: %s",
        err
      )
    )
  end)
end

return models
