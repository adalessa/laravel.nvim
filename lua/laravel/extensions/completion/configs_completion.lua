local configs_completion = {}

function configs_completion.complete(configs_loader, templates, params, callback)
  local configs, err = configs_loader:load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  return callback({
    items = vim
      .iter(configs)
      :map(function(config)
        return {
          label = templates:build("config_label", config),
          insertText = config,
          kind = vim.lsp.protocol.CompletionItemKind["Value"],
          documentation = config,
        }
      end)
      :totable(),
    isIncomplete = false,
  })
end

function configs_completion.shouldComplete(text)
  return text:match("config%([%'|%\"]")
end

return configs_completion
