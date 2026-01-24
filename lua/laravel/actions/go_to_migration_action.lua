local utils = require("laravel.utils.init")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")
local nio = require("nio")

---@class laravel.actions.go_to_migration_action
---@field model laravel.services.model
local action = Class({
  model = "laravel.services.model",
}, { info = nil })

---@async
function action:check(bufnr)
  local model_resp, err = self.model:get(bufnr)
  if err then
    return false
  end
  self.info = model_resp.model

  return true
end

function action:format()
  return "Go To Migration of " .. self.info.class
end

function action:run()
  local table_name = self.info.table
  table_name = vim.trim(table_name)
  if not table_name or table_name == "" then
    notify.error("Model has no table defined")
    return
  end
  local matches = utils.runRipgrep(string.format("Schema::(?:create|table)\\('%s'", table_name))

  local selected = nil
  if #matches == 0 then
    notify.error("No migration found for table: " .. table_name)
  elseif #matches == 1 then
    selected = matches[1].file
  else
    selected = nio.ui.select(matches, {
      prompt = "File: ",
      format_entry = function(item)
        return item.file
      end,
    })
  end
  if selected then
    vim.cmd("edit " .. selected)
  end
end

return action
