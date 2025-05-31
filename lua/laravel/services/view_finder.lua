local utils = require("laravel.utils.init")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

-- FIX: should not have logic of opening and more in a service or notification

---@class laravel.services.view_finder
---@field views_service laravel.services.views
---@field class_service laravel.services.class
local view_finder = Class({
  views_service = "laravel.services.views",
  class_service = "laravel.services.class",
})

---@param view string
function view_finder:usage(view)
  local matches = utils.runRipgrep(string.format("view\\(['\\\"]%s['\\\"]", view))
  if #matches == 0 then
    notify.warn("No usage of this view found")
  elseif #matches == 1 then
    vim.cmd("edit " .. matches[1].file)
  else
    local items = vim.tbl_map(function(item)
      return item.file
    end, matches)
    table.sort(items)
    vim.ui.select(items, { prompt = "File: " }, function(value)
      if not value then
        return
      end
      vim.cmd("edit " .. value)
    end)
  end
end

---@async
---@param view string
function view_finder:definition(view)
  local path, err = self.views_service:pathFromName(view)
  if err then
    notify.error(err)
    return
  end
  vim.schedule(function()
    vim.cmd("edit " .. path)
  end)
end

---@async
function view_finder:handle(bufnr)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if ft == "blade" then
    local name, err = self.views_service:nameFromPath(vim.uri_to_fname(vim.uri_from_bufnr(bufnr)))
    if err then
      notify.error(err)
      return
    end

    self:usage(name)
  end
  if ft == "php" then
    local views, err = self.class_service:views(bufnr)
    if err then
      notify.error(err)
      return
    end
    if #views == 0 then
      notify.warn("No views found")
      return
    end
    if #views == 1 then
      self:definition(views[1])
      return
    end
    vim.ui.select(views, { prompt = "View: " }, function(view)
      if not view then
        return
      end
      self:definition(view)
    end)
  end
end

return view_finder
