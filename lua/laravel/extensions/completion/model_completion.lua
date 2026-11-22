local model_resolver = require("laravel.extensions.completion.model_completion_type_resolver")

---@type laravel.extensions.completion.Provider
local model_completion = {
  name = "model",
  trigger_characters = { "(" },
  dependencies = {
    models_loader = "laravel.loaders.models_loader",
  },
}

---@async
function model_completion.complete(ctx, deps)
  local result = model_resolver.resolve_model_at_cursor(ctx.bufnr, ctx.before)

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

  if not (result and result.param_position == 0 and is_supported_methods(result.method)) then
    return {}
  end

  ---@type laravel.dto.models_response, laravel.error
  local resp, err = deps.models_loader:load()
  if err then
    return {}, err
  end

  local _, model = vim.iter(resp.models):find(function(name)
    return name:match("([^\\]+)$") == result.model or name == result.model
  end)

  if not model then
    return {}
  end

  return vim
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
end

function model_completion.matches(_)
  return true
end

return model_completion
