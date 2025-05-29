local utils = require("laravel.utils.init")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")
local nio = require("nio")

local action = Class({
  model = "laravel.services.model",
  tinker = "laravel.services.tinker",
}, { info = nil })

---@async
function action:check(bufnr)
  local info, err = self.model:getByBuffer(bufnr)
  if err then
    return false
  end
  self.info = info

  return true
end

function action:format()
  return "Go To Migration of " .. self.info.class
end

---@async
function action:run()
  local table_name, err = self.tinker:text(string.format([[echo (new %s())->getTable();]], self.info.class))
  if err then
    notify.error("Could not get table name: " .. err)
    return
  end
  table_name = vim.trim(table_name)
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
    vim.schedule(function()
      vim.cmd("edit " .. selected)
    end)
  end
end

return action
