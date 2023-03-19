---@class split
---@field cmd string
---@field width integer
local split = {
  cmd = "vertical",
  width = 120,
}

---@class laravel.config
---@field split split
---@field bind_telescope boolean
---@field ask_for_args boolean
---@field default_runner string
---@field resources table
---@field register_user_commands boolean
---@field commands_runner table
---@field route_info boolean
local config = {
  split = split,
  bind_telescope = true,
  ask_for_args = true,
  register_user_commands = true,
  route_info = true,
  default_runner = "buffer",
  commands_runner = {
    ["dump-server"] = "terminal",
    ["db"] = "terminal",
    ["tinker"] = "terminal",
  },
  resources = {
    cast = "app/Casts",
    channel = "app/Broadcasting",
    command = "app/Console/Commands",
    component = "app/View/Components",
    controller = "app/Http/Controllers",
    event = "app/Events",
    exception = "app/Exceptions",
    factory = function(name)
      return string.format("database/factories/%sFactory.php", name), nil
    end,
    job = "app/Jobs",
    listener = "app/Listeners",
    mail = "app/Mail",
    middleware = "app/Http/Middleware",
    migration = function(name)
      local result = require("laravel.runners").sync { "fd", name .. ".php" }
      if result.exit_code == 1 then
        return "", result.error
      end

      return result.out, nil
    end,
    model = "app/Models",
    notification = "app/Notifications",
    observer = "app/Observers",
    policy = "app/Policies",
    provider = "app/Providers",
    request = "app/Http/Requests",
    resource = "app/Http/Resources",
    rule = "app/Rules",
    scope = "app/Models/Scopes",
    seeder = "database/seeders",
    test = "tests/Feature",
  },
}

return config
