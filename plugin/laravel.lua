local group = vim.api.nvim_create_augroup("laravel", {})

vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = group,
  callback = function()
    require("laravel.environment").setup()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = group,
  pattern = "*.php",
  callback = function(ev)
    -- check that is initialize
    if not require("laravel.environment").get_executable("artisan") then
      return
    end
    require("laravel.diagnostics.views")(ev.buf)
  end,
})


vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  pattern = { "*Controller.php" },
  group = group,
  callback = function(ev)
    if not require("laravel.environment").get_executable("artisan") then
      return
    end

    require("laravel.route_info")(ev)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "routes/*.php" },
  group = group,
  callback = function()
    if not require("laravel.environment").get_executable("artisan") then
      return
    end
    require("laravel.routes").asyncLoad()
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  pattern = { "*Controller.php" },
  group = group,
  callback = function(ev)
    if not require("laravel.environment").get_executable("artisan") then
      return
    end

    require('laravel.route_info')(ev)
  end,
})

--- set treesitter
require("laravel.treesitter_queries")
