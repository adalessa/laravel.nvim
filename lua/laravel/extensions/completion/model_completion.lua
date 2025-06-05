local nio = require("nio")
local model_completion = {}
local app = require("laravel.core.app")

local function getPosition(params)
  local beforeLine = params.context.cursor_before_line
  local cursor = params.context.cursor

  --- Need to support the following multiline
  --- was not able to use treesitter since some times was broken due incomplete syntax
  --- $tip->query()
  ---     ->where(
  --- Tip::query()
  ---     ->where(

  --- Handle static method calls like Tip::where(
  local staticMethodPosition = beforeLine:match(".*()::where%(")
  if type(staticMethodPosition) == "number" and staticMethodPosition ~= 0 then
    return {
      character = staticMethodPosition - 1,
      line = cursor.line,
    }
  end

  --- Handle static method chains like Tip::query()->where(
  local staticChainPosition = beforeLine:match(".*()::query%(%)%->where%(")
  if type(staticChainPosition) == "number" and staticChainPosition ~= 0 then
    return {
      character = staticChainPosition - 1,
      line = cursor.line,
    }
  end

  --- Handle method chains on objects like $tip->query()->where(
  local objectChainPosition = beforeLine:match(".*()%->query%(%)%->where%(")
  if type(objectChainPosition) == "number" and objectChainPosition ~= 0 then
    return {
      character = objectChainPosition - 1,
      line = cursor.line,
    }
  end

  --- This auto complete this case should be always the last
  --- $tip->
  local lastDashPosition = beforeLine:match(".*()%->")
  if type(lastDashPosition) == "number" and lastDashPosition ~= 0 then
    return {
      character = lastDashPosition - 1,
      line = cursor.line,
    }
  end

  return nil
end

---@async
function model_completion.complete(templates, params, callback)
  local position = getPosition(params)
  if not position then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  local client = nio.lsp.get_clients({ name = app("laravel.services.config").get("lsp_server", "phpactor") })[1]
  local err, response = client.request.textDocument_typeDefinition({
    textDocument = {
      uri = vim.uri_from_bufnr(params.context.bufnr),
    },
    position = position,
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
  return callback({
    items = {},
    isIncomplete = false,
  })
end

function model_completion.shouldComplete(_)
  return true
end

return model_completion
