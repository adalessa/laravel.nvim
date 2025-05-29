local nio = require("nio")
local Class = require("laravel.utils.class")

---@class LaravelModelInfo
---@field model laravel.services.model
---@field view LaravelModelInfoView
---@field namespace integer
local model_info = Class({
  class = "laravel.services.class",
  tinker = "laravel.services.tinker",
  model = "laravel.services.model",
  view = "model_info_view",
}, {
  namespace = vim.api.nvim_create_namespace("laravel.model"),
})

function model_info:handle(bufnr)
  nio.run(function()
    local model, err = self.model:getByBuffer(bufnr)
    if err then
      vim.schedule(function()
        vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
      end)
      return
    end

    vim.schedule(function()
      vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
      vim.api.nvim_buf_set_extmark(bufnr, self.namespace, model.start - 1, 0, self.view:get(model))
    end)
  end)
end

function model_info:hide()
  self.visible = false
end

function model_info:show()
  self.visible = true
end

function model_info:toggle()
  self.visible = not self.visible
end

return model_info
