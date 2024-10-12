local common_actions = require("laravel.pickers.common.actions")
local ui_run = require("laravel.pickers.ui_select.ui_run")

local M = {}

function M.run(command)
  common_actions.run(command, ui_run)
end

return M
