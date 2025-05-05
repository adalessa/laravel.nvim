local promise = require("promise")
local split = require("laravel.utils").split
local a = require("plenary.async")

---@class laravel.repositories.environment_variables_repository
local repository = {}

local read_file = function(path)
  local err, fd = a.uv.fs_open(path, "r", 438)
  assert(not err, err)

  local err, stat = a.uv.fs_fstat(fd)
  assert(not err, err)

  local err, data = a.uv.fs_read(fd, stat.size, 0)
  assert(not err, err)

  local err = a.uv.fs_close(fd)
  assert(not err, err)

  return data
end

-- TODO move to a repository since read content of the project
function repository:all()
  return promise:new(function(resolve, reject)
    a.run(function()
      local data = read_file(".env")

      return vim
        .iter(vim.split(data, "\n"))
        :filter(function(line)
          return line ~= "" and not vim.startswith(line, "#")
        end)
        :map(function(line)
          local spl = split(line, "=")

          return {
            key = spl[1],
            value = spl[2],
          }
        end)
        :totable()
    end, function(data)
      resolve(data)
    end)
  end)
end

function repository:get(key)
  return self:all():thenCall(function(envs)
    for _, env in ipairs(envs) do
      if env.key == key then
        return env.value
      end
    end

    return nil
  end)
end

return repository
