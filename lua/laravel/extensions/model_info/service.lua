---@class LaravelModelInfo
---@field model LaravelModelService
---@field view LaravelModelInfoView
---@field namespace integer
local model_info = {}

function model_info:new(class, tinker, api, model, model_info_view)
  local instance = {
    class = class,
    tinker = tinker,
    api = api,
    model = model,
    view = model_info_view,
    namespace = vim.api.nvim_create_namespace("laravel.model"),
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function model_info:handle(bufnr)
  return self.model:getByBuffer(bufnr):thenCall(function(model)
    vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
    vim.api.nvim_buf_set_extmark(bufnr, self.namespace, model.start - 1, 0, self.view:get(model))
  end, function()
    vim.api.nvim_buf_clear_namespace(bufnr, self.namespace, 0, -1)
  end)
end

function model_info:hide()
  self.visible = false;
end

function model_info:show()
  self.visible = true;
end

function model_info:toggle()
  self.visible = not self.visible
end

return model_info
