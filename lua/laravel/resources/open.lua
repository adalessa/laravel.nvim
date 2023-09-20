local config = require "laravel.config"
local notify = require "laravel.notify"

return function(resource, name)
  local directory = config.options.resources[resource]
  local filename = ""
  if type(directory) == "function" then
    local err
    filename, err = directory(name)
    if err ~= nil then
      notify("Resource.Open", { level = "ERROR", msg = "Error getting the name" })
      return
    end
    filename = filename[1]
  elseif type(directory) == "string" then
    filename = string.format("%s/%s.php", directory, name)
  end

  if vim.fn.findfile(filename) then
    local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
    local buffer = vim.uri_to_bufnr(uri)
    vim.api.nvim_win_set_buf(0, buffer)

    return
  end

  notify("Resource.Open", {
    msg = string.format("Can't find resource %s", filename),
    level = "INFO",
  })
end
