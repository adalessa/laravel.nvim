local M = {}

---@param opts table|nil
---@return table
M.setup = function(opts)
  opts = opts or {}

  local cmd = opts.cmd or { "vendor/bin/sail" }

  local function get_cmd()
    return unpack(cmd)
  end

  return {
    -- list of executables to be use
    executables = {
      artisan = opts.artisan or { get_cmd(), "artisan" },
      composer = opts.composer or { get_cmd(), "composer" },
      npm = opts.npm or { get_cmd(), "npm" },
      yarn = opts.yarn or { get_cmd(), "yarn" },
      sail = opts.sail or cmd,
    },
  }
end

return M
