local utils = require "laravel.utils"
local application = require "laravel.application"

local send_to_tinker = function()
  local lines = utils.get_visual_selection()
  if nil == application.container.get "tinker" then
    require("laravel.artisan").run({ "tinker" }, "terminal", { focus = false })
    if nil == application.container.get "tinker" then
      utils.notify("Send To Tinker", { msg = "Tinker terminal id not found and could create it", level = "ERROR" })
      return
    end
  end

  for _, line in ipairs(lines) do
    vim.api.nvim_chan_send(application.container.get "tinker", line .. "\n")
  end
end

return {
  send_to_tinker = send_to_tinker,
}
