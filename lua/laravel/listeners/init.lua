local cacheService = require "laravel.services.cache_service"

local listeners = {}

local group = vim.api.nvim_create_augroup("LaravelGroup", { clear = true })

function listeners:register()
  vim.api.nvim_create_autocmd("User", {
    pattern = { "LaravelViewCreated" },
    group = group,
    callback = vim.schedule_wrap(function()
      cacheService:forget "views"
    end),
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = {
      "LaravelCommandCreated",
      "LaravelComposerRunned",
    },
    group = group,
    callback = vim.schedule_wrap(function()
      cacheService:forget "commands"
    end),
  })

  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "routes/*.php" },
    group = group,
    callback = vim.schedule_wrap(function()
      cacheService:forget "routes"
    end),
  })
end

return listeners
