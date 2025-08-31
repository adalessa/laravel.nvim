local env_vars_completion = {}

function env_vars_completion.complete(environment_vars_loader, templates, params, callback)
  local variables, err = environment_vars_loader:load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  return callback({
    items = vim
      .iter(variables)
      :map(function(variable)
        return {
          label = templates:build("env_var", variable.key),
          insertText = variable.key,
          kind = vim.lsp.protocol.CompletionItemKind["Value"],
          documentation = string.format("%s = %s", variable.key, variable.value),
        }
      end)
      :totable(),
    isIncomplete = false,
  })
end

function env_vars_completion.shouldComplete(text)
  return text:match("env%([%'|%\"]")
end

return env_vars_completion
