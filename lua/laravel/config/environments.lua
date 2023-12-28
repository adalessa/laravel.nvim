return {
  env_variable = "NVIM_LARAVEL_ENV",
  auto_dicover = true,
  default = "local",
  definitions = {
    ["sail"] = {
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
    ["docker-compose"] = {
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
    ["local"] = {
      condition = {
        executable = { "php" },
      },
    },
  },
}
