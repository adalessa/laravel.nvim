local nio = require("nio")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local boostrap = require("laravel.php-templates.laravel-bootstrap")
local md5 = require("laravel.utils.md5")

local dir = "vendor/nvim-laravel/"

---@class laravel.services.code
---@field api laravel.services.api
local code = Class({
  api = "laravel.services.api",
})

-- TODO: add take templates with variables

---@async
---@param name string
---@return table|nil, laravel.error
function code:fromTemplate(name)
  local ok, c = pcall(require, "laravel.php-templates." .. name)
  if not ok then
    return nil, Error:new("Could not find code template: " .. name)
  end

  return self:run(c)
end

---@async
---@param code string
---@return table, laravel.error
function code:run(code)
  local f = boostrap:gsub("__NVIM_LARAVEL_OUTPUT__", code)

  local n = md5.sumhexa(f)

  local fname = n .. ".php"
  local full = dir .. fname

  -- check if the file exists
  local _, file_stats = nio.uv.fs_stat(full)
  if not file_stats then
    local _, dir_stats = nio.uv.fs_stat(dir)
    if not dir_stats then
      local _, ok = nio.uv.fs_mkdir(dir, 493) -- 0755
      if not ok then
        return {}, Error:new("Could not create directory for php files: " .. dir)
      end
    end
    ---@diagnostic disable-next-line: param-type-mismatch
    local file = nio.file.open(full, "w+")
    if not file then
      return {}, Error:new("Could not create php file for " .. fname)
    end
    file.write("<?php\n")
    file.write(f)
    file.close()
  end

  local res, err = self.api:run("php", { full })
  if err then
    return {}, Error:new("Error running the php file " .. fname):wrap(err)
  end

  if res:failed() then
    return {}, Error:new("PHP code execution failed: " .. res:prettyErrors())
  end

  local result = table.concat(res:raw(), "")
  -- need to parse to remove the  START_OUTPUT and  END_OUTPUT
  result = result:match("__NEOVIM_LARAVEL_START_OUTPUT__%s*(.-)%s*__NEOVIM_LARAVEL_END_OUTPUT__")

  if not result or result == "" then
    return {}, Error:new("Invalid or empty PHP output while running code")
  end

  local ok, decoded = pcall(vim.json.decode, result, { luanil = { object = true } })
  if not ok then
    return {}, Error:new("Could not parse PHP output: " .. decoded)
  end

  return decoded, nil
end

return code
