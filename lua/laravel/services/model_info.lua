local promise = require("promise")

---@class LaravelModelInfo
---@field class LaravelClassService
---@field tinker Tinker
---@field api LaravelApi
local model_info = {}

function model_info:new(class, tinker, api)
  local instance = {
    class = class,
    tinker = tinker,
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function model_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.model")
  return self.class
      :get(bufnr)
      :thenCall(function(class)
        return self.tinker
            :json(string.format(
              [[
            $r = new ReflectionClass("%s");
            $isModel = $r->isSubclassOf("Illuminate\Database\Eloquent\Model");
            echo json_encode([
              'is_model' => $isModel,
              'class_start' => $r->getStartLine(),
            ]);
          ]],
              class.fqn
            ))
            :thenCall(function(res)
              if not res.is_model then
                return promise.reject("class is not a model")
              end

              return self.api
                  :send("artisan", { "model:show", "--json", string.format("\\%s", class.fqn) })
                  :thenCall(function(result)
                    local info = result:json()
                    if not info then
                      return promise.reject("info is not json")
                    end

                    return {
                      start = res.class_start,
                      info = info,
                    }
                  end)
            end)
      end)
      :thenCall(function(model)
        local virt_lines = {
          { { "[", "comment" } },
          { { " Database: ", "comment" },  { model.info.database, "@enum" } },
          { { " Table: ", "comment" },     { model.info.table, "@enum" } },
          { { " Attributes: ", "comment" } },
        }

        for _, attribute in ipairs(model.info.attributes) do
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
