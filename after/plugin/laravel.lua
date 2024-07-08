-- TODO: renable when the options are in vim format
-- require "laravel.bootstrap"
-- require('laravel.app')('env'):boot()

local group = vim.api.nvim_create_augroup("laravel", {})

vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = group,
  callback = function()
    require("laravel.app")("env"):boot()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChangedI" }, {
  group = group,
  pattern = "*.php",
  callback = function(ev)
    -- check that is initialize
    if not require("laravel.app")("env"):is_active() then
      return
    end
    require("laravel.diagnostics.views")(ev.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  pattern = { "*Controller.php" },
  group = group,
  callback = function(ev)
    if not require("laravel.app")("env"):is_active() then
      return
    end

    require("laravel.route_info")(ev)
  end,
})

local function subcommands()
  return vim.iter({
    "art",
    "artisan",
    "routes",
    "composer",
    "sail",
    "assets",
    "commands",
  })
end

vim.api.nvim_create_user_command("Laravel", function(args)
  local subcommand = args.fargs[1]
  if subcommand == "art" or subcommand == "artisan" then
    require("laravel").artisan()
  end
end, {
  nargs = "*",
  complete = function(argLead, cmdLine)
    -- If is the first subcommand
    if #vim.split(cmdLine, " ") <= 2 then
      return subcommands()
          :filter(function(subcommand)
            return vim.startswith(subcommand, argLead)
          end)
          :totable()
    end

    return {}
  end,
})

--- set treesitter queires
require("laravel.treesitter_queries")
require("laravel.tinker")

--- register cmp
local ok, cmp = pcall(require, "cmp")
if ok then
  cmp.register_source("laravel", require("laravel.cmp"))
end
