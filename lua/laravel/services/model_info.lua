---@class LaravelModelInfo
---@field model LaravelModelService
---@field view LaravelModelInfoView
local model_info = {}

function model_info:new(class, tinker, api, model, model_info_view)
  local instance = {
    class = class,
    tinker = tinker,
    api = api,
    model = model,
    view = model_info_view,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function model_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.model")

  return self.model
      :parse(bufnr)
      :thenCall(function(model)
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        vim.api.nvim_buf_set_extmark(bufnr, namespace, model.start - 1, 0, self.view:get(model))
      end)
      :catch(function()
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end)
end

return model_info
