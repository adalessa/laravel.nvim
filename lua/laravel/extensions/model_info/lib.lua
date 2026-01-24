local nio = require("nio")
local Class = require("laravel.utils.class")

local clean = vim.schedule_wrap(function(bufnr, namespace)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end)

---@class laravel.extensions.model_info.lib
---@field model_service laravel.services.model
---@field view LaravelModelInfoView
---@field namespace integer
---@field display_status table<string, boolean>
local model_info = Class({
  model_service = "laravel.services.model",
  view = "laravel.extensions.model_info.view",
}, {
  namespace = vim.api.nvim_create_namespace("laravel.model"),
  display_status = {},
})

function model_info:handle(bufnr)
  nio.run(function()
    local model, err = self.model_service:get(bufnr)

    nio.scheduler()
    if err then
      vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
      return
    end

    if self.display_status[bufnr] == nil then
      self.display_status[bufnr] = true
    end

    if self.display_status[bufnr] then
      vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
      vim.api.nvim_buf_set_extmark(bufnr, self.namespace, model.class.position.start.row, 0, self.view:get(model.model))
    end
  end)
end

function model_info:toggle(bufnr)
  self.display_status[bufnr] = not self.display_status[bufnr]
  self:refresh(bufnr)
end

function model_info:show(bufnr)
  self.display_status[bufnr] = true
  self:refresh(bufnr)
end

function model_info:hide(bufnr)
  self.display_status[bufnr] = false
  self:refresh(bufnr)
end

function model_info:refresh(bufnr)
  if self.display_status[bufnr] then
    self:handle(bufnr)
  else
    clean(bufnr, self.namespace)
  end
end

return model_info
