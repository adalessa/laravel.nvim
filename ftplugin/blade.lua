--- Here set things for blade
vim.keymap.set({ "n" }, "fg", function()
  vim.print("Here needs to find the view if in extends or how")

  vim.cmd("normal! fg")
end, { buffer = 0 })
