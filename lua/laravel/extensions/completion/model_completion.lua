local nio = require("nio")
local model_completion = {}

local function getPositionFromNode(node)
  local start_row, start_col, end_row, end_col = node:range()

  return {
    character = start_col,
    line = start_row,
  }
end

local function getPosition(params)
  vim.treesitter.get_parser(params.context.bufnr):parse()

  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "scoped_call_expression" or node:type() == "member_call_expression" then
      if
        vim.startswith(vim.treesitter.get_node_text(node, params.context.bufnr), "test")
        or vim.startswith(vim.treesitter.get_node_text(node, params.context.bufnr), "it")
      then
        return nil
      end

      return getPositionFromNode(node)
    elseif node:type() == "member_access_expression" then
      return getPositionFromNode(node:child(1))
    end
    node = node:parent()
  end

  return nil
end

---@async
function model_completion.complete(_, params, callback)
  local position = getPosition(params)
  if not position then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  local clients = vim.lsp.get_clients({
    bufnr = params.context.bufnr,
  })

  local client = vim.tbl_filter(function(client)
    return vim.tbl_contains({
      "intelephense",
      "phpactor",
      "phptools",
    }, client.name, {})
  end, clients)[1]

  if not client then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  client = nio.lsp.convert_client(client)

  local err, response = client.request.textDocument_typeDefinition({
    textDocument = {
      uri = vim.uri_from_bufnr(params.context.bufnr),
    },
    position = position,
  }, params.context.bufnr, {})

  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

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
