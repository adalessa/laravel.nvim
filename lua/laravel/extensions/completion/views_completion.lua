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
        local isVendor = view.isVendor and " (vendor)" or ""
        return {
          label = templates:build("view_label", view.key),
          insertText = view.key,
          kind = vim.lsp.protocol.CompletionItemKind["Value"],
          documentation = view.path .. isVendor,
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
