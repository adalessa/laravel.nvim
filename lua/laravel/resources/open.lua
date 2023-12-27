local config = require "laravel.config"

return function(resource, name)
  local directory = config.options.resources[resource]
  local filename = ""
  if type(directory) == "function" then
    filename = directory(name)
  elseif type(directory) == "string" then
    filename = string.format("%s/%s.php", directory, name)
  end

  if vim.fn.findfile(filename) then
    local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
    local buffer = vim.uri_to_bufnr(uri)
    vim.api.nvim_win_set_buf(0, buffer)

    return
  end

  vim.notify(string.format("Can't find resource %s", filename), vim.log.levels.INFO)
end
