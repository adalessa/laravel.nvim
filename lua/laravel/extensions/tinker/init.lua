local tinker = {}

function tinker:register(app)
  app:bindIf("tinker_command", "laravel.extensions.tinker.command", { tags = { "command" } })
  app:singeltonIf("tinker_service", "laravel.extensions.tinker.service")
  app:bindIf("tinker_ui", "laravel.extensions.tinker.ui")
end

---@param app laravel.app
function tinker:boot(app)
  vim.filetype.add({ extension = { tinker = "php" } })

  local group = vim.api.nvim_create_augroup("tinker", {})
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*.tinker",
    group = group,
    callback = function(ev)
      local bufnr = ev.buf

      if vim.api.nvim_get_option_value("filetype", { buf = bufnr }) ~= "php" then
        return
      end

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)

      if lines[1] ~= "<?php" then
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { "<?php" })
      end
    end,
  })
end

return tinker
