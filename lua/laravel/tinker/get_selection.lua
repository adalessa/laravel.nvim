local function get_vsel()
  local bufnr = vim.api.nvim_win_get_buf(0)
  local start = vim.fn.getpos "v" -- [bufnum, lnum, col, off]
  local _end = vim.fn.getpos "." -- [bufnum, lnum, col, off]
  if start[2] > _end[2] then
    local x = _end
    _end = start
    start = x
  end
  return {
    bufnr = bufnr,
    mode = vim.fn.mode(),
    pos = { start[2], start[3], _end[2], _end[3] },
  }
end

return function()
  local sel = get_vsel()
  return vim.api.nvim_buf_get_lines(sel.bufnr, sel.pos[1] - 1, sel.pos[3], false)
end
