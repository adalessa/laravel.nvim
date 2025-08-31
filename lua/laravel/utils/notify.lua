local opts = {
  title = "Laravel.nvim",
}

local M = {}

local notify = function(message, level)
  if type(message) ~= "string" then
    message = vim.inspect(message)
  end
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

function M.info(message)
  notify(message, vim.log.levels.INFO)
end

function M.warn(message)
  notify(message, vim.log.levels.WARN)
end

function M.error(message)
  notify(message, vim.log.levels.ERROR)
end

return M
