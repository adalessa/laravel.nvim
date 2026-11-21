local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

vim.notify = print
vim.opt.rtp:append(root)
vim.opt.swapfile = false

local deps = dofile(root .. "/tests/support/deps.lua")
local resolved, missing = deps.resolve({
  env = vim.env,
  repo_root = root,
  data_dir = vim.fn.stdpath("data") .. "/lazy",
})

if #missing > 0 then
  io.stderr:write(table.concat({
    "Missing test dependencies: " .. table.concat(missing, ", "),
    "Run `nix develop` from the repository root (or `make deps` for a non-Nix setup).",
  }, "\n") .. "\n")
  vim.cmd("cquit 1")
end

deps.setup(resolved)

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
    run = function(_, ...)
      check(...)

      if type(response) == "function" then
        return response(...)
      end

      return response
    end,
  }
end
