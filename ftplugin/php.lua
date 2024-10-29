--- Here set things for php buffers

vim.keymap.set({ "n" }, "lg", function()
  vim.print("checks if is in a view if not trigger the old lg")

  vim.cmd("normal! lg")
end, { buffer = 0 })
