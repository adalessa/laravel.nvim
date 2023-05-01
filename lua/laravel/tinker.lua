local utils = require "laravel.utils"
local application = require "laravel.application"

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

local send_to_tinker = function()
  local lines = utils.get_visual_selection()
  if nil == application.container.get "tinker" then
    application.run("artisan", { "tinker" }, { runner = "terminal", focus = false })
    if nil == application.container.get "tinker" then
      utils.notify("Send To Tinker", { msg = "Tinker terminal id not found and could create it", level = "ERROR" })
      return
    end
  end

  for _, line in ipairs(lines) do
    vim.api.nvim_chan_send(application.container.get "tinker", trim(line) .. "\n")
  end
end

return {
  send_to_tinker = send_to_tinker,
}
