---@class LaravelModelInfo
---@field class LaravelClassService
---@field api LaravelApi
local model_info = {}

function model_info:new(class, api)
  local instance = {
    class = class,
    api = api,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function model_info:handle(bufnr)
  local namespace = vim.api.nvim_create_namespace("laravel.model")
  self.class:get(bufnr, function(class)
    self.api:tinker(
      string.format(
        [[
    $r = new ReflectionClass("%s");
    $isModel = $r->isSubclassOf("Illuminate\Database\Eloquent\Model");
    echo json_encode([
      'is_model' => $isModel,
      'class_start' => $r->getStartLine(),
    ]);
  ]],
        class.fqn
      ),
      function(res)
        if res:successful() and res:json().is_model then
          self.api:async("artisan", { "model:show", "--json", string.format("\\%s", class.fqn) }, function(result)
            if result:successful() then
              local info = result:json()
              if not info then
                vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
                return
              end

              local virt_lines = {
                { { "[", "comment" } },
                { { " Database: ", "comment" },  { info.database, "@enum" } },
                { { " Table: ", "comment" },     { info.table, "@enum" } },
                { { " Attributes: ", "comment" } },
              }

              for _, attribute in ipairs(info.attributes) do
                table.insert(virt_lines, {
                  { "   " .. attribute.name, "@enum" },
                  { " " .. (attribute.type or 'null'),   "comment" },
                  attribute.cast and { " -> " .. attribute.cast, "@enum" } or nil,
                })
              end

              table.insert(virt_lines, { { "]", "comment" } })

              vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
              vim.api.nvim_buf_set_extmark(bufnr, namespace, res:json().class_start - 1, 0, {
                virt_lines = virt_lines,
                virt_lines_above = true,
              })
            else
              vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
            end
          end, { wrap = true })
        else
          vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
        end
      end,
      { wrap = true }
    )
  end, function()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  end)
end

return model_info
