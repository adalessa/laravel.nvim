local M = {}

---@param opts table|nil
---@return table
M.setup = function(opts)
  opts = opts or {}

  local container = opts.container_name or "app"

  local cmd = opts.cmd or { "docker", "compose", "exec", "-it", container }

  local function get_cmd()
    return unpack(cmd)
  end

  return {
    -- list of executables to be use
    executables = {
      artisan = opts.artisan or { get_cmd(), "php", "artisan" },
      composer = opts.composer or { get_cmd(), "composer" },
      npm = opts.npm or { get_cmd(), "npm" },
      yarn = opts.yarn or { get_cmd(), "yarn" },
      compose = opts.compose or { "docker", "compose" },
    },
  }
end

return M
