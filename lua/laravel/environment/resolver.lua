local get_env = require "laravel.environment.get_env"

---@param env_check boolean
---@param auto_discovery boolean
---@param default string|nil
return function(env_check, auto_discovery, default)
  return function(environments)
    local env_name = get_env "NVIM_LARAVEL_ENV"
    if env_check and env_name ~= nil then
      local environment = environments[env_name]
      if environment == nil then
        vim.notify(
          "NVIM_LARAVEL_ENV defined as " .. env_name .. " but there is no such environment defined",
          vim.log.levels.ERROR
        )
        return nil
      else
        return environment
      end
    end

    if auto_discovery then
      -- check for sail
      if
        environments.sail ~= nil
        and vim.fn.filereadable "vendor/bin/sail" == 1
        and vim.fn.filereadable "docker-compose.yml" == 1
      then
        return environments.sail
      end
      -- check for docker-compose
      if
        environments["docker-compose"] ~= nil
        and vim.fn.filereadable "docker-compose.yml" == 1
        and vim.fn.executable "docker"
      then
        return environments["docker-compose"]
      end
      -- check for native
      if environments["local"] ~= nil and vim.fn.executable "php" then
        return environments["local"]
      end
    end

    if default then
      local environment = environments[default]
      if environment == nil then
        vim.notify("Default define as " .. default .. " but there is no environment define", vim.log.levels.ERROR)
        return nil
      else
        return environment
      end
    end

    vim.notify("Could not resolve any environment please check your configuration", vim.log.levels.ERROR)
    return nil
  end
end
