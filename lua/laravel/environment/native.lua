local M = {}

---@param opts table|nil
---@return table
M.setup = function(opts)
  opts = opts or {}
  return {
    executables = {
      artisan = opts.artisan or { "php", "artisan" },
      composer = opts.composer or { "composer" },
      npm = opts.npm or { "npm" },
      yarn = opts.yarn or { "yarn" },
    },
  }
end

return M
