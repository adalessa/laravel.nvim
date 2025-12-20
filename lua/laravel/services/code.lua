local nio = require("nio")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local boostrap = require("laravel.php-templates.laravel-bootstrap")
local md5 = require("laravel.utils.md5")

local dir = "vendor/nvim-laravel/"

---@class laravel.services.code
local code = Class({
  api = "laravel.services.api",
})

---@async
function code:run(name)
  local ok, c = pcall(require, "laravel.php-templates." .. name)
  if not ok then
    return nil, Error:new("Could not find code template: " .. name)
  end

  local f = boostrap:gsub("__NVIM_LARAVEL_OUTPUT__", c)

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
        return nil, Error:new("Could not create directory for php files: " .. dir)
      end
    end
    local file = nio.file.open(full, "w+")
    if not file then
      return nil, Error:new("Could not create php file for " .. name)
    end
    file.write("<?php\n")
    file.write(f)
    file.close()
  end

  local res, err = self.api:run("php", { full })
  if err then
    return nil, Error:new("Error running the php file for " .. name):wrap(err)
  end

  if res:failed() then
    return nil, Error:new("PHP code execution failed for " .. name .. ": " .. res:prettyErrors())
  end

  local result = table.concat(res:raw(), "")
  -- need to parse to remove the  START_OUTPUT and  END_OUTPUT
  result = result:match("__NEOVIM_LARAVEL_START_OUTPUT__%s*(.-)%s*__NEOVIM_LARAVEL_END_OUTPUT__")

  return vim.json.decode(result, { luanil = { object = true } }), nil
  -- return result, nil
end

return code
