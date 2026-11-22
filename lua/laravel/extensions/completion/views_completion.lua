---@type laravel.extensions.completion.Provider
local views_completion = {
  name = "views",
  trigger_characters = { "'", '"' },
  dependencies = {
    views_loader = "laravel.loaders.views_loader",
    templates = "laravel.utils.templates",
  },
}

function views_completion.matches(ctx)
  return ctx.before:match("%f[%a]view%s*%(%s*[\"']") ~= nil or ctx.before:match("%f[%a]View::make%s*%(%s*[\"']") ~= nil
end

function views_completion.complete(_, deps)
  local views, err = deps.views_loader:load()
  if err then
    return {}, err
  end

  return vim
    .iter(views)
    :map(function(view)
      local isVendor = view.isVendor and " (vendor)" or ""
      return {
        label = deps.templates:build("view_label", view.key),
        insertText = view.key,
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = view.path .. isVendor,
      }
    end)
    :totable()
end

return views_completion
