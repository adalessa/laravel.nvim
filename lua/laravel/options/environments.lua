---@class EnvironmentCondition
---@field file_exists string[]|nil
---@field executable string[]|nil

---@class LaravelEnvironmentConfig
---@field name string
---@field condition EnvironmentCondition
---@field commands table|nil

---@class LaravelOptionsEnvironments
---@field env_variable string
---@field auto_dicover boolean
---@field default string
---@field definitions LaravelEnvironmentConfig[]
return {
  env_variable = "NVIM_LARAVEL_ENV",
  auto_dicover = true,
  default = "local",
  definitions = {
    {
      name = "sail",
      condition = {
        file_exists = { "vendor/bin/sail", "docker-compose.yml" },
      },
      commands = {
        sail = { "vendor/bin/sail" },
        {
          commands = { "php", "composer", "npm", "yarn" },
          prefix = { "vendor/bin/sail" },
        },
      },
    },
    {
      name = "docker-compose",
      condition = {
        file_exists = { "docker-compose.yml" },
        executable = { "docker" },
      },
      commands = {
        compose = { "docker", "compose" },
        {
          commands = { "php", "composer", "npm" },
          docker = {
            container = {
              env = "APP_SERVICE",
              default = "app",
            },
            exec = { "docker", "compose", "exec", "-it" },
          },
        },
      },
    },
    {
      name = "herd",
      condition = {
        executable = { "herd" },
      },
      commands = {
        herd = { "herd" },
        {
          commands = { "php", "composer" },
          prefix = { "herd" },
        },
      },
    },
    {
      name = "local",
      condition = {
        executable = { "php" },
      },
    },
  },
}
