--TODO: add missing fields
---@class LaravelCommand

---@class LaravelCommandProvider
---@field api LaravelApi
local commands = {}

local parse = function(json)
  local cmds = {}

  if json == "" or json == nil or #json == 0 then
    return cmds
  end

  return vim.tbl_filter(function (command)
    return not command.hidden
  end, vim.fn.json_decode(json).commands)
end

function commands:new(api)
  local instance = setmetatable({}, { __index = commands })
  instance.api = api
  return instance
end

---@param callback fun(commands: Iter<LaravelCommand>)
function commands:get(callback)
  self.api:async("artisan", { "list", "--format=json" }, function(result)
    if result:failed() then
      vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
      return
    end
    callback(vim.iter(parse(result.stdout)))
  end)
end

return commands
