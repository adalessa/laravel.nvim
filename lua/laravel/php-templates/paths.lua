return [[
  $base = base_path();
  $app = app_path();
  $views = resource_path("views");
  $resources = resource_path();
  $public = public_path();
  $storage = storage_path();
  $config = config_path();

  echo json_encode([
    "base" => $base,
    "app" => $app,
    "views" => $views,
    "resources" => $resources,
    "public" => $public,
    "storage" => $storage,
    "config" => $config,
  ]);
]]
