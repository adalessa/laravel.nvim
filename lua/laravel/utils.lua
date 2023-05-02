local utils = {}

---@param funname string
---@param opts table
function utils.notify(funname, opts)
  local level = vim.log.levels[opts.level]
  if not level then
    error("Invalid error level", 2)
  end
  local body = string.format("[laravel.%s]: %s", funname, opts.msg)
  if opts.raw ~= nil then
    body = opts.raw
  end
  vim.notify(body, level, {
    title = "Laravel.nvim",
  })
end

utils.get_visual_selection = function()
  local sel = utils.get_vsel()
  return vim.api.nvim_buf_get_lines(sel.bufnr, sel.pos[1] - 1, sel.pos[3], false)
end

utils.get_vsel = function()
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

utils.get_env = function(var)
  if vim.fn.exists "*DotenvGet" == 1 then
    return vim.fn.DotenvGet(var)
  else
    return vim.fn.eval("$" .. var)
  end
end

return utils
