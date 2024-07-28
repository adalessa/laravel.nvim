local group = vim.api.nvim_create_augroup("laravel", {})

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
