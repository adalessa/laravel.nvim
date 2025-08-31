---@class LaravelEnvironmentConfig
---@field name string
---@field map table<string, string[]>

---@class LaravelOptionsEnvironments
---@field env_variable string
---@field default string
---@field definitions LaravelEnvironmentConfig[]
return {
  env_variable = "NVIM_LARAVEL_ENV",
  default = "local",
  definitions = {
    {
      name = "sail",
      map = {
        php = { "vendor/bin/sail", "php" },
        composer = { "vendor/bin/sail", "composer" },
        npm = { "vendor/bin/sail", "npm" },
        yarn = { "vendor/bin/sail", "yarn" },
      },
    },
    {
      name = "docker-compose",
      map = {
        php = { "docker", "compose", "exec", "-it", "app", "php" },
        composer = { "docker", "compose", "exec", "-it", "app", "composer" },
        npm = { "docker", "compose", "exec", "-it", "app", "npm" },
        yarn = { "docker", "compose", "exec", "-it", "app", "yarn" },
      },
    },
    {
      name = "herd",
      map = {
        php = { "herd", "php" },
        composer = { "herd", "composer" },
      },
    },
    {
      name = "symfony",
      condition = {
        executable = { "symfony" },
      },
      commands = {
        symfony = { "symfony" },
        {
          commands = { "php", "composer" },
          prefix = { "symfony" },
        },
      },
    },
    {
      name = "local",
    },
  },
}
