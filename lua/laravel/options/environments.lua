---@class LaravelEnvironmentConfig
---@field name string
---@field map table<string, string[]>

---@class LaravelOptionsEnvironments
---@field default string
---@field ask_on_boot boolean
---@field definitions LaravelEnvironmentConfig[]
return {
  ask_on_boot = false,
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
      name = "valet",
      map = {
        php = { "valet", "php" },
        composer = { "valet", "composer" },
      },
    },
    {
      name = "symfony",
      map = {
        php = { "symfony", "php" },
        composer = { "symfony", "composer" },
      },
    },
    {
      name = "local",
    },
  },
}
