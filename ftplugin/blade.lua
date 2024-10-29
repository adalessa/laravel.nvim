--- Here set things for blade
vim.keymap.set({ "n" }, "lg", function()
  vim.print("Here needs to find the view if in extends or how")

  vim.cmd("normal! lg")
end, { buffer = 0 })
