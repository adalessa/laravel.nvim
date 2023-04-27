local runners = require "laravel.runners"

local artisan = {}

local function tinker(result)
  require("laravel").app.set("tinker", result.term_id)
  vim.api.nvim_create_autocmd({ "BufDelete" }, {
    buffer = result.buff,
    callback = function()
      require("laravel").app.set("tinker", nil)
    end,
  })
  -- add autoocmd to delete from storage when buffer is delted
end

--- Runs a command in the given runner on the default one
---@param cmd table
---@param runner string|nil
---@param opts table | nil
---@return table, boolean
artisan.run = function(cmd, runner, opts)
  local laravel = require("laravel").app

  local command = cmd[1]
  opts = opts or {}
  runner = runner
    or laravel.options.commands_runner[cmd[1]]
    or laravel.options.default_runner

  table.insert(cmd, 1, "artisan")

  local data, ok = laravel.run("artisan", cmd, runner, opts)
  if not ok then
    return {}, false
  end

  if command == "tinker" then
    tinker(data)
  end

  return data, true
end

return artisan
