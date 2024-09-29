---@class LaravelModelInfo
---@field model LaravelModelService
local model_info = {}

function model_info:new(class, tinker, api, model)
  local instance = {
    class = class,
    tinker = tinker,
    api = api,
    model = model,
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
        local virt_lines = {
          { { "[", "comment" } },
          { { " Database: ", "comment" },  { model.database, "@enum" } },
          { { " Table: ", "comment" },     { model.table, "@enum" } },
          { { " Attributes: ", "comment" } },
        }

        for _, attribute in ipairs(model.attributes) do
          table.insert(virt_lines, {
            { "   " .. attribute.name,                                                     "@enum" },
            { " " .. (attribute.type or "null") .. (attribute.nullable and "|null" or ""), "comment" },
            attribute.cast and { " -> " .. attribute.cast, "@enum" } or nil,
          })
        end

        table.insert(virt_lines, { { "]", "comment" } })

        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        vim.api.nvim_buf_set_extmark(bufnr, namespace, model.start - 1, 0, {
          virt_lines = virt_lines,
          virt_lines_above = true,
        })
      end)
      :catch(function()
        vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
      end)
end

return model_info
