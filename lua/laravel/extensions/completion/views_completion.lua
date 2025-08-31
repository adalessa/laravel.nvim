local views_completion = {}

function views_completion.complete(views_loader, templates, params, callback)
  local views, err = views_loader:load()
  if err then
    return callback({
      items = {},
      isIncomplete = false,
    })
  end

  return callback({
    items = vim
      .iter(views)
      :map(function(view)
        return {
          label = templates:build("view_label", view.name),
          insertText = view.name,
          kind = vim.lsp.protocol.CompletionItemKind["Value"],
          documentation = view.path,
        }
      end)
      :totable(),
    isIncomplete = false,
  })
end

function views_completion.shouldComplete(text)
  return text:match("view%([%'|%\"]") or text:match("View::make%([%'|%\"]")
end

return views_completion
