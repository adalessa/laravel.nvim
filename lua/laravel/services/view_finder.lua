local utils = require("laravel.utils.init")
local Class = require("laravel.utils.class")
local notify= require("laravel.utils.notify")

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

---@param view string
function view_finder:definition(view)
  self.views_service:open(view)
end

function view_finder:handle(bufnr)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  if ft == "blade" then
    return self.views_service:name(
      vim.uri_to_fname(vim.uri_from_bufnr(bufnr)),
      vim.schedule_wrap(function(view)
        self:usage(view)
      end)
    )
  end
  if ft == "php" then
    return self.class_service:views(bufnr):thenCall(function(views)
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
    end)
  end
end

return view_finder
