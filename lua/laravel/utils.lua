local utils = {}

local get_cmd = function()
  if require("laravel").app.environment.uses_sail then
    return "vendor/bin/sail"
  end

  return "php"
end

function utils.notify(funname, opts)
  local level = vim.log.levels[opts.level]
  if not level then
    error("Invalid error level", 2)
  end
  local body = string.format("[laravel.%s]: %s", funname, opts.msg)
  if opts.raw ~= nil then
    body = opts.raw
  end
  vim.notify(body, level, {
    title = "Laravel.nvim",
  })
end

---Gets the artisan command
---@param cmd table
---@return table
function utils.get_artisan_cmd(cmd)
  if type(cmd) ~= "table" then
    utils.notify("utils.get_artisan_cmd", {
      msg = "cmd has to be a table",
      level = "ERROR",
    })
    return {}
  end
  local out_cmd = vim.fn.deepcopy(cmd)

  table.insert(out_cmd, 1, get_cmd())
  table.insert(out_cmd, 2, "artisan")

  return out_cmd
end

return utils
