local M = {}

---@param opts table|nil
---@return table
M.setup = function(opts)
  opts = opts or {}

  local executables = {
    artisan = opts.artisan or { "php", "artisan" },
    composer = opts.composer or { "composer" },
    npm = opts.npm or { "npm" },
    yarn = opts.yarn or { "yarn" },
  }

  return {
    executables = vim.tbl_deep_extend("force", executables, opts.executables or {}),
  }
end

return M
