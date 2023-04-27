local M = {}

M.is_applicable = function()
  -- TODO add some checks to see if application is runnable locally
  return true
end

function M:new(settings)
  local env = { settings = settings }
  setmetatable(env, self)
  self.__index = self
  return env
end

function M:build_cmd(command_type, command)
  if command_type == "container" then
    return nil
  end
  return command
end

function M:is_running()
  return true
end

return M
