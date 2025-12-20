local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.related
---@field related laravel.services.related
---@field log laravel.utils.log
local related_picker = Class({
  related = "laravel.services.related",
  log = "laravel.utils.log",
})

---@async
function related_picker:run(picker, opts)
  local relations, err = self.related:get(vim.api.nvim_get_current_buf())
  if err then
    notify.error("Error loading related items")
    self.log:error(err)
    return
  end

  picker(opts, relations)
end

return related_picker
