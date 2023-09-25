local get_env = require "laravel.environment.get_env"

local M = {}

---@param opts table|nil
---@return function
M.setup = function(opts)
  return function()
    opts = opts or {}

    local container = get_env "APP_SERVICE" or opts.container_name or "app"

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
end

return M
