return function (funname, opts)
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
