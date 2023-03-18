local autocommands = {}

autocommands.dir_changed = function(opts)
  -- register an auto comamnds for the event DirChanged
  -- this should calla the setup again with the provided options
  local group = vim.api.nvim_create_augroup("laravel", {})
  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = function()
      require("laravel").setup(opts)
    end,
  })
end

return autocommands
