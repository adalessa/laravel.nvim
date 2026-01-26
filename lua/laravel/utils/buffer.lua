local M = {}

---@param bufnr number|nil
---@return boolean
function M.is_valid_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return false
  end

  local win = vim.fn.bufwinid(bufnr)
  if win ~= -1 then
    local win_type = vim.fn.win_gettype(win)
    if win_type ~= "" then
      return false -- Exclude non-standard windows like popup or preview windows
    end
  end

  return true
end

return M
