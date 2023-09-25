local notify = require "laravel.notify"
local run = require "laravel.run"
local get_selection = require "laravel.tinker.get_selection"

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local M = {}

M.current_terminal = nil

function M.send_to_tinker()
  local lines = get_selection()
  if nil == M.current_terminal then
    run("artisan", { "tinker" }, { focus = false })
    if nil == M.current_terminal then
      notify("Send To Tinker", { msg = "Tinker terminal id not found and could create it", level = "ERROR" })
      return
    end
  end

  for _, line in ipairs(lines) do
    vim.api.nvim_chan_send(M.current_terminal, trim(line) .. "\n")
  end
end

return M
