return {
  dispatch = function(name, data)
    vim.api.nvim_exec_autocmds("User", {
      pattern = name,
      data = data,
    })
  end,
}
