---@class laravel.core.health
---@field status "unknown"|"healthy"|"broken"|"unavailable"
---@field error string|nil
local health = {
  status = "unknown",
  error = nil,
}

local unavailable_patterns = {
  "is not running",
  "Cannot connect to the Docker daemon",
  "Cannot connect to the Docker",
  "no configuration file provided",
  "is not a docker command",
  "permission denied while trying to connect to the Docker daemon",
}

local broken_patterns = {
  "PHP Parse error",
  "PHP Fatal error",
  "ParseError",
  "syntax error",
  "Uncaught Error",
}

local function matches(message, patterns)
  if not message or message == "" then
    return false
  end

  for _, pattern in ipairs(patterns) do
    if message:find(pattern, 1, true) then
      return true
    end
  end

  return false
end

--- Reset the tracked health, for example after changing the environment.
function health.reset()
  health.status = "unknown"
  health.error = nil
end

--- Mark the environment as healthy after a successful Laravel command.
function health.markHealthy()
  health.status = "healthy"
  health.error = nil
end

--- Mark the application as broken when PHP cannot boot.
---@param message string|nil
function health.markBroken(message)
  if health.status == "unavailable" then
    return
  end

  health.status = "broken"
  health.error = message
end

--- Mark the environment as unavailable, for example when the container is stopped.
---@param message string|nil
function health.markUnavailable(message)
  health.status = "unavailable"
  health.error = message
end

--- Inspect the stderr of a failed command and update the health accordingly.
---@param message string|nil
function health.recordFailure(message)
  if matches(message, unavailable_patterns) then
    health.markUnavailable(message)
    return
  end

  if matches(message, broken_patterns) then
    health.markBroken(message)
  end
end

---@return boolean
function health.isUnavailable()
  return health.status == "unavailable"
end

---@return boolean
function health.isBroken()
  return health.status == "broken"
end

--- Passive features should not keep executing commands while the environment
--- is unavailable. The status probe (and user initiated commands) still run so
--- the health can recover once the container is started again.
---@return boolean
function health.shouldSkip()
  return health.status == "unavailable"
end

---@return string
function health.getStatus()
  return health.status
end

---@return string|nil
function health.getError()
  return health.error
end

return health
