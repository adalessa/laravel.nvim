local utils = require "laravel.utils"
local docker_compose = {}

local commands = {
  npm = "docker-compose exec %s",
  artisan = "docker-compose exec %s php",
  container = "docker-compose",
  yarn = "docker-compose exec %s",
  composer = "docker-compose exec %s",
}

docker_compose.is_applicable = function()
  return vim.fn.filereadable "docker-compose.yml" == 1
end

function docker_compose:new(settings)
  local env = { settings = settings }
  setmetatable(env, self)
  self.__index = self
  return env
end

function docker_compose:is_running()
  return self:build_cmd("container", "ps")
end

function docker_compose:build_cmd(command_type, command)
  -- TODO we could try getting container_name from .env file
  if self.settings.container_name ~= nil then
    return string.format(commands[command_type], self.settings.container_name) .. " " .. command
  end
  utils.notify("docker-compose error", { msg = "Please specify container_name", level = "ERROR" })
  return nil
end

function docker_compose:up()
  return self:build_cmd(nil, "up -d")
end

return docker_compose
