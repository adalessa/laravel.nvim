local sail = {}

local env_command = "vendor/bin/sail"

sail.is_applicable = function()
  local has_sail_cmd = vim.fn.filereadable "vendor/bin/sail" == 1
  local has_docker_compose_config = vim.fn.filereadable "docker-compose.yml" == 1
  return has_docker_compose_config and has_sail_cmd
end

function sail:new(settings)
  local env = { settings = settings }
  setmetatable(env, self)
  self.__index = self
  return env
end

function sail:build_cmd(_, command)
  return env_command .. " " .. command
end

function sail:is_running()
  return self:build_cmd(nil, "ps")
end

function sail:up()
  return self:build_cmd(nil, "up -d")
end

return sail
