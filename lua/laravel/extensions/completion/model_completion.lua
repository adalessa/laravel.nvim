local model_resolver = require("laravel.extensions.completion.model_completion_type_resolver")

local model_completion = {}

---@async
function model_completion.complete(_, params, callback)
  local result = model_resolver.resolve_model_at_cursor(params.context.bufnr, params.context.cursor_before_line)

  local supported_methods = {
    "where",
    "order",
  }
  local function is_supported_methods(method)
    return vim.iter(supported_methods):any(function(m)
      -- check that has the prefix of m in method
      return method:match("^" .. m)
    end)
  end

  if not (result and result.param_position == 0 and is_supported_methods(result.method) )then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  ---@type laravel.dto.models_response, laravel.error
  local resp, err = Laravel.app("laravel.loaders.models_loader"):load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  local _, model = vim.iter(resp.models):find(function(name)
    return name:match("([^\\]+)$") == result.model or name == result.model
  end)

  if not model then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  local items = vim
    .iter(model.attributes or {})
    :map(function(attribute)
      return {
        label = attribute.name,
        insertText = attribute.name,
        kind = vim.lsp.protocol.CompletionItemKind["Field"],
        documentation = string.format(
          [[
### Property: `%s`
- **Type**: `%s`
- **Cast**: `%s`
- **Fillable**: `%s`
- **Hidden**: `%s`
- **Increments**: `%s`
- **Nullable**: `%s`
- **Unique**: `%s`
]],
          attribute.name or "N/A",
          attribute.type or "N/A",
          attribute.cast or "N/A",
          tostring(attribute.fillable),
          tostring(attribute.hidden),
          tostring(attribute.increments),
          tostring(attribute.nullable),
          tostring(attribute.unique)
        ),
      }
    end)
    :totable()

  return callback({
    items = items,
    isIncomplete = false,
  })
end

function model_completion.shouldComplete(_)
  return true
end

return model_completion
