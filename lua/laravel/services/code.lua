local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local md5 = require("laravel.utils.md5")
local app = require("laravel.core.app")

local vendor_dir = "vendor"
local dir = vendor_dir .. "/nvim-laravel/"

---@class laravel.services.code
---@field api laravel.services.api
local codeService = Class({
  api = "laravel.services.api",
})

---@async
---@param name string
---@return table|nil, laravel.error
function codeService:fromTemplate(name)
  local ok, c = pcall(require, "laravel.php-templates." .. name)
  if not ok then
    return nil, Error:new("Could not find code template: " .. name)
  end

  return self:run(c)
end

---@async
---@param code string
---@return table, laravel.error
function codeService:run(code)
  local full = self:make_php_file(code, "laravel-bootstrap")

  local res, err = self.api:run("php", { full })
  if err then
    return {}, Error:new("Error running the php file " .. full):wrap(err)
  end

  if res:failed() then
    return {}, Error:new("PHP code execution failed: " .. res:prettyErrors())
  end

  local result = table.concat(res:raw(), "")
  -- need to parse to remove the  START_OUTPUT and  END_OUTPUT
  result = result:match("__NEOVIM_LARAVEL_START_OUTPUT__%s*(.-)%s*__NEOVIM_LARAVEL_END_OUTPUT__")

  if not result or result == "" then
    return {}, Error:new("Invalid or empty PHP output while running code file:" .. full)
  end

  local ok, decoded = pcall(vim.json.decode, result, { luanil = { object = true } })
  if not ok then
    return {}, Error:new("Could not parse PHP output: " .. decoded)
  end

  return decoded, nil
end

-- Generate a PHP file from a template and code snippet for PTY execution.
-- Can be easily extended to add more templates in the future (see template param).
--- @param code string: The code snippet to inject
--- @param template string?: The php-templates module to use (defaults to 'tinker')
--- @return string Full path to generated PHP file (will not execute it)
function codeService:make_php_file(code, template)
  template = template or "tinker"
  -- Future extensibility: add/replace templates for custom behaviors
  local ok, tpl = pcall(require, "laravel.php-templates." .. template)
  if not ok or type(tpl) ~= "string" then
    error("Could not load PHP template: " .. tostring(template))
  end
  local output = tpl:gsub("__NVIM_LARAVEL_OUTPUT__", code)

  local pre_script = app:make("laravel.services.code.pre_script")

  if type(pre_script) == "function" then
    pre_script = pre_script()
  end

  if type(pre_script) ~= "string" then
    pre_script = ""
  end

  output = output:gsub("__NVIM_LARAL_PRE_BOOTSTRAP__", pre_script)

  local hash = md5.sumhexa(output)
  local fname = hash .. "." .. template .. ".php"
  local full = dir .. fname
  local file_stats = vim.uv.fs_stat(full)
  if not (file_stats and file_stats.size > 0) then
    -- Keep this synchronous: several passive features can request a file for
    -- different buffers at the same time and concurrent async file/descriptor
    -- handling can crash Neovim's event loop.
    for _, path in ipairs({ vendor_dir, dir }) do
      if not vim.uv.fs_stat(path) then
        local ok, err = vim.uv.fs_mkdir(path, 493) -- 0755
        if not ok and not (err and vim.startswith(err, "EEXIST")) then
          error("Could not create directory " .. path .. ": " .. tostring(err))
        end
      end
    end

    local file, err = io.open(full, "w")
    if not file then
      error("Could not create php file for " .. fname .. ": " .. tostring(err))
    end
    file:write("<?php\n")
    file:write(output)
    file:close()
  end

  return full
end

return codeService
