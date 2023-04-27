local env = {}

local commands = {
  "npm",
  "yarn",
  "artisan",
  "composer",
  "container",
  "is_running",
  "start",
}

function env.is_valid(settings)
  for _, command in ipairs(commands) do
    if settings[command] == nil then
      return false
    end
  end
  return true
end

function env:new(settings)
  if env.is_valid(settings) then
    self.__index = self
    setmetatable(settings, self)
    return self
  end
  return nil
end

function env:build_cmd(command_type, command)
  -- if command = false it wont be run
  if not self.settings[command_type] then
    return nil
  end
  return self.settings[command_type] .. " " .. command
end

function env:is_running()
  if not self.settings["is_running"] then
    return self:build_cmd("is_running", "")
  end
  return nil
end

return env
