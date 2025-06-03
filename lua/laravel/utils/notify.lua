local opts = {
  title = "Laravel.nvim",
}

local M = {}

function M.info(message)
  if type(message) ~= "string" then
    message = vim.inspect(message)
  end
  vim.notify(message, vim.log.levels.INFO, opts)
end

function M.warn(message)
  if type(message) ~= "string" then
    message = vim.inspect(message)
  end
  vim.notify(message, vim.log.levels.WARN, opts)
end

function M.error(message)
  if type(message) ~= "string" then
    message = vim.inspect(message)
  end
  vim.notify(message, vim.log.levels.ERROR, opts)
end

return M
