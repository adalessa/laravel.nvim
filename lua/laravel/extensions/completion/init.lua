local app = require("laravel.core.app")

---@class laravel.extensions.completion.Context
---@field bufnr integer
---@field filetype string
---@field line string Full text of the current line
---@field before string Text before the cursor

---@class laravel.extensions.completion.Provider
---@field name string
---@field trigger_characters string[]|nil
---@field dependencies table<string, string>|nil
---@field matches fun(ctx: laravel.extensions.completion.Context): boolean
---@field complete fun(ctx: laravel.extensions.completion.Context, deps: table): lsp.CompletionItem[], string|nil

---@class laravel.extensions.completion
local completion = {}

completion.supported_filetypes = { "php", "blade", "tinker" }

completion.providers = {
  require("laravel.extensions.completion.views_completion"),
  require("laravel.extensions.completion.inertia_completion"),
  require("laravel.extensions.completion.configs_completion"),
  require("laravel.extensions.completion.routes_completion"),
  require("laravel.extensions.completion.env_vars_completion"),
  require("laravel.extensions.completion.model_completion"),
}

---@return boolean
local function default_is_active()
  local ok, active = pcall(app.isActive, app)
  return ok and active or false
end

---@param ctx laravel.extensions.completion.Context
---@return boolean
function completion.is_supported(ctx)
  return vim.tbl_contains(completion.supported_filetypes, ctx.filetype)
end

---@param filetype string
---@param opts table|nil
---@return boolean
function completion.is_enabled(filetype, opts)
  opts = opts or {}
  local is_active = opts.is_active or default_is_active

  return completion.is_supported({ filetype = filetype }) and is_active()
end

---Build the engine-independent context from an nvim-cmp request.
---@param params table
---@return laravel.extensions.completion.Context
function completion.from_cmp(params)
  local ctx = params.context

  return {
    bufnr = ctx.bufnr,
    filetype = ctx.filetype,
    line = ctx.cursor_line,
    before = ctx.cursor_before_line,
  }
end

---Build the engine-independent context from a blink.cmp request.
---@param ctx blink.cmp.Context
---@return laravel.extensions.completion.Context
function completion.from_blink(ctx)
  return {
    bufnr = ctx.bufnr,
    filetype = vim.bo[ctx.bufnr].filetype,
    line = ctx.line,
    before = ctx.line:sub(1, ctx.cursor[2]),
  }
end

---@param providers laravel.extensions.completion.Provider[]|nil
---@return string[]
function completion.trigger_characters(providers)
  local characters = {}

  for _, provider in ipairs(providers or completion.providers) do
    for _, character in ipairs(provider.trigger_characters or {}) do
      if not vim.tbl_contains(characters, character) then
        table.insert(characters, character)
      end
    end
  end

  return characters
end

---Resolve completions for the normalized context.
---@param ctx laravel.extensions.completion.Context
---@param opts table|nil
---@return lsp.CompletionItem[], string|nil
---@async
function completion.resolve(ctx, opts)
  opts = opts or {}
  local providers = opts.providers or completion.providers
  local get_service = opts.get_service or function(name)
    return app(name)
  end

  if not completion.is_supported(ctx) then
    return {}
  end

  local is_active = opts.is_active or default_is_active
  if not is_active() then
    return {}
  end

  for _, provider in ipairs(providers) do
    if provider.matches(ctx) then
      local deps = {}
      for key, service in pairs(provider.dependencies or {}) do
        deps[key] = get_service(service)
      end

      local items, err = provider.complete(ctx, deps)
      if err then
        return {}, err
      end

      return items or {}, nil
    end
  end

  return {}
end

return completion
