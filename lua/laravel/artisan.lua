local runners = require "laravel.runners"

local artisan = {}

local function tinker(result)
  -- TODO: save term_id in storage
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
  local command = cmd[1]
  opts = opts or {}
  runner = runner
    or require("laravel").app.options.commands_runner[cmd[1]]
    or require("laravel").app.options.default_runner

  table.insert(cmd, 1, "artisan")

  local ok = require("laravel").app.if_uses_sail(function()
    table.insert(cmd, 1, "vendor/bin/sail")
  end, function()
    table.insert(cmd, 1, "php")
  end, opts.silent or false)

  if not ok then
    return {}, false
  end

  local result = runners[runner](cmd, opts)
  if command == "tinker" then
    tinker(result)
  end

  return result, true
end

return artisan
