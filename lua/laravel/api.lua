local Job = require "plenary.job"
local environment = require "laravel.environment"

local M = {}

local function generate_command(name, args)
  local executable = environment.get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
  end

  return vim.fn.extend(executable, args)
end

function M.sync(program, args)
  local cmd = generate_command(program, args)

  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()

  return {
    stdout = stdout,
    exit_code = ret,
    stderr = stderr,
  }
end

function M.async(program, args, callback)
  local cmd = generate_command(program, args)

  local command = table.remove(cmd, 1)
  Job:new({
    command = command,
    args = cmd,
    on_exit = vim.schedule_wrap(callback),
  }):start()
end

return M
