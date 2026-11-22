---@type laravel.extensions.provider
local completion_provider = {}

local BLINK_SOURCE_ID = "laravel"
local BLINK_SOURCE_MODULE = "laravel.extensions.completion.blink"
local BLINK_FILETYPES = { "php", "blade", "tinker" }

function completion_provider.register(app)
  app:bindIf("completion", "laravel.extensions.completion.source")
end

---Prefer the injected engine so tests (and disabled engines) never fall back
---to requiring a real plugin.
---@param engine table|false|nil
---@param module_name string
---@return table|false
local function resolve_engine(engine, module_name)
  if engine ~= nil then
    return engine
  end

  local ok, module = pcall(require, module_name)
  return ok and module or false
end

---@param app laravel.core.app
---@param cmp table|false
---@return boolean
local function register_cmp(app, cmp)
  if not cmp then
    return false
  end

  cmp.register_source(BLINK_SOURCE_ID, app("completion"))
  return true
end

---@param blink table|false
---@param config table|false
---@return boolean
local function register_blink(blink, config)
  if not blink or not config then
    return false
  end

  if config.sources.providers[BLINK_SOURCE_ID] ~= nil then
    return true
  end

  blink.add_source_provider(BLINK_SOURCE_ID, {
    name = "Laravel",
    module = BLINK_SOURCE_MODULE,
  })

  for _, filetype in ipairs(BLINK_FILETYPES) do
    blink.add_filetype_source(filetype, BLINK_SOURCE_ID)
  end

  return true
end

---blink.cmp is commonly lazy-loaded, so retry registration the first time a
---php/blade buffer or insert mode appears.
---@param engines table
---@return nil
local function watch_for_blink(engines)
  local group = vim.api.nvim_create_augroup("laravel.completion.blink", { clear = true })

  vim.api.nvim_create_autocmd({ "FileType", "InsertEnter" }, {
    group = group,
    callback = function()
      if not vim.tbl_contains(BLINK_FILETYPES, vim.bo.filetype) then
        return
      end

      local blink = resolve_engine(engines.blink, "blink.cmp")
      local config = resolve_engine(engines.blink_config, "blink.cmp.config")
      if register_blink(blink, config) then
        pcall(vim.api.nvim_del_augroup_by_id, group)
      end
    end,
  })
end

---@param app laravel.core.app
---@param opts table|nil
---@param engines table|nil Used by tests to inject or disable completion engines
function completion_provider.boot(app, opts, engines)
  opts = opts or {}
  if opts.enable == false then
    return
  end

  engines = engines or {}
  local cmp = resolve_engine(engines.cmp, "cmp")
  local blink = resolve_engine(engines.blink, "blink.cmp")
  local blink_config = resolve_engine(engines.blink_config, "blink.cmp.config")

  register_cmp(app, cmp)
  if register_blink(blink, blink_config) then
    return
  end

  if engines.watch ~= false then
    watch_for_blink(engines)
  end
end

return completion_provider
