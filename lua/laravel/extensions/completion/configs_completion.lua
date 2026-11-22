---@type laravel.extensions.completion.Provider
local configs_completion = {
  name = "configs",
  trigger_characters = { "'", '"' },
  dependencies = {
    configs_loader = "laravel.loaders.configs_loader",
    templates = "laravel.utils.templates",
  },
}

function configs_completion.matches(ctx)
  return ctx.before:match("%f[%a]config%s*%(%s*[\"']") ~= nil
end

function configs_completion.complete(_, deps)
  local configs, err = deps.configs_loader:load()
  if err then
    return {}, err
  end

  return vim
    .iter(configs)
    :map(function(config)
      return {
        label = deps.templates:build("config_label", config.name),
        insertText = config.name,
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = config.name,
      }
    end)
    :totable()
end

return configs_completion
