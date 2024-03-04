local api = require "laravel.api"

return function(done, should_quote)
  local resp = api.tinker_execute "json_encode(array_keys(Arr::dot(Config::all())));"
  if resp:failed() then
    return
  end

  local configs = vim.json.decode(resp:prettyContent())
  if configs == nil then
    return
  end

  local candidates = {}

  for _, config in pairs(configs) do
    local insert = config
    if should_quote then
      insert = string.format("'%s'", config)
    end
    table.insert(candidates, {
      label = string.format("%s (route)", config),
      insertText = insert,
      kind = vim.lsp.protocol.CompletionItemKind["Value"],
    })
  end

  done { { items = candidates, isIncomplete = false } }
end
