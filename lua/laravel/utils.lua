local utils = {}

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

utils.get_visual_selection = function ()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  return vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
end

return utils
