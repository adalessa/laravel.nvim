local lazypath = vim.fn.stdpath("data") .. "/lazy"
vim.notify = print
vim.opt.rtp:append(".")
vim.opt.rtp:append(lazypath .. "/plenary.nvim")
vim.opt.rtp:append(lazypath .. "/nui.nvim")
vim.opt.rtp:append(lazypath .. "/nvim-treesitter")
vim.opt.rtp:append(lazypath .. "/nvim-nio")

vim.opt.swapfile = false
vim.cmd("runtime! plugin/plenary.vim")

A = function(...)
  print(vim.inspect(...))
end

LoadStub = function(stub)
  local file = require("nio").file.open(stub)
  if not file then
    error("Failed to open " .. stub)
  end
  local content = file.read(nil, 0)
  if not content then
    error("Failed to read " .. stub)
  end

  return content
end

CreateApiMock = function(check, response)
  return {
    run = function (_, ...)
      check(...)

      if type(response) == "function" then
        return response(...)
      end

      return response
    end,
  }
end
