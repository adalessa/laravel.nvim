-- a provider should have a register and a boot method
local provider = {}

---@param app function
function provider:register(app)
  app():register_many({
    api = "laravel.api",
    options = "laravel.options",
    env = "laravel.environment",
    class = "laravel.services.class",
  })
end

---@param app function
function provider:boot(app)
  app("env"):boot()

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      require("laravel.app")("env"):boot()
    end,
  })
end

return provider
