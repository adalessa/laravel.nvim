local nio = require("nio")
local model_completion = {}

function model_completion.complete(templates, params, callback)
  nio.run(function()
    local beforeLine = params.context.cursor_before_line
    local cursor = params.context.cursor
    local lastDashPosition = beforeLine:match(".*()-")
    if type(lastDashPosition) ~= "number" or lastDashPosition == 0 then
      return callback({
        items = {},
        isIncomplete = false,
      })
    end

    local client = nio.lsp.get_clients({ name = "phpactor" })[1]
    local err, response = client.request.textDocument_typeDefinition({
      textDocument = {
        uri = vim.uri_from_bufnr(params.context.bufnr),
      },
      position = {
        character = lastDashPosition - 1,
        line = cursor.line,
      },
    }, params.context.bufnr, {})
    if response and response.uri then
      local bufnr = vim.uri_to_bufnr(response.uri)
      nio.fn.bufload(bufnr)
      local model, err = Laravel.app("laravel.services.cache"):remember("completion_model_" .. bufnr, 60, function()
        return Laravel.app("laravel.services.model"):getByBuffer(bufnr)
      end)

      if err then
        return callback({
          items = {},
          isIncomplete = false,
        })
      end

      local items = vim
        .iter(model.attributes)
        :map(function(attribute)
          return {
            label = attribute.name,
            insertText = attribute.name,
            kind = vim.lsp.protocol.CompletionItemKind["Property"],
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
    return callback({
      items = {},
      isIncomplete = false,
    })
  end)
end

function model_completion.shouldComplete(_)
  return true
end

return model_completion
