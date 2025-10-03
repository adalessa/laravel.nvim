local provider = {}

function provider:register(app)
  app:singletonIf("laravel.extensions.tinker.lib")

  vim.tbl_map(function(command)
    app:addCommand("laravel.extensions.tinker." .. command.signature, command)
  end, require("laravel.extensions.tinker.commands"))
end

---@param app laravel.core.app
function provider:boot(app, opts)
  vim.filetype.add({ extension = { tinker = "php" } })

  app("laravel.extensions.tinker.lib").ui:setConfig(opts)

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

  Laravel.extensions.tinker = setmetatable({
    open = function()
      app("laravel.extensions.tinker.lib"):open()
    end,
    select = function()
      app("laravel.extensions.tinker.lib"):select()
    end,
    create = function()
      app("laravel.extensions.tinker.lib"):create()
    end,
  }, {
    __call = function()
      app("laravel.extensions.tinker.lib"):open()
    end,
  })
end

return provider
