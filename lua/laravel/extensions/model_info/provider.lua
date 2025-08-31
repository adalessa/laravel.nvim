local model_info_provider = {}

---@param app laravel.core.app
function model_info_provider:register(app)
  app:singletonIf("laravel.extensions.model_info.lib")

  vim.tbl_map(function(command)
    app:addCommand("laravel.extensions.model_info." .. command.signature, command)
  end, require("laravel.extensions.model_info.commands"))
end

---@param app laravel.core.app
function model_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.extensions.model_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*.php",
    group = group,
    callback = app:whenActive(function(ev)
      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      ---@type laravel.extensions.model_info.lib
      local lib = app("laravel.extensions.model_info.lib")
      lib:handle(ev.buf)
    end),
  })
end

return model_info_provider
