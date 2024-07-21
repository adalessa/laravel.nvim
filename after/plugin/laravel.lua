local group = vim.api.nvim_create_augroup("laravel", {})

vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = group,
  callback = function()
    require("laravel.app")("env"):boot()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChangedI" }, {
  group = group,
  pattern = "*.php",
  callback = function(ev)
    -- check that is initialize
    if not require("laravel.app")("env"):is_active() then
      return
    end
    require("laravel.diagnostics.views")(ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  pattern = { "*Controller.php" },
  group = group,
  callback = function(ev)
    if not require("laravel.app")("env"):is_active() then
      return
    end

    require("laravel.route_info")(ev)
  end,
})

require("laravel.user_command")

--- set treesitter queires
require("laravel.treesitter_queries")
require("laravel.tinker")

--- register cmp
local ok, cmp = pcall(require, "cmp")
if ok then
  cmp.register_source("laravel", require("laravel.services.completion"))
end
