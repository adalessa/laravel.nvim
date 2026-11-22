---@type laravel.extensions.completion.Provider
local env_vars_completion = {
  name = "env_vars",
  trigger_characters = { "'", '"' },
  dependencies = {
    environment_vars_loader = "laravel.loaders.environment_variables_cache_loader",
    templates = "laravel.utils.templates",
  },
}

function env_vars_completion.matches(ctx)
  return ctx.before:match("%f[%a]env%s*%(%s*[\"']") ~= nil
end

function env_vars_completion.complete(_, deps)
  local variables, err = deps.environment_vars_loader:load()
  if err then
    return {}, err
  end

  return vim
    .iter(variables)
    :map(function(variable)
      return {
        label = deps.templates:build("env_var", variable.key),
        insertText = variable.key,
        kind = vim.lsp.protocol.CompletionItemKind["Value"],
        documentation = string.format("%s = %s", variable.key, variable.value),
      }
    end)
    :totable()
end

return env_vars_completion
