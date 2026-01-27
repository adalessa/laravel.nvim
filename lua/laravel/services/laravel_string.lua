local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.laravel_string
---@field api laravel.services.api
local string_helper = Class({
  api = "laravel.services.api",
})

---@async
---@param text string
---@return string, laravel.error|nil
function string_helper:pluralize(text)
  local t = string.format([[require 'vendor/autoload.php'; echo Illuminate\Support\Str::plural('%s');]], text)
  local res, err = self.api:run("php", { "-r", t })
  if err then
    return "", Error:new("Error pluralizing string " .. text):wrap(err)
  end

  if not res:successful() then
    return "", Error:new("Error pluralizing string " .. text .. ": " .. res:prettyErrors())
  end

  local output = vim.trim(table.concat(res:raw(), ""))

  return output, nil
end

return string_helper
