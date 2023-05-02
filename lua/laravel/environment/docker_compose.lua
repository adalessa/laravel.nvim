local utils = require "laravel.utils"

local M = {}

---@param opts table|nil
---@return table
M.setup = function(opts)
  opts = opts or {}

  local container = opts.container_name or utils.get_env "APP_SERVICE" or "app"

  local cmd = opts.cmd or { "docker", "compose", "exec", "-it", container }

  local function get_cmd(args)
    return vim.fn.extend(cmd, args)
  end

  local executables = {
    artisan = opts.artisan or get_cmd { "php", "artisan" },
    composer = opts.composer or get_cmd { "composer" },
    npm = opts.npm or get_cmd { "npm" },
    yarn = opts.yarn or get_cmd { "yarn" },
    php = opts.php or get_cmd { "php" },
    compose = opts.compose or { "docker", "compose" },
  }

  return {
    executables = vim.tbl_deep_extend("force", executables, opts.executables or {}),
  }
end

return M
